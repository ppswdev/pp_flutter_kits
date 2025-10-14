//
//  DecibelDataModels.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//
//  本文件定义了分贝测量仪的基础数据模型
//  包括测量结果、统计指标、测量会话、校准配置和导出配置
//

import Foundation

// MARK: - 测量结果数据模型

/// 分贝测量结果
///
/// 表示单次分贝测量的完整结果，包含原始值、各种权重值、校准值和频谱数据
/// 这是最基础的数据单元，每次音频缓冲区处理都会生成一个测量结果
///
/// **符合标准**：IEC 61672-1
struct DecibelMeasurement: Codable, Identifiable {
    /// 唯一标识符
    let id = UUID()
    
    /// 测量时间戳
    let timestamp: Date
    
    /// 原始分贝值（dB），未应用任何权重
    let rawDecibel: Double
    
    /// A权重分贝值（dB），应用A权重后的值
    let aWeightedDecibel: Double
    
    /// Fast时间权重分贝值（dB）
    let fastDecibel: Double
    
    /// Slow时间权重分贝值（dB）
    let slowDecibel: Double
    
    /// 校准后的分贝值（dB），应用了频率权重、时间权重和校准偏移
    let calibratedDecibel: Double
    
    /// 频率频谱数据数组，用于频谱分析图
    let frequencySpectrum: [Double]
    
    /// 获取主要显示的分贝值
    var displayDecibel: Double {
        return calibratedDecibel
    }
    
    /// 获取分贝等级描述
    var levelDescription: String {
        switch calibratedDecibel {
        case 0..<30:
            return "极安静"
        case 30..<40:
            return "安静"
        case 40..<50:
            return "较安静"
        case 50..<60:
            return "正常"
        case 60..<70:
            return "较吵闹"
        case 70..<80:
            return "吵闹"
        case 80..<90:
            return "很吵闹"
        case 90..<100:
            return "极吵闹"
        case 100..<110:
            return "危险"
        case 110...:
            return "极危险"
        default:
            return "未知"
        }
    }
    
    /// 获取分贝等级颜色
    var levelColor: String {
        switch calibratedDecibel {
        case 0..<50:
            return "green"
        case 50..<70:
            return "yellow"
        case 70..<85:
            return "orange"
        case 85..<100:
            return "red"
        case 100...:
            return "purple"
        default:
            return "gray"
        }
    }
}

// MARK: - 统计指标数据模型

/// 分贝统计指标
///
/// 包含完整的统计分析结果，用于评估噪声特性和暴露水平
/// 符合 ISO 1996-1 和 IEC 61672-1 标准的统计分析要求
///
/// **包含的指标**：
/// - 基本统计：AVG、MIN、MAX、PEAK
/// - 等效连续声级：LEQ
/// - 百分位数：L10、L50、L90
/// - 标准偏差
struct DecibelStatistics: Codable, Identifiable {
    /// 唯一标识符
    let id = UUID()
    
    /// 统计生成时间戳
    let timestamp: Date
    
    /// 测量持续时间（秒）
    let measurementDuration: TimeInterval
    
    /// 样本数量（测量次数）
    let sampleCount: Int
    
    // MARK: 基本统计指标
    
    /// AVG - 算术平均值（dB）
    let avgDecibel: Double
    
    /// MIN - 最小值（dB），应用时间权重
    let minDecibel: Double
    
    /// MAX - 最大值（dB），应用时间权重
    let maxDecibel: Double
    
    /// PEAK - 峰值（dB），不应用时间权重，表示瞬时峰值
    let peakDecibel: Double
    
    // MARK: 等效连续声级
    
    /// Leq - 等效连续声级（dB），能量平均值，符合ISO 1996-1标准
    let leqDecibel: Double
    
    // MARK: 百分位数统计
    
    /// L10 - 超过10%时间的声级（dB），表示噪声峰值特征
    let l10Decibel: Double
    
    /// L50 - 超过50%时间的声级（dB），即中位数
    let l50Decibel: Double
    
    /// L90 - 超过90%时间的声级（dB），表示背景噪声水平
    let l90Decibel: Double
    
    // MARK: 标准偏差
    
    /// 标准偏差（dB），表示数据的离散程度
    let standardDeviation: Double
    
    /// 获取统计摘要
    var summary: String {
        return String(format: "AVG: %.1f dB | MIN: %.1f dB | MAX: %.1f dB | PEAK: %.1f dB", 
                     avgDecibel, minDecibel, maxDecibel, peakDecibel)
    }
    
    /// 获取详细统计信息
    var detailedSummary: String {
        return String(format: """
        AVG: %.1f dB | MIN: %.1f dB | MAX: %.1f dB | PEAK: %.1f dB
        Leq: %.1f dB | L10: %.1f dB | L50: %.1f dB | L90: %.1f dB
        标准差: %.1f dB | 样本数: %d | 时长: %.1fs
        """, avgDecibel, minDecibel, maxDecibel, peakDecibel,
             leqDecibel, l10Decibel, l50Decibel, l90Decibel,
             standardDeviation, sampleCount, measurementDuration)
    }
}

// MARK: - 测量会话数据模型

/// 测量会话
struct MeasurementSession: Codable, Identifiable {
    let id = UUID()
    let startTime: Date
    var endTime: Date?
    var measurements: [DecibelMeasurement] = []
    let sessionName: String
    
    /// 会话持续时间（秒）
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    /// 平均分贝值
    var averageDecibel: Double {
        guard !measurements.isEmpty else { return 0.0 }
        let sum = measurements.reduce(0.0) { $0 + $1.calibratedDecibel }
        return sum / Double(measurements.count)
    }
    
    /// 最大分贝值
    var maxDecibel: Double {
        return measurements.map { $0.calibratedDecibel }.max() ?? 0.0
    }
    
    /// 最小分贝值
    var minDecibel: Double {
        return measurements.map { $0.calibratedDecibel }.min() ?? 0.0
    }
    
    /// 等效连续声级（Leq）
    var leq: Double {
        guard !measurements.isEmpty else { return 0.0 }
        let sum = measurements.reduce(0.0) { result, measurement in
            result + pow(10.0, measurement.calibratedDecibel / 10.0)
        }
        return 10.0 * log10(sum / Double(measurements.count))
    }
    
    /// 时间加权平均值（TWA）
    var twa: Double {
        return leq // 简化计算，实际应用中需要考虑时间权重
    }
    
    /// 噪声剂量百分比
    var noiseDose: Double {
        let threshold = 85.0 // 85 dB基准
        let dose = pow(2.0, (twa - threshold) / 5.0) * 100.0
        return min(dose, 100.0)
    }
}

// MARK: - 统计数据分析模型

/// 统计分析结果
struct StatisticalAnalysis: Codable {
    let sessionId: UUID
    let analysisTime: Date
    let totalMeasurements: Int
    let averageDecibel: Double
    let maxDecibel: Double
    let minDecibel: Double
    let leq: Double
    let twa: Double
    let noiseDose: Double
    let l10: Double // 超过10%时间的声级
    let l50: Double // 超过50%时间的声级（中位数）
    let l90: Double // 超过90%时间的声级
    
    /// 创建统计分析
    static func create(from session: MeasurementSession) -> StatisticalAnalysis {
        let decibelValues = session.measurements.map { $0.calibratedDecibel }.sorted()
        let count = decibelValues.count
        
        let l10Index = Int(Double(count) * 0.9)
        let l50Index = Int(Double(count) * 0.5)
        let l90Index = Int(Double(count) * 0.1)
        
        return StatisticalAnalysis(
            sessionId: session.id,
            analysisTime: Date(),
            totalMeasurements: count,
            averageDecibel: session.averageDecibel,
            maxDecibel: session.maxDecibel,
            minDecibel: session.minDecibel,
            leq: session.leq,
            twa: session.twa,
            noiseDose: session.noiseDose,
            l10: count > l10Index ? decibelValues[l10Index] : 0.0,
            l50: count > l50Index ? decibelValues[l50Index] : 0.0,
            l90: count > l90Index ? decibelValues[l90Index] : 0.0
        )
    }
}

// MARK: - 校准数据模型

/// 校准点
struct CalibrationPoint: Codable, Identifiable {
    let id = UUID()
    let frequency: Double
    let referenceLevel: Double
    let measuredLevel: Double
    let compensation: Double
    let timestamp: Date
    
    init(frequency: Double, referenceLevel: Double, measuredLevel: Double) {
        self.frequency = frequency
        self.referenceLevel = referenceLevel
        self.measuredLevel = measuredLevel
        self.compensation = referenceLevel - measuredLevel
        self.timestamp = Date()
    }
}

/// 校准配置
struct CalibrationConfig: Codable {
    var calibrationPoints: [CalibrationPoint] = []
    var globalOffset: Double = 0.0
    var isCalibrated: Bool = false
    var calibrationDate: Date?
    
    /// 获取指定频率的补偿值
    func getCompensation(for frequency: Double) -> Double {
        // 如果没有校准点，返回全局偏移
        guard !calibrationPoints.isEmpty else {
            return globalOffset
        }
        
        // 找到最接近的频率点
        let closestPoint = calibrationPoints.min { point1, point2 in
            abs(point1.frequency - frequency) < abs(point2.frequency - frequency)
        }
        
        return closestPoint?.compensation ?? globalOffset
    }
    
    /// 添加校准点
    mutating func addCalibrationPoint(_ point: CalibrationPoint) {
        // 移除相同频率的旧点
        calibrationPoints.removeAll { $0.frequency == point.frequency }
        calibrationPoints.append(point)
        
        // 按频率排序
        calibrationPoints.sort { $0.frequency < $1.frequency }
        
        isCalibrated = true
        calibrationDate = Date()
    }
}

// MARK: - 导出数据模型

/// 导出格式
enum ExportFormat: String, CaseIterable, Codable {
    case json = "JSON"
    case csv = "CSV"
    case excel = "Excel"
}

/// 导出配置
struct ExportConfig: Codable {
    let format: ExportFormat
    let includeRawData: Bool
    let includeStatistics: Bool
    let includeCalibration: Bool
    let dateRange: DateInterval?
    let sessionIds: [UUID]?
    
    init(format: ExportFormat, 
         includeRawData: Bool = true,
         includeStatistics: Bool = true,
         includeCalibration: Bool = false,
         dateRange: DateInterval? = nil,
         sessionIds: [UUID]? = nil) {
        self.format = format
        self.includeRawData = includeRawData
        self.includeStatistics = includeStatistics
        self.includeCalibration = includeCalibration
        self.dateRange = dateRange
        self.sessionIds = sessionIds
    }
}


// MARK: - 扩展方法

extension DecibelMeasurement {
    /// 转换为CSV格式
    func toCSV() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        return [
            formatter.string(from: timestamp),
            String(format: "%.2f", rawDecibel),
            String(format: "%.2f", aWeightedDecibel),
            String(format: "%.2f", fastDecibel),
            String(format: "%.2f", slowDecibel),
            String(format: "%.2f", calibratedDecibel),
            levelDescription
        ].joined(separator: ",")
    }
    
    /// CSV标题行
    static func csvHeader() -> String {
        return "时间,原始分贝,A权重分贝,快权重分贝,慢权重分贝,校准分贝,等级描述"
    }
    
    /// 转换为Map格式
    func toMap() -> [String: Any] {
        return [
            "id": id.uuidString,
            "timestamp": timestamp.timeIntervalSince1970 * 1000, // 转换为毫秒
            "rawDecibel": rawDecibel,
            "aWeightedDecibel": aWeightedDecibel,
            "fastDecibel": fastDecibel,
            "slowDecibel": slowDecibel,
            "calibratedDecibel": calibratedDecibel,
            "frequencySpectrum": frequencySpectrum,
            "displayDecibel": displayDecibel,
            "levelDescription": levelDescription,
            "levelColor": levelColor
        ]
    }
}

extension MeasurementSession {
    /// 转换为CSV格式
    func toCSV() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return [
            sessionName,
            formatter.string(from: startTime),
            endTime != nil ? formatter.string(from: endTime!) : "",
            String(format: "%.1f", duration),
            String(format: "%.2f", averageDecibel),
            String(format: "%.2f", maxDecibel),
            String(format: "%.2f", minDecibel),
            String(format: "%.2f", leq),
            String(format: "%.2f", twa),
            String(format: "%.1f", noiseDose)
        ].joined(separator: ",")
    }
    
    /// 会话CSV标题行
    static func csvHeader() -> String {
        return "会话名称,开始时间,结束时间,持续时间(秒),平均分贝,最大分贝,最小分贝,Leq,TWA,噪声剂量(%)"
    }
}

