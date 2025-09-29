import AVFoundation
import Accelerate

/**
 * 频谱分析器类
 * 
 * 功能说明：
 * 1. 使用FFT（快速傅里叶变换）将时域音频信号转换为频域数据
 * 2. 分析音频信号的频谱特征，提取各频段的能量强度
 * 3. 为音频可视化（如频谱柱状图、波形显示）提供数据支持
 * 4. 支持降采样以减少数据量，提高处理效率
 * 
 * 技术原理：
 * - 使用Apple的Accelerate框架中的vDSP函数进行高性能FFT计算
 * - 采用Hann窗函数减少频谱泄漏
 * - 通过降采样降低数据维度，适合实时显示
 * 
 * 应用场景：
 * - 音频播放器的频谱可视化
 * - 实时音频分析
 * - 音频效果处理的可视化反馈
 */
class SpectrumAnalyzer {
    
    // MARK: - 私有属性
    
    /// FFT计算设置对象，用于配置FFT参数
    private var fftSetup: FFTSetup?
    
    /// FFT的log2(n)值，其中n是缓冲区大小
    private var log2n: vDSP_Length
    
    /// 音频缓冲区大小，必须是2的幂次方
    var bufferSize: Int
    
    /// Hann窗函数数组，用于减少频谱泄漏
    private var window: [Float]
    
    /// 输出缓冲区，存储FFT计算结果
    private var outputBuffer: [Float]
    
    /// 频率数据缓冲区
    private var frequencyData: [Float]
    
    /// 降采样因子，用于减少输出数据量
    private var downsampleFactor: Int

    // MARK: - 初始化方法
    
    /**
     * 初始化频谱分析器
     * 
     * - Parameters:
     *   - bufferSize: 音频缓冲区大小，必须是2的幂次方（如1024, 2048等）
     *   - downsampleFactor: 降采样因子，默认值为10
     *                     用于将FFT结果降采样，减少数据量
     *                     例如：1024个频点降采样10倍后得到102个频点
     */
    init(bufferSize: Int, downsampleFactor: Int = 10) {
        self.bufferSize = bufferSize
        self.downsampleFactor = downsampleFactor
        
        // 计算FFT所需的log2(n)值
        self.log2n = vDSP_Length(log2(Float(bufferSize)))
        
        // 创建FFT设置对象，使用基2FFT算法
        self.fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        
        // 初始化Hann窗函数，用于减少频谱泄漏
        self.window = [Float](repeating: 0, count: bufferSize)
        vDSP_hann_window(&window, vDSP_Length(bufferSize), Int32(vDSP_HANN_NORM))
        
        // 初始化输出缓冲区，大小为缓冲区的一半（FFT的对称性）
        self.outputBuffer = [Float](repeating: 0, count: bufferSize / 2)
        self.frequencyData = [Float](repeating: 0, count: bufferSize / 2)
    }

    // MARK: - 析构方法
    
    /**
     * 析构方法，清理FFT设置对象
     * 防止内存泄漏
     */
    deinit {
        if let fftSetup = fftSetup {
            vDSP_destroy_fftsetup(fftSetup)
        }
    }

    // MARK: - 公共方法
    
    /**
     * 分析音频缓冲区，返回频谱数据
     * 
     * - Parameter buffer: 输入的音频PCM缓冲区
     * - Returns: 降采样后的频谱幅度数组，表示各频段的能量强度
     * 
     * 处理流程：
     * 1. 将音频数据转换为复数格式
     * 2. 执行FFT变换，将时域信号转换为频域
     * 3. 计算频谱幅度（magnitude）
     * 4. 降采样以减少数据量
     * 
     * 返回值说明：
     * - 数组长度 = bufferSize / 2 / downsampleFactor
     * - 每个元素代表一个频段的能量强度
     * - 值越大表示该频段的能量越强
     */
    func analyze(buffer: AVAudioPCMBuffer) -> [Float] {
        guard let fftSetup = fftSetup else { return [] }

        let frameCount = buffer.frameLength
        
        // 创建复数数组用于FFT计算
        var realp = [Float](repeating: 0, count: Int(frameCount / 2))  // 实部
        var imagp = [Float](repeating: 0, count: Int(frameCount / 2))  // 虚部
        var magnitudes = [Float](repeating: 0.0, count: Int(frameCount / 2))  // 幅度

        // 使用指针操作进行高性能FFT计算
        realp.withUnsafeMutableBufferPointer { realpPtr in
            imagp.withUnsafeMutableBufferPointer { imagpPtr in
                // 创建复数结构体
                var output = DSPSplitComplex(realp: realpPtr.baseAddress!, imagp: imagpPtr.baseAddress!)

                // 将音频数据转换为复数格式
                buffer.floatChannelData?.pointee.withMemoryRebound(to: DSPComplex.self, capacity: Int(frameCount)) { (inputData) in
                    vDSP_ctoz(inputData, 2, &output, 1, vDSP_Length(frameCount / 2))
                }

                // 执行FFT变换（时域 -> 频域）
                vDSP_fft_zrip(fftSetup, &output, 1, log2n, FFTDirection(FFT_FORWARD))

                // 计算频谱幅度（复数模长）
                vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(frameCount / 2))
            }
        }

        // 降采样并返回结果
        return downsample(magnitudes, factor: downsampleFactor)
    }

    // MARK: - 私有方法
    
    /**
     * 降采样方法，减少数据量
     * 
     * - Parameters:
     *   - data: 原始频谱数据
     *   - factor: 降采样因子
     * - Returns: 降采样后的数据
     * 
     * 降采样原理：
     * 将连续的多个数据点求平均值，减少数据量
     * 例如：factor=10时，每10个数据点合并为1个平均值
     * 
     * 优势：
     * 1. 减少数据量，提高显示性能
     * 2. 平滑频谱数据，减少噪声
     * 3. 适合实时可视化显示
     */
    private func downsample(_ data: [Float], factor: Int) -> [Float] {
        guard factor > 0 else { return data }
        
        let downsampledCount = data.count / factor
        var downsampledData = [Float](repeating: 0.0, count: downsampledCount)
        
        // 对每个降采样点计算平均值
        for i in 0..<downsampledCount {
            let start = i * factor
            let end = start + factor
            let sum = data[start..<end].reduce(0, +)
            downsampledData[i] = sum / Float(factor)
        }
        
        return downsampledData
    }
}
