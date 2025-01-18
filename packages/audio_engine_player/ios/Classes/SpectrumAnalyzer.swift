import AVFoundation
import Accelerate

class SpectrumAnalyzer {
    private var fftSetup: FFTSetup?
    private var log2n: vDSP_Length
    var bufferSize: Int // 将访问级别更改为 internal
    private var window: [Float]
    private var outputBuffer: [Float]
    private var frequencyData: [Float]
    private var downsampleFactor: Int

    init(bufferSize: Int, downsampleFactor: Int = 10) { // 默认降采样因子为10
        self.bufferSize = bufferSize
        self.downsampleFactor = downsampleFactor
        self.log2n = vDSP_Length(log2(Float(bufferSize)))
        self.fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        self.window = [Float](repeating: 0, count: bufferSize)
        vDSP_hann_window(&window, vDSP_Length(bufferSize), Int32(vDSP_HANN_NORM))
        self.outputBuffer = [Float](repeating: 0, count: bufferSize / 2)
        self.frequencyData = [Float](repeating: 0, count: bufferSize / 2)
    }

    deinit {
        if let fftSetup = fftSetup {
            vDSP_destroy_fftsetup(fftSetup)
        }
    }

    func analyze(buffer: AVAudioPCMBuffer) -> [Float] {
        guard let fftSetup = fftSetup else { return [] }

        let frameCount = buffer.frameLength
        var realp = [Float](repeating: 0, count: Int(frameCount / 2))
        var imagp = [Float](repeating: 0, count: Int(frameCount / 2))
        var magnitudes = [Float](repeating: 0.0, count: Int(frameCount / 2))

        realp.withUnsafeMutableBufferPointer { realpPtr in
            imagp.withUnsafeMutableBufferPointer { imagpPtr in
                var output = DSPSplitComplex(realp: realpPtr.baseAddress!, imagp: imagpPtr.baseAddress!)

                buffer.floatChannelData?.pointee.withMemoryRebound(to: DSPComplex.self, capacity: Int(frameCount)) { (inputData) in
                    vDSP_ctoz(inputData, 2, &output, 1, vDSP_Length(frameCount / 2))
                }

                vDSP_fft_zrip(fftSetup, &output, 1, log2n, FFTDirection(FFT_FORWARD))

                vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(frameCount / 2))
            }
        }

        return downsample(magnitudes, factor: downsampleFactor)
    }

    private func downsample(_ data: [Float], factor: Int) -> [Float] {
        guard factor > 0 else { return data }
        let downsampledCount = data.count / factor
        var downsampledData = [Float](repeating: 0.0, count: downsampledCount)
        for i in 0..<downsampledCount {
            let start = i * factor
            let end = start + factor
            let sum = data[start..<end].reduce(0, +)
            downsampledData[i] = sum / Float(factor)
        }
        return downsampledData
    }
}
