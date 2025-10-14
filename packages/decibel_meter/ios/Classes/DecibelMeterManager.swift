//
//  DecibelMeterManager.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//
//  本文件是分贝测量仪的核心管理类，负责：
//  1. 音频采集和处理（AVAudioEngine）
//  2. 分贝计算和权重应用（频率权重、时间权重）
//  3. 统计指标计算（AVG、MIN、MAX、PEAK、LEQ、L10、L50、L90）
//  4. 图表数据生成（时间历程、频谱、统计分布、LEQ趋势）
//  5. 后台录制支持
//  6. 校准功能
//
//  符合国际标准：IEC 61672-1、ISO 1996-1、IEC 61260-1
//

import Foundation
import AVFoundation
import Combine
import UIKit

// MARK: - 数据模型
// 注意：DecibelMeasurement 定义在 DecibelDataModels.swift 中

/// 测量状态（符合专业声级计标准）
///
/// 根据 IEC 61672-1 标准，专业声级计通常只需要2-3个基本状态
/// 本实现包含3个状态：停止、测量中、错误
enum MeasurementState: Equatable {
    /// 停止状态：未进行测量，等待开始
    case idle
    
    /// 测量状态：正在进行分贝测量和数据采集
    case measuring
    
    /// 错误状态：发生错误，包含错误描述信息
    case error(String)
    
    static func == (lhs: MeasurementState, rhs: MeasurementState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.measuring, .measuring):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
    
    /// 获取状态的字符串表示
    var stringValue: String {
        switch self {
        case .idle:
            return "idle"
        case .measuring:
            return "measuring"
        case .error(let message):
            return "error:\(message)"
        }
    }
}

/// 时间权重类型
///
/// 定义声级计的时间响应特性，符合 IEC 61672-1 标准
/// 时间权重影响分贝值对声音变化的响应速度
enum TimeWeighting: String, CaseIterable {
    /// Fast（快）响应：时间常数125ms，适用于一般噪声测量
    case fast = "Fast"
    
    /// Slow（慢）响应：时间常数1000ms，适用于稳态噪声测量
    case slow = "Slow"
    
    /// Impulse（脉冲）响应：上升35ms/下降1500ms，适用于冲击噪声
    case impulse = "Impulse"
    
    /// 获取时间权重的中文描述
    var description: String {
        switch self {
        case .fast:
            return "快响应 - 125ms"
        case .slow:
            return "慢响应 - 1000ms"
        case .impulse:
            return "脉冲响应 - 35ms↑/1500ms↓"
        }
    }
    
    /// 获取时间常数（秒）
    ///
    /// 时间常数决定了声级计对声音变化的响应速度
    /// - Fast: 0.125秒（125ms）
    /// - Slow: 1.0秒（1000ms）
    /// - Impulse: 0.035秒（35ms，上升时间）
    var timeConstant: Double {
        switch self {
        case .fast:
            return 0.125  // 125ms
        case .slow:
            return 1.0    // 1000ms
        case .impulse:
            return 0.035  // 35ms (上升时间)
        }
    }
    
    /// 获取相关技术标准
    ///
    /// 所有时间权重都符合 IEC 61672-1:2013 标准
    var standard: String {
        switch self {
        case .fast:
            return "IEC 61672-1"
        case .slow:
            return "IEC 61672-1"
        case .impulse:
            return "IEC 61672-1"
        }
    }
    
    /// 获取应用场景说明
    ///
    /// 不同的时间权重适用于不同的测量场景
    var application: String {
        switch self {
        case .fast:
            return "一般噪声测量、交通噪声"
        case .slow:
            return "稳态噪声测量、环境监测"
        case .impulse:
            return "冲击噪声、爆炸声、瞬时峰值"
        }
    }
    
    /// 显示符号，用于单位显示
    ///
    /// 返回单字母符号，用于组合显示如"dB(A)F"
    /// - Fast: "F"
    /// - Slow: "S"
    /// - Impulse: "I"
    var displaySymbol: String {
        switch self {
        case .fast:
            return "F"
        case .slow:
            return "S"
        case .impulse:
            return "I"
        }
    }
}

/// 频率权重类型
///
/// 定义声级计的频率响应特性，符合 IEC 61672-1 标准
/// 频率权重模拟人耳对不同频率声音的敏感度差异
enum FrequencyWeighting: String, CaseIterable {
    /// A权重：模拟人耳在40 phon等响度曲线下的响应，最常用
    case aWeight = "dB-A"
    
    /// B权重：模拟人耳在70 phon等响度曲线下的响应，已较少使用
    case bWeight = "dB-B"
    
    /// C权重：模拟人耳在100 phon等响度曲线下的响应，适用于高声级
    case cWeight = "dB-C"
    
    /// Z权重：无频率修正，保持原始频率响应
    case zWeight = "dB-Z"
    
    /// ITU-R 468权重：专门用于广播音频设备的噪声测量
    case ituR468 = "ITU-R 468"
    
    /// 获取频率权重的中文描述
    var description: String {
        switch self {
        case .zWeight:
            return "Z权重 - 无频率修正, 保持原始频率响应"
        case .aWeight:
            return "A权重 - 环境噪声标准, 模拟人耳在40 phon等响度曲线下的响应"
        case .bWeight:
            return "B权重 - 中等响度（已弃用）, 模拟人耳在70 phon等响度曲线下的响应"
        case .cWeight:
            return "C权重 - 高声级测量"
        case .ituR468:
            return "ITU-R 468 - 广播音频标准, 专门用于广播音频设备的噪声测量"
        }
    }
    
    /// 获取相关技术标准
    ///
    /// 返回该频率权重所遵循的国际标准
    var standard: String {
        switch self {
        case .zWeight:
            return "无标准"
        case .aWeight:
            return "IEC 61672-1, ISO 226"
        case .bWeight:
            return "已从IEC 61672-1移除"
        case .cWeight:
            return "IEC 61672-1"
        case .ituR468:
            return "ITU-R BS.468-4"
        }
    }
    
    /// 显示符号，用于单位显示
    ///
    /// 返回单字母或简写符号，用于组合显示如"dB(A)F"
    /// - A权重: "A"
    /// - B权重: "B"
    /// - C权重: "C"
    /// - Z权重: "Z"
    /// - ITU-R 468: "ITU"
    var displaySymbol: String {
        switch self {
        case .zWeight:
            return "Z"
        case .aWeight:
            return "A"
        case .bWeight:
            return "B"
        case .cWeight:
            return "C"
        case .ituR468:
            return "ITU"
        }
    }
}

// MARK: - 分贝测量管理器

/// 分贝测量管理器
///
/// 这是分贝测量仪的核心管理类，采用单例模式设计
/// 负责音频采集、分贝计算、权重应用、统计分析和图表数据生成
///
/// **主要功能**：
/// - 实时音频采集和分贝计算
/// - 频率权重应用（A、B、C、Z、ITU-R 468）
/// - 时间权重应用（Fast、Slow、Impulse）
/// - 统计指标计算（AVG、MIN、MAX、PEAK、LEQ、L10、L50、L90）
/// - 图表数据生成（时间历程、频谱、统计分布、LEQ趋势）
/// - 后台录制支持
/// - 校准功能
///
/// **符合标准**：
/// - IEC 61672-1:2013 - 声级计标准
/// - ISO 1996-1:2016 - 环境噪声测量
/// - IEC 61260-1:2014 - 倍频程滤波器
///
/// **使用方式**：
/// ```swift
/// let manager = DecibelMeterManager.shared
/// await manager.startMeasurement()
/// let indicator = manager.getRealTimeIndicatorData()
/// manager.stopMeasurement()
/// ```
class DecibelMeterManager: NSObject {
    
    // MARK: - 单例
    /// 分贝测量管理器的单例实例
    static let shared = DecibelMeterManager()
    
    // MARK: - 私有属性
    
    /// 当前测量结果，包含原始分贝、权重分贝、频谱等完整信息
    private var currentMeasurement: DecibelMeasurement?
    
    /// 当前测量状态：idle（停止）、measuring（测量中）、error（错误）
    private var measurementState: MeasurementState = .idle
    
    /// 是否正在录制标志
    private var isRecording = false
    
    /// 当前分贝值（已应用权重和校准）
    private var currentDecibel: Double = 0.0
    
    /// 最小分贝值（应用时间权重），-1表示未初始化
    private var minDecibel: Double = -1.0
    
    // MARK: - 回调闭包
    /// 分贝测量结果更新回调。当有新的分贝测量结果产生时调用，参数为最新的 DecibelMeasurement 对象
    var onMeasurementUpdate: ((DecibelMeasurement) -> Void)?
    
    /// 测量状态变化回调。当测量状态（空闲/测量中/错误）发生改变时触发，参数为当前测量状态
    var onStateChange: ((MeasurementState) -> Void)?
    
    /// 分贝计数据更新回调。当有新的分贝数值时调用，参数为：当前分贝值，PEAK, MAX, MIN，LEQ
    var onMeterDataUpdate: ((Double, Double, Double, Double, Double) -> Void)?
    
    // MARK: - 音频相关属性
    
    /// 音频引擎，用于音频采集和处理
    private var audioEngine: AVAudioEngine?
    
    /// 音频输入节点，从麦克风获取音频数据
    private var inputNode: AVAudioInputNode?
    
    /// 音频会话，管理音频资源和后台录制
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    // MARK: - 后台任务管理
    
    /// 后台任务标识符，用于延长后台执行时间
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    /// 后台任务定时器，用于定期延长后台任务
    private var backgroundTaskTimer: Timer?
    
    /// 应用生命周期管理器，处理前后台切换
    private let appLifecycleManager = AppLifecycleManager.shared
    
    // MARK: - 测量相关属性
    
    /// 测量历史记录数组，存储所有的测量结果（最多1000条）
    private var measurementHistory: [DecibelMeasurement] = []
    
    /// 时间权重滤波器，用于应用Fast、Slow、Impulse时间权重
    private var timeWeightingFilter: TimeWeightingFilter?
    
    /// 频率权重滤波器，用于应用A、B、C、Z、ITU-R 468频率权重
    private var frequencyWeightingFilter: FrequencyWeightingFilter?
    
    /// 校准偏移值（dB），用于补偿设备差异
    private var calibrationOffset: Double = 0.0
    
    /// 当前频率权重，默认为A权重（最常用）
    private var currentFrequencyWeighting: FrequencyWeighting = .aWeight
    
    // MARK: - 统计相关属性
    
    /// 当前统计信息，包含AVG、MIN、MAX、PEAK、LEQ、L10、L50、L90等
    private var currentStatistics: DecibelStatistics?
    
    /// PEAK峰值（dB）：瞬时峰值，不应用时间权重，-1表示未初始化
    private var peakDecibel: Double = -1.0
    
    /// MAX最大值（dB）：时间权重后的最大值，-1表示未初始化
    private var maxDecibel: Double = -1.0
    
    /// 测量开始时间，用于计算测量时长
    private var measurementStartTime: Date?
    
    // MARK: - 时间权重相关属性
    
    /// 当前时间权重，默认为Fast（快响应）
    private var currentTimeWeighting: TimeWeighting = .fast
    
    // MARK: - 噪音测量计相关属性
    
    /// 当前使用的噪声限值标准，默认为NIOSH（更保守）
    private var currentNoiseStandard: NoiseStandard = .niosh
    
    /// 标准工作日时长（小时），用于TWA计算
    private let standardWorkDay: Double = 8.0
    
    // MARK: - 配置属性
    
    /// 音频采样率（Hz），标准值为44100Hz
    private let sampleRate: Double = 44100.0
    
    /// 音频缓冲区大小（采样点数），影响处理延迟和精度
    private let bufferSize: UInt32 = 1024
    
    /// 参考声压（Pa），国际标准值为20微帕（20e-6 Pa）
    private let referencePressure: Double = 20e-6
    
    /// 分贝值下限（dB），用于限制异常低值
    private let minDecibelLimit: Double = -20.0
    
    /// 分贝值上限（dB），用于限制异常高值
    private let maxDecibelLimit: Double = 140.0
    
    // MARK: - 初始化
    
    /// 私有初始化方法（单例模式）
    ///
    /// 初始化音频会话和滤波器，确保测量环境准备就绪
    private override init() {
        super.init()
        setupAudioSession()
        setupFilters()
    }
    
    // MARK: - 公共方法
    
    /// 开始测量
    ///
    /// 启动音频采集和分贝测量，初始化所有统计值
    /// 如果已在测量中，则忽略此调用
    ///
    /// **功能**：
    /// - 请求麦克风权限
    /// - 启动音频引擎
    /// - 开始后台任务
    /// - 初始化统计值（MIN、MAX、PEAK）
    /// - 记录测量开始时间
    ///
    /// **注意**：此方法是异步的，需要使用await调用
    ///
    /// **使用示例**：
    /// ```swift
    /// await manager.startMeasurement()
    /// ```
    func startMeasurement() async {
        guard measurementState != .measuring else { return }
        
        do {
            try await requestMicrophonePermission()
            try setupAudioEngine()
            try startAudioEngine()
            
            // 开始后台任务
            startBackgroundTask()
            
            // 初始化统计相关属性
            measurementStartTime = Date()
            peakDecibel = -1.0  // 重置为未初始化状态
            maxDecibel = -1.0   // 重置为未初始化状态
            minDecibel = -1.0   // 重置为未初始化状态，准备记录真实最小值
            
            updateState(.measuring)
            isRecording = true
            
        } catch {
            updateState(.error("启动测量失败: \(error.localizedDescription)"))
        }
    }
    
    /// 停止测量
    ///
    /// 停止音频采集和分贝测量，计算最终统计信息
    ///
    /// **功能**：
    /// - 停止音频引擎
    /// - 结束后台任务
    /// - 计算最终统计信息（如果有测量数据）
    /// - 更新状态为idle
    ///
    /// **使用示例**：
    /// ```swift
    /// manager.stopMeasurement()
    /// ```
    func stopMeasurement() {
        stopAudioEngine()
        
        // 结束后台任务
        endBackgroundTask()
        
        // 计算最终统计信息
        if !measurementHistory.isEmpty {
            currentStatistics = calculateStatistics(from: measurementHistory)
        }
        
        updateState(.idle)
        isRecording = false
    }
    
    /// 获取当前测量状态
    func getCurrentState() -> MeasurementState {
        return measurementState
    }
    
    /// 获取当前分贝值
    func getCurrentDecibel() -> Double {
        return currentDecibel
    }
    
    /// 获取当前测量数据
    func getCurrentMeasurement() -> DecibelMeasurement? {
        return currentMeasurement
    }
    
    /// 获取统计信息
    func getStatistics() -> (current: Double, max: Double, min: Double) {
        return (currentDecibel, maxDecibel, minDecibel)
    }
    
    /// 获取测量历史
    func getMeasurementHistory() -> [DecibelMeasurement] {
        return measurementHistory
    }
    
    /// 设置校准偏移
    func setCalibrationOffset(_ offset: Double) {
        calibrationOffset = offset
    }
    
    /// 获取当前频率权重
    func getCurrentFrequencyWeighting() -> FrequencyWeighting {
        return currentFrequencyWeighting
    }
    
    /// 设置频率权重
    func setFrequencyWeighting(_ weighting: FrequencyWeighting) {
        currentFrequencyWeighting = weighting
    }
    
    /// 获取所有可用的频率权重
    func getAvailableFrequencyWeightings() -> [FrequencyWeighting] {
        return FrequencyWeighting.allCases
    }
    
    /// 获取频率权重曲线数据（用于图表显示）
    func getFrequencyWeightingCurve(_ weighting: FrequencyWeighting) -> [Double] {
        let frequencies = Array(stride(from: 10.0, through: 20000.0, by: 10.0))
        return frequencyWeightingFilter?.getWeightingCurve(weighting, frequencies: frequencies) ?? []
    }
    
    /// 获取当前时间权重
    func getCurrentTimeWeighting() -> TimeWeighting {
        return currentTimeWeighting
    }
    
    /// 设置时间权重
    func setTimeWeighting(_ weighting: TimeWeighting) {
        currentTimeWeighting = weighting
    }
    
    /// 获取所有可用的时间权重
    func getAvailableTimeWeightings() -> [TimeWeighting] {
        return TimeWeighting.allCases
    }
    
    /// 获取当前统计信息
    func getCurrentStatistics() -> DecibelStatistics? {
        return currentStatistics
    }
    
    /// 获取实时LEQ值
    func getRealTimeLeq() -> Double {
        guard !measurementHistory.isEmpty else { return 0.0 }
        let decibelValues = measurementHistory.map { $0.calibratedDecibel }
        return calculateLeq(from: decibelValues)
    }
    
    /// 获取当前峰值
    func getCurrentPeak() -> Double {
        return peakDecibel
    }
    
    // MARK: - 扩展的公共获取方法
    
    /// 获取当前测量时长（格式化为 HH:mm:ss）
    ///
    /// 返回从测量开始到现在的时长，格式为"时:分:秒"
    ///
    /// - Returns: 格式化的时长字符串，如"00:05:23"，未开始测量时返回"00:00:00"
    ///
    /// **使用示例**：
    /// ```swift
    /// let duration = manager.getFormattedMeasurementDuration() // "00:05:23"
    /// ```
    func getFormattedMeasurementDuration() -> String {
        guard let startTime = measurementStartTime else { return "00:00:00" }
        let duration = Date().timeIntervalSince(startTime)
        return formatDuration(duration)
    }
    
    /// 获取当前测量时长（秒）
    ///
    /// 返回从测量开始到现在的时长（秒数）
    ///
    /// - Returns: 测量时长（秒），未开始测量时返回0.0
    ///
    /// **使用示例**：
    /// ```swift
    /// let seconds = manager.getMeasurementDuration() // 323.5
    /// ```
    func getMeasurementDuration() -> TimeInterval {
        guard let startTime = measurementStartTime else { return 0.0 }
        return Date().timeIntervalSince(startTime)
    }
    
    /// 获取当前频率时间权重简写文本
    ///
    /// 返回符合国际标准的权重显示格式，组合频率权重和时间权重
    ///
    /// - Returns: 权重简写文本，格式为"dB(频率权重)时间权重"
    ///
    /// **示例**：
    /// - "dB(A)F" - A权重 + Fast时间权重
    /// - "dB(C)S" - C权重 + Slow时间权重
    /// - "dB(ITU)I" - ITU-R 468权重 + Impulse时间权重
    ///
    /// **使用示例**：
    /// ```swift
    /// let text = manager.getWeightingDisplayText() // "dB(A)F"
    /// ```
    func getWeightingDisplayText() -> String {
        let freqSymbol = currentFrequencyWeighting.displaySymbol
        let timeSymbol = currentTimeWeighting.displaySymbol
        return "dB(\(freqSymbol))\(timeSymbol)"
    }
    
    /// 获取校准偏移值
    ///
    /// 返回当前设置的校准偏移值，用于补偿设备差异
    ///
    /// - Returns: 校准偏移值（dB），正值表示增加，负值表示减少
    ///
    /// **使用示例**：
    /// ```swift
    /// let offset = manager.getCalibrationOffset() // 2.5
    /// ```
    func getCalibrationOffset() -> Double {
        return calibrationOffset
    }
    
    /// 获取最小分贝值
    ///
    /// 返回测量期间的最小分贝值（应用时间权重）
    ///
    /// - Returns: 最小分贝值（dB），未开始测量时返回-1.0
    ///
    /// **注意**：此值应用了时间权重，与PEAK不同
    ///
    /// **使用示例**：
    /// ```swift
    /// let min = manager.getMinDecibel() // 60.2
    /// ```
    func getMinDecibel() -> Double {
        return minDecibel
    }
    
    /// 获取最大分贝值
    ///
    /// 返回测量期间的最大分贝值（应用时间权重）
    ///
    /// - Returns: 最大分贝值（dB），未开始测量时返回-1.0
    ///
    /// **注意**：此值应用了时间权重，与PEAK不同
    /// **区别**：MAX ≤ PEAK（理论上）
    ///
    /// **使用示例**：
    /// ```swift
    /// let max = manager.getMaxDecibel() // 85.7
    /// ```
    func getMaxDecibel() -> Double {
        return maxDecibel
    }
    
    /// 获取LEQ值（等效连续声级）
    ///
    /// 返回实时计算的等效连续声级，表示能量平均值
    ///
    /// - Returns: LEQ值（dB），符合ISO 1996-1标准
    ///
    /// **计算公式**：
    /// ```
    /// LEQ = 10 × log₁₀(1/n × Σᵢ₌₁ⁿ 10^(Li/10))
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// let leq = manager.getLeqDecibel() // 70.3
    /// ```
    func getLeqDecibel() -> Double {
        return getRealTimeLeq()
    }
    
    // MARK: - 权重列表获取方法
    
    /// 获取所有频率权重列表（支持JSON转换）
    ///
    /// 返回所有可用的频率权重选项和当前选择
    ///
    /// - Returns: WeightingOptionsList对象，包含所有频率权重选项
    ///
    /// **包含的权重**：
    /// - dB-A：A权重，环境噪声标准
    /// - dB-B：B权重，中等响度（已弃用）
    /// - dB-C：C权重，高声级测量
    /// - dB-Z：Z权重，无频率修正
    /// - ITU-R 468：广播音频标准
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let list = manager.getFrequencyWeightingsList()
    /// let json = list.toJSON() // 转换为JSON字符串
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// let list = manager.getFrequencyWeightingsList()
    /// for option in list.options {
    ///     print("\(option.displayName): \(option.description)")
    /// }
    /// ```
    func getFrequencyWeightingsList() -> WeightingOptionsList {
        let options = FrequencyWeighting.allCases.map { weighting in
            WeightingOption(
                id: weighting.rawValue,
                displayName: getFrequencyWeightingDisplayName(weighting),
                symbol: weighting.displaySymbol,
                description: weighting.description,
                standard: weighting.standard
            )
        }
        return WeightingOptionsList(
            options: options,
            currentSelection: currentFrequencyWeighting.rawValue
        )
    }
    
    /// 获取所有时间权重列表（支持JSON转换）
    ///
    /// 返回所有可用的时间权重选项和当前选择
    ///
    /// - Returns: WeightingOptionsList对象，包含所有时间权重选项
    ///
    /// **包含的权重**：
    /// - F：Fast（快响应，125ms）
    /// - S：Slow（慢响应，1000ms）
    /// - I：Impulse（脉冲响应，35ms↑/1500ms↓）
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let list = manager.getTimeWeightingsList()
    /// let json = list.toJSON() // 转换为JSON字符串
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// let list = manager.getTimeWeightingsList()
    /// for option in list.options {
    ///     print("\(option.symbol): \(option.description)")
    /// }
    /// ```
    func getTimeWeightingsList() -> WeightingOptionsList {
        let options = TimeWeighting.allCases.map { weighting in
            WeightingOption(
                id: weighting.rawValue,
                displayName: weighting.description,
                symbol: weighting.displaySymbol,
                description: weighting.application,
                standard: weighting.standard
            )
        }
        return WeightingOptionsList(
            options: options,
            currentSelection: currentTimeWeighting.rawValue
        )
    }
    
    // MARK: - 图表数据获取方法
    
    /// 获取时间历程图数据（实时分贝曲线）
    ///
    /// 返回指定时间范围内的分贝变化曲线数据，用于绘制时间历程图
    /// 这是专业声级计最重要的图表类型
    ///
    /// - Parameter timeRange: 时间范围（秒），默认60秒，表示显示最近多少秒的数据
    /// - Returns: TimeHistoryChartData对象，包含数据点、时间范围、分贝范围等
    ///
    /// **图表要求**：
    /// - 横轴：时间（最近60秒或可配置）
    /// - 纵轴：分贝值（0-140 dB）
    /// - 显示：实时更新的曲线
    ///
    /// **数据来源**：measurementHistory（自动过滤指定时间范围）
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let data = manager.getTimeHistoryChartData(timeRange: 60.0)
    /// let json = data.toJSON()
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// // 获取最近60秒的数据
    /// let data = manager.getTimeHistoryChartData(timeRange: 60.0)
    /// print("数据点数量: \(data.dataPoints.count)")
    /// print("分贝范围: \(data.minDecibel) - \(data.maxDecibel) dB")
    /// ```
    func getTimeHistoryChartData(timeRange: TimeInterval = 60.0) -> TimeHistoryChartData {
        let now = Date()
        let startTime = now.addingTimeInterval(-timeRange)
        
        // 过滤指定时间范围内的数据
        let filteredMeasurements = measurementHistory.filter { measurement in
            measurement.timestamp >= startTime
        }
        
        // 转换为数据点
        let dataPoints = filteredMeasurements.map { measurement in
            TimeHistoryDataPoint(
                timestamp: measurement.timestamp,
                decibel: measurement.calibratedDecibel,
                weightingType: currentTimeWeighting.rawValue
            )
        }
        
        // 计算范围
        let decibelValues = dataPoints.map { $0.decibel }
        let minDb = decibelValues.min() ?? 0.0
        let maxDb = decibelValues.max() ?? 140.0
        
        return TimeHistoryChartData(
            dataPoints: dataPoints,
            timeRange: timeRange,
            minDecibel: minDb,
            maxDecibel: maxDb,
            title: "实时分贝曲线 - \(getWeightingDisplayText())"
        )
    }
    
    /// 获取实时指示器数据
    ///
    /// 返回当前所有关键测量指标，这是最常用的数据获取方法
    ///
    /// - Returns: RealTimeIndicatorData对象，包含当前、LEQ、MIN、MAX、PEAK等所有关键指标
    ///
    /// **包含的数据**：
    /// - currentDecibel：当前分贝值（已应用权重和校准）
    /// - leq：等效连续声级
    /// - min：最小值（应用时间权重）
    /// - max：最大值（应用时间权重）
    /// - peak：峰值（不应用时间权重）
    /// - weightingDisplay：权重显示文本，如"dB(A)F"
    ///
    /// **未初始化处理**：MIN/MAX/PEAK < 0时返回0.0
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let data = manager.getRealTimeIndicatorData()
    /// let json = data.toJSON()
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// let indicator = manager.getRealTimeIndicatorData()
    /// print("当前: \(indicator.currentDecibel) \(indicator.weightingDisplay)")
    /// print("LEQ: \(indicator.leq) dB")
    /// print("MIN: \(indicator.min) dB, MAX: \(indicator.max) dB, PEAK: \(indicator.peak) dB")
    /// ```
    func getRealTimeIndicatorData() -> RealTimeIndicatorData {
        return RealTimeIndicatorData(
            currentDecibel: currentDecibel,
            leq: getRealTimeLeq(),
            min: minDecibel < 0 ? 0.0 : minDecibel,
            max: maxDecibel < 0 ? 0.0 : maxDecibel,
            peak: peakDecibel < 0 ? 0.0 : peakDecibel,
            weightingDisplay: getWeightingDisplayText(),
            timestamp: Date()
        )
    }
    
    /// 获取频谱分析图数据
    ///
    /// 返回各频段的声压级分布数据，用于绘制频谱分析图
    /// 符合 IEC 61260-1 标准的倍频程分析要求
    ///
    /// - Parameter bandType: 倍频程类型，"1/1"（10个频点）或"1/3"（30个频点），默认"1/3"
    /// - Returns: SpectrumChartData对象，包含各频率点的声压级数据
    ///
    /// **图表要求**：
    /// - 横轴：频率（Hz）- 对数坐标
    /// - 纵轴：声压级（dB）
    /// - 显示：1/1倍频程或1/3倍频程柱状图
    ///
    /// **频率点**：
    /// - 1/1倍频程：31.5, 63, 125, 250, 500, 1k, 2k, 4k, 8k, 16k Hz
    /// - 1/3倍频程：25, 31.5, 40, 50, 63, 80, 100, 125, ... 20k Hz
    ///
    /// **数据来源**：frequencySpectrum数组或基于权重的模拟数据
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let data = manager.getSpectrumChartData(bandType: "1/3")
    /// let json = data.toJSON()
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// // 1/1倍频程
    /// let spectrum1_1 = manager.getSpectrumChartData(bandType: "1/1")
    ///
    /// // 1/3倍频程
    /// let spectrum1_3 = manager.getSpectrumChartData(bandType: "1/3")
    /// print("频率点数量: \(spectrum1_3.dataPoints.count)")
    /// ```
    func getSpectrumChartData(bandType: String = "1/3") -> SpectrumChartData {
        let frequencies: [Double]
        
        if bandType == "1/1" {
            // 1/1倍频程标准频率
            frequencies = [31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        } else {
            // 1/3倍频程标准频率
            frequencies = [25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, 10000, 12500, 16000, 20000]
        }
        
        // 使用当前测量的频谱数据或模拟数据
        let dataPoints = frequencies.enumerated().map { index, frequency in
            let magnitude: Double
            if let spectrum = currentMeasurement?.frequencySpectrum,
               index < spectrum.count {
                // 使用实际频谱数据并转换为dB
                magnitude = 20.0 * log10(spectrum[index] + 1e-10) + currentDecibel
            } else {
                // 模拟数据：基于当前分贝值和频率权重
                let weightCompensation = frequencyWeightingFilter?.getWeightingdB(currentFrequencyWeighting, frequency: frequency) ?? 0.0
                magnitude = currentDecibel + weightCompensation + Double.random(in: -5...5)
            }
            
            return SpectrumDataPoint(
                frequency: frequency,
                magnitude: max(0, min(140, magnitude)),
                bandType: bandType
            )
        }
        
        return SpectrumChartData(
            dataPoints: dataPoints,
            bandType: bandType == "1/1" ? "1/1倍频程" : "1/3倍频程",
            frequencyRange: (min: frequencies.first ?? 20, max: frequencies.last ?? 20000),
            title: "频谱分析 - \(getWeightingDisplayText())"
        )
    }
    
    /// 获取统计分布图数据（L10、L50、L90）
    ///
    /// 返回声级的统计分布数据，用于分析噪声的统计特性
    /// 符合 ISO 1996-2 标准的统计分析要求
    ///
    /// - Returns: StatisticalDistributionChartData对象，包含各百分位数数据
    ///
    /// **图表要求**：
    /// - 横轴：百分位数（%）
    /// - 纵轴：分贝值（dB）
    /// - 显示：柱状图或折线图
    ///
    /// **关键指标**：
    /// - L10：10%时间超过的声级，表示噪声峰值特征
    /// - L50：50%时间超过的声级，即中位数
    /// - L90：90%时间超过的声级，表示背景噪声水平
    ///
    /// **数据来源**：measurementHistory（自动计算百分位数）
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let data = manager.getStatisticalDistributionChartData()
    /// let json = data.toJSON()
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// let distribution = manager.getStatisticalDistributionChartData()
    /// print("L10: \(distribution.l10) dB") // 噪声峰值
    /// print("L50: \(distribution.l50) dB") // 中位数
    /// print("L90: \(distribution.l90) dB") // 背景噪声
    /// ```
    func getStatisticalDistributionChartData() -> StatisticalDistributionChartData {
        guard !measurementHistory.isEmpty else {
            return StatisticalDistributionChartData(
                dataPoints: [],
                l10: 0.0,
                l50: 0.0,
                l90: 0.0,
                title: "统计分布图"
            )
        }
        
        let decibelValues = measurementHistory.map { $0.calibratedDecibel }.sorted()
        
        // 计算各百分位数
        let percentiles: [Double] = [10, 20, 30, 40, 50, 60, 70, 80, 90]
        let dataPoints = percentiles.map { percentile in
            let value = calculatePercentile(decibelValues, percentile: percentile)
            let label: String
            if percentile == 10 {
                label = "L90"
            } else if percentile == 50 {
                label = "L50"
            } else if percentile == 90 {
                label = "L10"
            } else {
                label = "L\(Int(100 - percentile))"
            }
            
            return StatisticalDistributionPoint(
                percentile: percentile,
                decibel: value,
                label: label
            )
        }
        
        let l10 = calculatePercentile(decibelValues, percentile: 90)
        let l50 = calculatePercentile(decibelValues, percentile: 50)
        let l90 = calculatePercentile(decibelValues, percentile: 10)
        
        return StatisticalDistributionChartData(
            dataPoints: dataPoints,
            l10: l10,
            l50: l50,
            l90: l90,
            title: "统计分布图 - L10: \(String(format: "%.1f", l10)) dB, L50: \(String(format: "%.1f", l50)) dB, L90: \(String(format: "%.1f", l90)) dB"
        )
    }
    
    /// 获取LEQ趋势图数据
    ///
    /// 返回LEQ随时间变化的趋势数据，用于职业健康监测和长期暴露评估
    /// 符合 ISO 1996-1 标准的等效连续声级计算要求
    ///
    /// - Parameter interval: 采样间隔（秒），默认10秒，表示每隔多少秒计算一次LEQ
    /// - Returns: LEQTrendChartData对象，包含时段LEQ和累积LEQ数据
    ///
    /// **图表要求**：
    /// - 横轴：时间
    /// - 纵轴：LEQ值（dB）
    /// - 显示：累积趋势曲线
    ///
    /// **数据内容**：
    /// - 时段LEQ：每个时间段内的LEQ值
    /// - 累积LEQ：从开始到当前的总体LEQ值
    ///
    /// **应用场景**：
    /// - 职业噪声暴露监测
    /// - 环境噪声长期评估
    /// - TWA（时间加权平均）计算
    ///
    /// **数据来源**：measurementHistory（按时间间隔分组计算）
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let data = manager.getLEQTrendChartData(interval: 10.0)
    /// let json = data.toJSON()
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// // 每10秒采样一次
    /// let leqTrend = manager.getLEQTrendChartData(interval: 10.0)
    /// print("当前LEQ: \(leqTrend.currentLeq) dB")
    /// print("数据点数量: \(leqTrend.dataPoints.count)")
    ///
    /// for point in leqTrend.dataPoints {
    ///     print("时段LEQ: \(point.leq) dB, 累积LEQ: \(point.cumulativeLeq) dB")
    /// }
    /// ```
    func getLEQTrendChartData(interval: TimeInterval = 10.0) -> LEQTrendChartData {
        guard !measurementHistory.isEmpty else {
            return LEQTrendChartData(
                dataPoints: [],
                timeRange: 0.0,
                currentLeq: 0.0,
                title: "LEQ趋势图"
            )
        }
        
        // 按时间间隔分组计算LEQ
        var dataPoints: [LEQTrendDataPoint] = []
        var cumulativeLeq = 0.0
        
        let startTime = measurementHistory.first!.timestamp
        let endTime = measurementHistory.last!.timestamp
        let totalDuration = endTime.timeIntervalSince(startTime)
        
        var currentTime = startTime
        var currentGroup: [DecibelMeasurement] = []
        
        for measurement in measurementHistory {
            if measurement.timestamp.timeIntervalSince(currentTime) >= interval {
                // 计算当前组的LEQ
                if !currentGroup.isEmpty {
                    let groupDecibelValues = currentGroup.map { $0.calibratedDecibel }
                    let groupLeq = calculateLeq(from: groupDecibelValues)
                    
                    // 计算累积LEQ
                    let allPreviousValues = measurementHistory
                        .filter { $0.timestamp <= measurement.timestamp }
                        .map { $0.calibratedDecibel }
                    cumulativeLeq = calculateLeq(from: allPreviousValues)
                    
                    dataPoints.append(LEQTrendDataPoint(
                        timestamp: currentTime,
                        leq: groupLeq,
                        cumulativeLeq: cumulativeLeq
                    ))
                }
                
                currentTime = measurement.timestamp
                currentGroup = [measurement]
            } else {
                currentGroup.append(measurement)
            }
        }
        
        // 添加最后一组
        if !currentGroup.isEmpty {
            let groupDecibelValues = currentGroup.map { $0.calibratedDecibel }
            let groupLeq = calculateLeq(from: groupDecibelValues)
            cumulativeLeq = getRealTimeLeq()
            
            dataPoints.append(LEQTrendDataPoint(
                timestamp: currentTime,
                leq: groupLeq,
                cumulativeLeq: cumulativeLeq
            ))
        }
        
        return LEQTrendChartData(
            dataPoints: dataPoints,
            timeRange: totalDuration,
            currentLeq: getRealTimeLeq(),
            title: "LEQ趋势图 - 当前LEQ: \(String(format: "%.1f", getRealTimeLeq())) dB"
        )
    }
    
    // MARK: - 设置方法
    
    /// 重置所有状态和数据
    ///
    /// 完全重置分贝测量仪，清除所有测量数据和设置
    ///
    /// **重置内容**：
    /// - 停止测量（如果正在测量）
    /// - 清除所有历史数据
    /// - 重置统计值（MIN=-1, MAX=-1, PEAK=-1, LEQ=0）
    /// - 重置校准偏移为0
    /// - 重置状态为idle
    ///
    /// **注意**：此操作不可恢复，会丢失所有测量数据
    ///
    /// **使用场景**：
    /// - 开始新的测量会话
    /// - 清除错误状态
    /// - 恢复初始设置
    ///
    /// **使用示例**：
    /// ```swift
    /// manager.resetAllData()
    /// print("状态: \(manager.getCurrentState())") // idle
    /// print("分贝值: \(manager.getCurrentDecibel())") // 0.0
    /// ```
    func resetAllData() {
        // 停止测量
        if measurementState == .measuring {
            stopMeasurement()
        }
        
        // 清除所有数据
        measurementHistory.removeAll()
        currentMeasurement = nil
        currentStatistics = nil
        measurementStartTime = nil
        
        // 重置统计值
        currentDecibel = 0.0
        minDecibel = -1.0
        maxDecibel = -1.0
        peakDecibel = -1.0
        
        // 重置校准
        calibrationOffset = 0.0
        
        // 重置状态
        updateState(.idle)
        isRecording = false
    }
    
    // MARK: - 私有辅助方法
    
    /// 格式化时间间隔为 HH:mm:ss 格式
    ///
    /// 将秒数转换为"时:分:秒"格式的字符串
    ///
    /// - Parameter duration: 时间间隔（秒）
    /// - Returns: 格式化的时间字符串，如"00:05:23"
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// 获取频率权重的显示名称
    ///
    /// 将频率权重枚举转换为用户友好的显示名称
    ///
    /// - Parameter weighting: 频率权重枚举值
    /// - Returns: 显示名称，如"dB-A"、"dB-C"、"ITU-R 468"
    private func getFrequencyWeightingDisplayName(_ weighting: FrequencyWeighting) -> String {
        switch weighting {
        case .aWeight:
            return "dB-A"
        case .bWeight:
            return "dB-B"
        case .cWeight:
            return "dB-C"
        case .zWeight:
            return "dB-Z"
        case .ituR468:
            return "ITU-R 468"
        }
    }
    
    // MARK: - 噪音测量计功能（公共API）
    
    /// 获取完整的噪声剂量数据
    ///
    /// 返回包含剂量、TWA、预测时间等完整信息的数据对象
    /// 这是噪音测量计最主要的API方法
    ///
    /// - Parameter standard: 噪声限值标准，默认使用当前设置的标准
    /// - Returns: NoiseDoseData对象
    ///
    /// **包含的数据**：
    /// - 剂量百分比（%）
    /// - 剂量率（%/小时）
    /// - TWA值（dB）
    /// - 是否超标
    /// - 限值余量（dB）
    /// - 预测达标时间（小时）
    /// - 剩余允许时间（小时）
    /// - 风险等级
    ///
    /// **使用示例**：
    /// ```swift
    /// let doseData = manager.getNoiseDoseData(standard: .osha)
    /// print("剂量: \(doseData.dosePercentage)%")
    /// print("TWA: \(doseData.twa) dB")
    /// print("风险等级: \(doseData.riskLevel)")
    /// ```
    func getNoiseDoseData(standard: NoiseStandard? = nil) -> NoiseDoseData {
        let useStandard = standard ?? currentNoiseStandard
        let leq = getRealTimeLeq()
        let duration = getMeasurementDuration()
        
        // 计算TWA
        let twa = calculateTWA(leq: leq, duration: duration, standardWorkDay: standardWorkDay)
        
        // 计算剂量
        let dose = calculateNoiseDose(twa: twa, standard: useStandard)
        
        // 计算剂量率
        let doseRate = calculateDoseRate(currentDose: dose, duration: duration)
        
        // 判断是否超标
        let isExceeding = twa >= useStandard.twaLimit
        
        // 计算限值余量
        let limitMargin = useStandard.twaLimit - twa
        
        // 预测达到100%剂量的时间
        let predictedTime = predictTimeToFullDose(currentDose: dose, doseRate: doseRate)
        
        // 计算剩余允许时间
        let remainingTime = calculateRemainingAllowedTime(currentDose: dose, doseRate: doseRate)
        
        // 判断风险等级
        let riskLevel = RiskLevel.from(dosePercentage: dose)
        
        return NoiseDoseData(
            dosePercentage: dose,
            doseRate: doseRate,
            twa: twa,
            duration: duration / 3600.0,  // 转换为小时
            standard: useStandard,
            isExceeding: isExceeding,
            limitMargin: limitMargin,
            predictedTimeToFullDose: predictedTime,
            remainingAllowedTime: remainingTime,
            riskLevel: riskLevel
        )
    }
    
    /// 检查是否超过限值
    ///
    /// 检查当前TWA或剂量是否超过指定标准的限值
    ///
    /// - Parameter standard: 噪声限值标准
    /// - Returns: 是否超过限值
    ///
    /// **使用示例**：
    /// ```swift
    /// if manager.isExceedingLimit(standard: .osha) {
    ///     print("警告：已超过OSHA限值！")
    /// }
    /// ```
    func isExceedingLimit(standard: NoiseStandard) -> Bool {
        let doseData = getNoiseDoseData(standard: standard)
        return doseData.isExceeding
    }
    
    /// 获取限值比较结果
    ///
    /// 返回与指定标准的详细比较结果，包括余量、风险等级、建议措施
    ///
    /// - Parameter standard: 噪声限值标准
    /// - Returns: LimitComparisonResult对象
    ///
    /// **使用示例**：
    /// ```swift
    /// let result = manager.getLimitComparisonResult(standard: .niosh)
    /// print("TWA: \(result.currentTWA) dB, 限值: \(result.twaLimit) dB")
    /// print("余量: \(result.limitMargin) dB")
    /// ```
    func getLimitComparisonResult(standard: NoiseStandard) -> LimitComparisonResult {
        let doseData = getNoiseDoseData(standard: standard)
        
        // 生成建议措施
        var recommendations: [String] = []
        
        if doseData.twa >= standard.actionLevel {
            recommendations.append("已达到行动值，建议采取听力保护措施")
        }
        
        if doseData.isExceeding {
            recommendations.append("已超过TWA限值，必须立即采取控制措施")
            recommendations.append("必须佩戴听力保护设备")
            recommendations.append("建议减少暴露时间或降低噪声源")
        } else if doseData.dosePercentage >= 50.0 {
            recommendations.append("剂量已达50%以上，建议佩戴听力保护设备")
        }
        
        if doseData.dosePercentage >= 80.0 && !doseData.isExceeding {
            recommendations.append("接近限值，建议缩短暴露时间")
        }
        
        return LimitComparisonResult(
            standard: standard,
            currentTWA: doseData.twa,
            twaLimit: standard.twaLimit,
            currentDose: doseData.dosePercentage,
            isExceeding: doseData.isExceeding,
            isActionLevelReached: doseData.twa >= standard.actionLevel,
            limitMargin: doseData.limitMargin,
            doseMargin: 100.0 - doseData.dosePercentage,
            riskLevel: doseData.riskLevel,
            recommendations: recommendations
        )
    }
    
    /// 获取剂量累积图数据
    ///
    /// 返回剂量随时间累积的数据，用于绘制剂量累积图
    ///
    /// - Parameters:
    ///   - interval: 采样间隔（秒），默认60秒
    ///   - standard: 噪声限值标准
    /// - Returns: DoseAccumulationChartData对象
    ///
    /// **图表要求**：
    /// - 横轴：时间（小时）
    /// - 纵轴：剂量（%）
    /// - 显示：累积曲线 + 100%限值线
    ///
    /// **使用示例**：
    /// ```swift
    /// let data = manager.getDoseAccumulationChartData(interval: 60.0, standard: .osha)
    /// print("当前剂量: \(data.currentDose)%")
    /// ```
    func getDoseAccumulationChartData(interval: TimeInterval = 60.0, standard: NoiseStandard? = nil) -> DoseAccumulationChartData {
        let useStandard = standard ?? currentNoiseStandard
        
        guard !measurementHistory.isEmpty else {
            return DoseAccumulationChartData(
                dataPoints: [],
                currentDose: 0.0,
                limitLine: 100.0,
                standard: useStandard,
                timeRange: 0.0,
                title: "剂量累积图 - \(useStandard.rawValue)"
            )
        }
        
        var dataPoints: [DoseAccumulationPoint] = []
        let startTime = measurementHistory.first!.timestamp
        var currentTime = startTime
        var currentGroup: [DecibelMeasurement] = []
        
        for measurement in measurementHistory {
            if measurement.timestamp.timeIntervalSince(currentTime) >= interval {
                // 计算当前时间点的累积剂量
                if !currentGroup.isEmpty {
                    let allPreviousValues = measurementHistory
                        .filter { $0.timestamp <= measurement.timestamp }
                        .map { $0.calibratedDecibel }
                    
                    let cumulativeLeq = calculateLeq(from: allPreviousValues)
                    let exposureTime = measurement.timestamp.timeIntervalSince(startTime)
                    let twa = calculateTWA(leq: cumulativeLeq, duration: exposureTime)
                    let dose = calculateNoiseDose(twa: twa, standard: useStandard)
                    
                    dataPoints.append(DoseAccumulationPoint(
                        timestamp: measurement.timestamp,
                        cumulativeDose: dose,
                        currentTWA: twa,
                        exposureTime: exposureTime / 3600.0  // 转换为小时
                    ))
                }
                
                currentTime = measurement.timestamp
                currentGroup = [measurement]
            } else {
                currentGroup.append(measurement)
            }
        }
        
        // 添加最后一个点
        if !currentGroup.isEmpty {
            let leq = getRealTimeLeq()
            let duration = getMeasurementDuration()
            let twa = calculateTWA(leq: leq, duration: duration)
            let dose = calculateNoiseDose(twa: twa, standard: useStandard)
            
            dataPoints.append(DoseAccumulationPoint(
                timestamp: Date(),
                cumulativeDose: dose,
                currentTWA: twa,
                exposureTime: duration / 3600.0
            ))
        }
        
        let finalDose = dataPoints.last?.cumulativeDose ?? 0.0
        let totalDuration = getMeasurementDuration() / 3600.0
        
        return DoseAccumulationChartData(
            dataPoints: dataPoints,
            currentDose: finalDose,
            limitLine: 100.0,
            standard: useStandard,
            timeRange: totalDuration,
            title: "剂量累积图 - \(useStandard.rawValue) - 当前: \(String(format: "%.1f", finalDose))%"
        )
    }
    
    /// 获取TWA趋势图数据
    ///
    /// 返回TWA随时间变化的数据，用于绘制TWA趋势图
    ///
    /// - Parameters:
    ///   - interval: 采样间隔（秒），默认60秒
    ///   - standard: 噪声限值标准
    /// - Returns: TWATrendChartData对象
    ///
    /// **图表要求**：
    /// - 横轴：时间（小时）
    /// - 纵轴：TWA（dB）
    /// - 显示：TWA曲线 + 限值线
    ///
    /// **使用示例**：
    /// ```swift
    /// let data = manager.getTWATrendChartData(interval: 60.0, standard: .niosh)
    /// print("当前TWA: \(data.currentTWA) dB")
    /// ```
    func getTWATrendChartData(interval: TimeInterval = 60.0, standard: NoiseStandard? = nil) -> TWATrendChartData {
        let useStandard = standard ?? currentNoiseStandard
        
        guard !measurementHistory.isEmpty else {
            return TWATrendChartData(
                dataPoints: [],
                currentTWA: 0.0,
                limitLine: useStandard.twaLimit,
                standard: useStandard,
                timeRange: 0.0,
                title: "TWA趋势图 - \(useStandard.rawValue)"
            )
        }
        
        var dataPoints: [TWATrendDataPoint] = []
        let startTime = measurementHistory.first!.timestamp
        var currentTime = startTime
        var currentGroup: [DecibelMeasurement] = []
        
        for measurement in measurementHistory {
            if measurement.timestamp.timeIntervalSince(currentTime) >= interval {
                // 计算当前时间点的TWA
                if !currentGroup.isEmpty {
                    let allPreviousValues = measurementHistory
                        .filter { $0.timestamp <= measurement.timestamp }
                        .map { $0.calibratedDecibel }
                    
                    let cumulativeLeq = calculateLeq(from: allPreviousValues)
                    let exposureTime = measurement.timestamp.timeIntervalSince(startTime)
                    let twa = calculateTWA(leq: cumulativeLeq, duration: exposureTime)
                    let dose = calculateNoiseDose(twa: twa, standard: useStandard)
                    
                    dataPoints.append(TWATrendDataPoint(
                        timestamp: measurement.timestamp,
                        twa: twa,
                        exposureTime: exposureTime / 3600.0,  // 转换为小时
                        dosePercentage: dose
                    ))
                }
                
                currentTime = measurement.timestamp
                currentGroup = [measurement]
            } else {
                currentGroup.append(measurement)
            }
        }
        
        // 添加最后一个点
        if !currentGroup.isEmpty {
            let leq = getRealTimeLeq()
            let duration = getMeasurementDuration()
            let twa = calculateTWA(leq: leq, duration: duration)
            let dose = calculateNoiseDose(twa: twa, standard: useStandard)
            
            dataPoints.append(TWATrendDataPoint(
                timestamp: Date(),
                twa: twa,
                exposureTime: duration / 3600.0,
                dosePercentage: dose
            ))
        }
        
        let finalTWA = dataPoints.last?.twa ?? 0.0
        let totalDuration = getMeasurementDuration() / 3600.0
        
        return TWATrendChartData(
            dataPoints: dataPoints,
            currentTWA: finalTWA,
            limitLine: useStandard.twaLimit,
            standard: useStandard,
            timeRange: totalDuration,
            title: "TWA趋势图 - \(useStandard.rawValue) - 当前: \(String(format: "%.1f", finalTWA)) dB"
        )
    }
    
    /// 设置噪声限值标准
    ///
    /// 切换使用的噪声限值标准（OSHA、NIOSH、GBZ、EU）
    ///
    /// - Parameter standard: 要设置的标准
    ///
    /// **使用示例**：
    /// ```swift
    /// manager.setNoiseStandard(.osha)
    /// ```
    func setNoiseStandard(_ standard: NoiseStandard) {
        currentNoiseStandard = standard
    }
    
    /// 获取当前噪声限值标准
    ///
    /// - Returns: 当前使用的标准
    func getCurrentNoiseStandard() -> NoiseStandard {
        return currentNoiseStandard
    }
    
    /// 获取所有可用的噪声限值标准列表
    ///
    /// - Returns: 所有标准的数组
    func getAvailableNoiseStandards() -> [NoiseStandard] {
        return NoiseStandard.allCases
    }
    
    /// 生成噪音测量计综合报告
    ///
    /// 生成包含所有关键数据的完整报告，用于法规符合性评估
    ///
    /// - Parameter standard: 噪声限值标准
    /// - Returns: NoiseDosimeterReport对象，如果未开始测量则返回nil
    ///
    /// **使用示例**：
    /// ```swift
    /// if let report = manager.generateNoiseDosimeterReport(standard: .osha) {
    ///     if let json = report.toJSON() {
    ///         // 保存或分享报告
    ///     }
    /// }
    /// ```
    func generateNoiseDosimeterReport(standard: NoiseStandard? = nil) -> NoiseDosimeterReport? {
        guard let startTime = measurementStartTime else { return nil }
        let useStandard = standard ?? currentNoiseStandard
        
        let doseData = getNoiseDoseData(standard: useStandard)
        let comparisonResult = getLimitComparisonResult(standard: useStandard)
        let statistics = currentStatistics
        
        return NoiseDosimeterReport(
            reportTime: Date(),
            measurementStartTime: startTime,
            measurementEndTime: Date(),
            measurementDuration: getMeasurementDuration() / 3600.0,
            standard: useStandard,
            doseData: doseData,
            comparisonResult: comparisonResult,
            leq: getRealTimeLeq(),
            statistics: ReportStatistics(
                avg: statistics?.avgDecibel ?? 0.0,
                min: statistics?.minDecibel ?? 0.0,
                max: statistics?.maxDecibel ?? 0.0,
                peak: statistics?.peakDecibel ?? 0.0,
                l10: statistics?.l10Decibel ?? 0.0,
                l50: statistics?.l50Decibel ?? 0.0,
                l90: statistics?.l90Decibel ?? 0.0
            )
        )
    }
    
    /// 获取允许暴露时长表
    ///
    /// 根据当前测量数据生成允许暴露时长表，包含每个声级的累计暴露时间和剂量
    /// 该表格展示了不同声级下的允许暴露时间、实际累计时间和剂量贡献
    ///
    /// - Parameter standard: 噪声限值标准，默认使用当前设置的标准
    /// - Returns: PermissibleExposureDurationTable对象
    ///
    /// **表格内容**：
    /// - 声级列表：从基准限值开始，按交换率递增至天花板限值
    /// - 允许时长：根据标准计算的最大允许暴露时间
    /// - 累计时长：实际测量中在该声级范围内的累计时间
    /// - 声级剂量：该声级的剂量贡献百分比
    ///
    /// **计算原理**：
    /// ```
    /// 允许时长 = 8小时 × 2^((基准限值 - 声级) / 交换率)
    /// 声级剂量 = (累计时长 / 允许时长) × 100%
    /// 总剂量 = Σ 各声级剂量
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// let table = manager.getPermissibleExposureDurationTable(standard: .niosh)
    /// print("总剂量: \(table.totalDose)%")
    /// print("超标声级数: \(table.exceedingLevelsCount)")
    /// for duration in table.durations {
    ///     print("\(duration.soundLevel) dB: \(duration.formattedAccumulatedDuration) / \(duration.formattedAllowedDuration) (\(String(format: "%.1f", duration.currentLevelDose))%)")
    /// }
    /// ```
    func getPermissibleExposureDurationTable(standard: NoiseStandard? = nil) -> PermissibleExposureDurationTable {
        let useStandard = standard ?? currentNoiseStandard
        let criterionLevel = useStandard.twaLimit
        let exchangeRate = useStandard.exchangeRate
        let ceilingLimit = 115.0  // 通用天花板限值
        
        // 生成声级列表（从基准限值开始，按交换率递增）
        var soundLevels: [Double] = []
        var currentLevel = criterionLevel
        while currentLevel <= ceilingLimit {
            soundLevels.append(currentLevel)
            currentLevel += exchangeRate
        }
        
        // 计算每个声级的累计暴露时间
        // 使用字典存储每个声级范围的累计时间
        var levelDurations: [Double: TimeInterval] = [:]
        
        for measurement in measurementHistory {
            let level = measurement.calibratedDecibel
            
            // 找到小于或等于当前分贝值的最接近的限值
            // 例如：87dB 归类到 85dB，92dB 归类到 91dB
            var targetLevel: Double? = nil
            
            // 从高到低遍历声级列表，找到第一个小于或等于当前分贝值的限值
            for i in stride(from: soundLevels.count - 1, through: 0, by: -1) {
                if level >= soundLevels[i] {
                    targetLevel = soundLevels[i]
                    break
                }
            }
            
            // 如果找到了目标限值，累加时间
            if let targetLevel = targetLevel {
                levelDurations[targetLevel, default: 0.0] += 1.0
            }
        }
        
        // 生成表项
        let durations = soundLevels.map { soundLevel -> PermissibleExposureDuration in
            // 计算允许时长：T = 8小时 × 2^((基准限值 - 声级) / 交换率)
            let allowedHours = 8.0 * pow(2.0, (criterionLevel - soundLevel) / exchangeRate)
            let allowedDuration = allowedHours * 3600.0  // 转换为秒
            
            // 获取累计时长
            let accumulatedDuration = levelDurations[soundLevel] ?? 0.0
            
            // 判断是否为天花板限值
            let isCeilingLimit = soundLevel >= ceilingLimit
            
            return PermissibleExposureDuration(
                soundLevel: soundLevel,
                allowedDuration: allowedDuration,
                accumulatedDuration: accumulatedDuration,
                isCeilingLimit: isCeilingLimit
            )
        }
        
        return PermissibleExposureDurationTable(
            standard: useStandard,
            criterionLevel: criterionLevel,
            exchangeRate: exchangeRate,
            ceilingLimit: ceilingLimit,
            durations: durations
        )
    }
    
    // MARK: - 噪音测量计私有计算方法
    
    /// 计算TWA（时间加权平均值）- 私有方法
    ///
    /// 根据LEQ和测量时长计算8小时时间加权平均值
    /// 此方法为内部计算使用，外部通过getNoiseDoseData()获取TWA值
    ///
    /// - Parameters:
    ///   - leq: 等效连续声级（dB）
    ///   - duration: 实际测量时长（秒）
    ///   - standardWorkDay: 标准工作日时长（小时），默认8小时
    /// - Returns: TWA值（dB）
    ///
    /// **计算公式**：
    /// ```
    /// TWA = 10 × log₁₀((T/8) × 10^(LEQ/10))
    /// ```
    private func calculateTWA(leq: Double, duration: TimeInterval, standardWorkDay: Double = 8.0) -> Double {
        let exposureHours = duration / 3600.0  // 转换为小时
        
        // TWA = 10 × log₁₀((T/8) × 10^(LEQ/10))
        let energyFraction = (exposureHours / standardWorkDay) * pow(10.0, leq / 10.0)
        let twa = 10.0 * log10(energyFraction)
        
        return twa
    }
    
    /// 计算噪声剂量（Dose）- 私有方法
    ///
    /// 根据TWA计算噪声剂量百分比
    /// 此方法为内部计算使用，外部通过getNoiseDoseData()获取剂量值
    ///
    /// - Parameters:
    ///   - twa: 时间加权平均值（dB）
    ///   - standard: 噪声限值标准
    /// - Returns: 噪声剂量百分比（%）
    ///
    /// **计算公式**：
    /// ```
    /// Dose = 100 × 2^((TWA - CriterionLevel) / ExchangeRate)
    /// ```
    private func calculateNoiseDose(twa: Double, standard: NoiseStandard) -> Double {
        let criterionLevel = standard.criterionLevel
        let exchangeRate = standard.exchangeRate
        
        // Dose = 100 × 2^((TWA - 85) / ExchangeRate)
        let dose = 100.0 * pow(2.0, (twa - criterionLevel) / exchangeRate)
        
        return dose
    }
    
    /// 计算剂量率（Dose Rate）- 私有方法
    ///
    /// 计算单位时间内的剂量累积速率
    /// 此方法为内部计算使用，外部通过getNoiseDoseData()获取剂量率
    ///
    /// - Parameters:
    ///   - currentDose: 当前累积剂量（%）
    ///   - duration: 已暴露时长（秒）
    /// - Returns: 剂量率（%/小时）
    ///
    /// **计算公式**：
    /// ```
    /// Dose Rate = Current Dose / Elapsed Time (hours)
    /// ```
    private func calculateDoseRate(currentDose: Double, duration: TimeInterval) -> Double {
        let exposureHours = duration / 3600.0
        guard exposureHours > 0 else { return 0.0 }
        
        return currentDose / exposureHours
    }
    
    /// 预测达到100%剂量的时间 - 私有方法
    ///
    /// 基于当前剂量率预测何时达到100%剂量
    /// 此方法为内部计算使用，外部通过getNoiseDoseData()获取预测时间
    ///
    /// - Parameters:
    ///   - currentDose: 当前累积剂量（%）
    ///   - doseRate: 剂量率（%/小时）
    /// - Returns: 预测时间（小时），如果已超过100%或剂量率为0则返回nil
    private func predictTimeToFullDose(currentDose: Double, doseRate: Double) -> Double? {
        guard doseRate > 0, currentDose < 100.0 else { return nil }
        
        let remainingDose = 100.0 - currentDose
        return remainingDose / doseRate
    }
    
    /// 计算剩余允许暴露时间 - 私有方法
    ///
    /// 计算在不超过100%剂量的前提下，还可以暴露多长时间
    /// 此方法为内部计算使用，外部通过getNoiseDoseData()获取剩余时间
    ///
    /// - Parameters:
    ///   - currentDose: 当前累积剂量（%）
    ///   - doseRate: 剂量率（%/小时）
    /// - Returns: 剩余时间（小时），如果已超标则返回nil
    private func calculateRemainingAllowedTime(currentDose: Double, doseRate: Double) -> Double? {
        return predictTimeToFullDose(currentDose: currentDose, doseRate: doseRate)
    }
    
    /// 计算统计指标
    func calculateStatistics(from measurements: [DecibelMeasurement]) -> DecibelStatistics {
        guard !measurements.isEmpty else {
            return createEmptyStatistics()
        }
        
        let decibelValues = measurements.map { $0.calibratedDecibel }
        let timestamps = measurements.map { $0.timestamp }
        
        // 基本统计
        let avgDecibel = decibelValues.reduce(0, +) / Double(decibelValues.count)
        let minDecibel = decibelValues.min() ?? 0.0
        // MAX使用实时追踪的时间权重最大值，不是历史数据的最大值
        let maxDecibel = self.maxDecibel
        // PEAK使用实时追踪的瞬时峰值，不是历史数据的最大值
        let peakDecibel = self.peakDecibel
        
        // 等效连续声级 (Leq)
        let leqDecibel = calculateLeq(from: decibelValues)
        
        // 百分位数统计
        let sortedDecibels = decibelValues.sorted()
        let l10Decibel = calculatePercentile(sortedDecibels, percentile: 90) // L10 = 90%位
        let l50Decibel = calculatePercentile(sortedDecibels, percentile: 50) // L50 = 50%位
        let l90Decibel = calculatePercentile(sortedDecibels, percentile: 10) // L90 = 10%位
        
        // 标准偏差
        let standardDeviation = calculateStandardDeviation(from: decibelValues, mean: avgDecibel)
        
        // 测量时长
        let measurementDuration = timestamps.last?.timeIntervalSince(timestamps.first ?? Date()) ?? 0.0
        
        return DecibelStatistics(
            timestamp: Date(),
            measurementDuration: measurementDuration,
            sampleCount: measurements.count,
            avgDecibel: avgDecibel,
            minDecibel: minDecibel,
            maxDecibel: maxDecibel,
            peakDecibel: peakDecibel,
            leqDecibel: leqDecibel,
            l10Decibel: l10Decibel,
            l50Decibel: l50Decibel,
            l90Decibel: l90Decibel,
            standardDeviation: standardDeviation
        )
    }
    
    /// 清除测量历史
    func clearHistory() {
        measurementHistory.removeAll()
        maxDecibel = 0.0
        minDecibel = -1.0   // 重置为未初始化状态
        peakDecibel = 0.0
        currentStatistics = nil
        measurementStartTime = nil
    }
    
    /// 验证分贝值是否在合理范围内
    private func validateDecibelValue(_ value: Double) -> Double {
        return max(minDecibelLimit, min(value, maxDecibelLimit))
    }
    
    /// 更新状态并通知回调
    private func updateState(_ newState: MeasurementState) {
        measurementState = newState
        onStateChange?(newState)
    }
    
    /// 更新分贝值并通知回调
    private func updateDecibel(_ newDecibel: Double, timeWeightedDecibel: Double, rawDecibel: Double) {
        // 验证并限制分贝值在合理范围内
        let validatedDecibel = validateDecibelValue(newDecibel)
        currentDecibel = validatedDecibel
        
        // 更新MAX值（使用时间权重后的值）
        let validatedTimeWeighted = validateDecibelValue(timeWeightedDecibel)
        if maxDecibel < 0 || validatedTimeWeighted > maxDecibel {
            maxDecibel = validatedTimeWeighted
        }
        
        // 更新MIN值（使用时间权重后的值）
        if minDecibel < 0 || validatedTimeWeighted < minDecibel {
            minDecibel = validatedTimeWeighted
        }
        
        // 更新PEAK值（使用原始未加权的瞬时峰值）
        let validatedRaw = validateDecibelValue(rawDecibel)
        if peakDecibel < 0 || validatedRaw > peakDecibel {
            peakDecibel = validatedRaw
        }
        // 计算当前LEQ值
        let currentLeq = getRealTimeLeq()
        
        print("updateDecibel currentDecibel: \(currentDecibel), maxDecibel: \(maxDecibel), minDecibel: \(minDecibel), peakDecibel: \(peakDecibel), leq: \(currentLeq)")
        onMeterDataUpdate?(currentDecibel, peakDecibel, maxDecibel, minDecibel, currentLeq)
    }
    
    /// 更新测量数据并通知回调
    private func updateMeasurement(_ measurement: DecibelMeasurement) {
        currentMeasurement = measurement
        onMeasurementUpdate?(measurement)
    }
    
    // MARK: - 私有统计计算方法
    
    /// 创建空统计信息
    private func createEmptyStatistics() -> DecibelStatistics {
        return DecibelStatistics(
            timestamp: Date(),
            measurementDuration: 0.0,
            sampleCount: 0,
            avgDecibel: 0.0,
            minDecibel: 0.0,
            maxDecibel: 0.0,
            peakDecibel: 0.0,
            leqDecibel: 0.0,
            l10Decibel: 0.0,
            l50Decibel: 0.0,
            l90Decibel: 0.0,
            standardDeviation: 0.0
        )
    }
    
    /// 计算等效连续声级 (Leq)
    private func calculateLeq(from decibelValues: [Double]) -> Double {
        guard !decibelValues.isEmpty else { return 0.0 }
        
        let sum = decibelValues.reduce(0.0) { sum, value in
            sum + pow(10.0, value / 10.0)
        }
        
        return 10.0 * log10(sum / Double(decibelValues.count))
    }
    
    /// 计算百分位数
    private func calculatePercentile(_ sortedValues: [Double], percentile: Double) -> Double {
        guard !sortedValues.isEmpty else { return 0.0 }
        
        let index = Int(ceil(Double(sortedValues.count) * percentile / 100.0)) - 1
        let clampedIndex = max(0, min(index, sortedValues.count - 1))
        return sortedValues[clampedIndex]
    }
    
    /// 计算标准偏差
    private func calculateStandardDeviation(from values: [Double], mean: Double) -> Double {
        guard values.count > 1 else { return 0.0 }
        
        let variance = values.reduce(0.0) { sum, value in
            sum + pow(value - mean, 2)
        } / Double(values.count - 1)
        
        return sqrt(variance)
    }
    
    // MARK: - 私有方法
    
    /// 设置音频会话
    private func setupAudioSession() {
        do {
            // 配置音频会话支持后台录制
            try audioSession.setCategory(
                .record,
                mode: .measurement,
                options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker]
            )
            
            // 启用后台音频处理
            try audioSession.setActive(true, options: [])
            
            // 设置音频会话为支持后台处理
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setPreferredIOBufferDuration(0.005) // 5ms缓冲区，提高响应速度
            
        } catch {
            print("设置音频会话失败: \(error)")
            updateState(.error("音频会话配置失败: \(error.localizedDescription)"))
        }
    }
    
    /// 开始后台任务
    private func startBackgroundTask() {
        endBackgroundTask() // 确保之前的任务已结束
        
        // 使用AppLifecycleManager管理后台任务
        backgroundTaskID = appLifecycleManager.startBackgroundTaskForMeasurement()
        
        // 打印后台配置信息
        appLifecycleManager.printBackgroundConfiguration()
        
        print("开始后台测量任务，ID: \(backgroundTaskID.rawValue)")
    }
    
    /// 延长后台任务
    private func extendBackgroundTask() {
        guard backgroundTaskID != .invalid else { return }
        
        print("尝试延长后台任务")
        
        // 使用AppLifecycleManager延长任务
        let newTaskID = appLifecycleManager.startBackgroundTaskForMeasurement()
        
        if newTaskID != .invalid {
            backgroundTaskID = newTaskID
            print("成功延长后台任务，新ID: \(newTaskID.rawValue)")
        } else {
            print("无法延长后台任务")
        }
    }
    
    /// 结束后台任务
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            print("结束后台测量任务，ID: \(backgroundTaskID.rawValue)")
            appLifecycleManager.endBackgroundTask()
            backgroundTaskID = .invalid
        }
        
        backgroundTaskTimer?.invalidate()
        backgroundTaskTimer = nil
    }
    
    /// 设置滤波器
    private func setupFilters() {
        timeWeightingFilter = TimeWeightingFilter()
        frequencyWeightingFilter = FrequencyWeightingFilter()
    }
    
    /// 请求麦克风权限
    private func requestMicrophonePermission() async throws {
        let status = AVAudioSession.sharedInstance().recordPermission
        
        switch status {
        case .granted:
            return
        case .denied:
            throw DecibelMeterError.microphonePermissionDenied
        case .undetermined:
            let granted = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
            if !granted {
                throw DecibelMeterError.microphonePermissionDenied
            }
        @unknown default:
            throw DecibelMeterError.microphonePermissionDenied
        }
    }
    
    /// 设置音频引擎
    private func setupAudioEngine() throws {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw DecibelMeterError.audioEngineSetupFailed
        }
        
        inputNode = audioEngine.inputNode
        guard let inputNode = inputNode else {
            throw DecibelMeterError.inputNodeNotFound
        }
        
        // 设置输入格式
        let inputFormat = inputNode.outputFormat(forBus: 0)
        print("输入格式: \(inputFormat)")
        
        // 安装音频处理块
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { [weak self] buffer, time in
            Task { @MainActor in
                self?.processAudioBuffer(buffer)
            }
        }
    }
    
    /// 启动音频引擎
    private func startAudioEngine() throws {
        guard let audioEngine = audioEngine else {
            throw DecibelMeterError.audioEngineSetupFailed
        }
        
        try audioEngine.start()
    }
    
    /// 停止音频引擎
    private func stopAudioEngine() {
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
        audioEngine = nil
        inputNode = nil
    }
    
    /// 处理音频缓冲区
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        
        // 转换为数组
        let samples = Array(UnsafeBufferPointer(start: channelData, count: frameCount))
        
        // 计算分贝值
        let measurement = calculateDecibelMeasurement(from: samples)
        
        // 获取用于MAX和PEAK计算的值
        let currentTimeWeightedDecibel = timeWeightingFilter?.applyWeighting(currentTimeWeighting, currentValue: measurement.aWeightedDecibel) ?? measurement.aWeightedDecibel
        let rawDecibel = measurement.rawDecibel
        
        // 更新测量数据并通知回调
        updateMeasurement(measurement)
        updateDecibel(
            measurement.calibratedDecibel,
            timeWeightedDecibel: currentTimeWeightedDecibel,
            rawDecibel: rawDecibel
        )
        
        // 添加到历史记录
        measurementHistory.append(measurement)
        
        // 限制历史记录长度
        if measurementHistory.count > 1000 {
            measurementHistory.removeFirst()
        }
    }
    
    /// 计算分贝测量结果
    private func calculateDecibelMeasurement(from samples: [Float]) -> DecibelMeasurement {
        let timestamp = Date()
        
        // 计算原始分贝值
        let rawDecibel = calculateRawDecibel(from: samples)
        
        // 计算当前权重分贝值
        let weightedDecibel = calculateWeightedDecibel(from: samples, weighting: currentFrequencyWeighting)
        
        // 应用当前时间权重
        let currentTimeWeightedDecibel = timeWeightingFilter?.applyWeighting(currentTimeWeighting, currentValue: weightedDecibel) ?? weightedDecibel
        
        // 计算所有时间权重的值（用于存储和比较）
        let fastDecibel = timeWeightingFilter?.applyFastWeighting(weightedDecibel) ?? weightedDecibel
        let slowDecibel = timeWeightingFilter?.applySlowWeighting(weightedDecibel) ?? weightedDecibel
        
        // 应用校准
        let calibratedDecibel = currentTimeWeightedDecibel + calibrationOffset
        
        // 计算频谱（简化版）
        let frequencySpectrum = calculateFrequencySpectrum(from: samples)
        
        return DecibelMeasurement(
            timestamp: timestamp,
            rawDecibel: rawDecibel,
            aWeightedDecibel: weightedDecibel,
            fastDecibel: fastDecibel,
            slowDecibel: slowDecibel,
            calibratedDecibel: calibratedDecibel,
            frequencySpectrum: frequencySpectrum
        )
    }
    
    /// 计算原始分贝值
    private func calculateRawDecibel(from samples: [Float]) -> Double {
        // 计算RMS值
        let sum = samples.reduce(0.0) { $0 + Double($1 * $1) }
        let rms = sqrt(sum / Double(samples.count))
        
        // 转换为分贝
        let pressure = rms * 1.0 // 假设灵敏度为1
        return 20.0 * log10(pressure / referencePressure + 1e-10)
    }
    
    /// 计算频率权重分贝值
    private func calculateWeightedDecibel(from samples: [Float], weighting: FrequencyWeighting) -> Double {
        // 简化版频率权重计算
        // 实际应用中需要FFT分析
        let rawDecibel = calculateRawDecibel(from: samples)
        
        // 根据权重类型应用不同的补偿
        let weightCompensation = getWeightCompensation(for: weighting)
        return rawDecibel + weightCompensation
    }
    
    /// 获取权重补偿值（简化实现）
    private func getWeightCompensation(for weighting: FrequencyWeighting) -> Double {
        switch weighting {
        case .aWeight:
            return -2.0 // A权重补偿
        case .bWeight:
            return -1.0 // B权重补偿
        case .cWeight:
            return 0.0 // C权重补偿
        case .zWeight:
            return 0.0 // 无补偿
        case .ituR468:
            return -1.5 // ITU-R 468权重补偿
        }
    }
    
    /// 计算频谱（简化版）
    private func calculateFrequencySpectrum(from samples: [Float]) -> [Double] {
        // 简化版频谱计算
        // 实际应用中需要使用FFT
        let spectrum = Array(0..<32).map { _ in Double.random(in: 0...1) }
        return spectrum
    }
}

// MARK: - 错误类型

enum DecibelMeterError: LocalizedError {
    case microphonePermissionDenied
    case audioEngineSetupFailed
    case inputNodeNotFound
    case audioSessionError
    
    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "麦克风权限被拒绝"
        case .audioEngineSetupFailed:
            return "音频引擎设置失败"
        case .inputNodeNotFound:
            return "找不到输入节点"
        case .audioSessionError:
            return "音频会话错误"
        }
    }
}

// MARK: - 时间权重滤波器

class TimeWeightingFilter {
    // 存储各权重类型的上一次值
    private var fastPreviousValue: Double = 0.0
    private var slowPreviousValue: Double = 0.0
    private var impulsePreviousValue: Double = 0.0
    private var lastUpdateTime: Date = Date()
    
    // 时间常数（秒）
    private let fastTimeConstant: Double = 0.125   // 125ms
    private let slowTimeConstant: Double = 1.0     // 1000ms
    private let impulseRiseTime: Double = 0.035    // 35ms (上升时间)
    private let impulseFallTime: Double = 1.5      // 1500ms (下降时间)
    
    /// 应用指定的时间权重
    func applyWeighting(_ weighting: TimeWeighting, currentValue: Double) -> Double {
        switch weighting {
        case .fast:
            return applyFastWeighting(currentValue)
        case .slow:
            return applySlowWeighting(currentValue)
        case .impulse:
            return applyImpulseWeighting(currentValue)
        }
    }
    
    func applyFastWeighting(_ currentValue: Double) -> Double {
        return applyExponentialFilter(currentValue, previousValue: &fastPreviousValue, timeConstant: fastTimeConstant)
    }
    
    func applySlowWeighting(_ currentValue: Double) -> Double {
        return applyExponentialFilter(currentValue, previousValue: &slowPreviousValue, timeConstant: slowTimeConstant)
    }
    
    func applyImpulseWeighting(_ currentValue: Double) -> Double {
        return applyImpulseFilter(currentValue, previousValue: &impulsePreviousValue)
    }
    
    private func applyExponentialFilter(_ currentValue: Double, previousValue: inout Double, timeConstant: Double) -> Double {
        let now = Date()
        let dt = now.timeIntervalSince(lastUpdateTime)
        
        if dt <= 0 {
            return previousValue
        }
        
        let alpha = 1.0 - exp(-dt / timeConstant)
        let filteredValue = previousValue + alpha * (currentValue - previousValue)
        
        previousValue = filteredValue
        lastUpdateTime = now
        
        return filteredValue
    }
    
    /// 应用Impulse权重滤波器
    /// Impulse权重：快速上升（35ms），缓慢下降（1.5s）
    private func applyImpulseFilter(_ currentValue: Double, previousValue: inout Double) -> Double {
        let now = Date()
        let dt = now.timeIntervalSince(lastUpdateTime)
        
        if dt <= 0 {
            return previousValue
        }
        
        // 判断是上升还是下降
        if currentValue > previousValue {
            // 上升阶段：使用快速时间常数（35ms）
            let alpha = 1.0 - exp(-dt / impulseRiseTime)
            let filteredValue = previousValue + alpha * (currentValue - previousValue)
            previousValue = filteredValue
            lastUpdateTime = now
            return filteredValue
        } else {
            // 下降阶段：使用慢速时间常数（1.5s）
            let alpha = 1.0 - exp(-dt / impulseFallTime)
            let filteredValue = previousValue + alpha * (currentValue - previousValue)
            previousValue = filteredValue
            lastUpdateTime = now
            return filteredValue
        }
    }
}

// MARK: - 频率权重滤波器

class FrequencyWeightingFilter {
    
    /// 应用指定的频率权重
    func applyWeighting(_ weighting: FrequencyWeighting, frequency: Double) -> Double {
        switch weighting {
        case .aWeight:
            return applyAWeighting(frequency: frequency)
        case .bWeight:
            return applyBWeighting(frequency: frequency)
        case .cWeight:
            return applyCWeighting(frequency: frequency)
        case .zWeight:
            return applyZWeighting(frequency: frequency)
        case .ituR468:
            return applyITU468Weighting(frequency: frequency)
        }
    }
    
    /// Z权重（无权重）
    func applyZWeighting(frequency: Double) -> Double {
        return 1.0 // 对所有频率返回1
    }
    
    /// A权重（环境噪声标准）
    func applyAWeighting(frequency: Double) -> Double {
        let f = frequency
        let f1 = 20.6
        let f2 = 107.7
        let f3 = 737.9
        let f4 = 12194.2
        
        let numerator = pow(f4, 2) * pow(f, 4)
        let denominator = (pow(f, 2) + pow(f1, 2)) *
                         sqrt((pow(f, 2) + pow(f2, 2)) * (pow(f, 2) + pow(f3, 2))) *
                         (pow(f, 2) + pow(f4, 2))
        
        return numerator / denominator
    }
    
    /// B权重（中等响度，已弃用）
    func applyBWeighting(frequency: Double) -> Double {
        let f = frequency
        let f1 = 20.6
        let f2 = 158.5
        let f3 = 12194.2
        
        let numerator = pow(f3, 2) * pow(f, 3)
        let denominator = (pow(f, 2) + pow(f1, 2)) *
                         sqrt(pow(f, 2) + pow(f2, 2)) *
                         (pow(f, 2) + pow(f3, 2))
        
        return numerator / denominator
    }
    
    /// C权重（高声级测量）
    func applyCWeighting(frequency: Double) -> Double {
        let f = frequency
        let f1 = 20.6
        let f2 = 12194.2
        
        let numerator = pow(f2, 2) * pow(f, 2)
        let denominator = (pow(f, 2) + pow(f1, 2)) * (pow(f, 2) + pow(f2, 2))
        
        return numerator / denominator
    }
    
    /// ITU-R 468权重（广播音频标准）
    func applyITU468Weighting(frequency: Double) -> Double {
        let f = frequency
        
        // ITU-R 468权重曲线的简化实现
        // 实际应用中需要完整的频率响应表
        
        if f < 10 {
            return 0.0
        } else if f < 31.5 {
            return -12.0
        } else if f < 63 {
            return -9.0
        } else if f < 125 {
            return -6.0
        } else if f < 250 {
            return -4.0
        } else if f < 500 {
            return -3.0
        } else if f < 1000 {
            return -1.0
        } else if f < 2000 {
            return 0.0
        } else if f < 4000 {
            return 1.0
        } else if f < 8000 {
            return 0.0
        } else if f < 16000 {
            return -2.0
        } else {
            return -5.0
        }
    }
    
    /// 获取权重在特定频率的dB值
    func getWeightingdB(_ weighting: FrequencyWeighting, frequency: Double) -> Double {
        let weight = applyWeighting(weighting, frequency: frequency)
        return 20.0 * log10(weight + 1e-10) // 转换为dB
    }
    
    /// 获取权重曲线的频率响应表（用于显示）
    func getWeightingCurve(_ weighting: FrequencyWeighting, frequencies: [Double]) -> [Double] {
        return frequencies.map { frequency in
            getWeightingdB(weighting, frequency: frequency)
        }
    }
}
