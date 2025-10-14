//
//  NoiseDosimeterModels.swift
//  DecibelMeterDemo
//
//  Created by AI Assistant on 2025/1/23.
//
//  本文件定义了噪音测量计（Noise Dosimeter）专用的数据模型
//  包括噪声剂量、TWA、限值标准、剂量累积图等
//  符合 OSHA、NIOSH、GBZ、EU 标准
//

import Foundation

// MARK: - 噪声限值标准

/// 噪声限值标准
///
/// 定义不同国家和地区的职业噪声暴露限值标准
/// 包括TWA限值、交换率、参考声级等参数
///
/// **支持的标准**：
/// - OSHA（美国职业安全健康管理局）
/// - NIOSH（美国国家职业安全健康研究所）
/// - GBZ（中国职业卫生标准）
/// - EU（欧盟标准）
enum NoiseStandard: String, CaseIterable, Codable {
    /// OSHA标准：90 dB(A) TWA限值，5 dB交换率
    case osha = "OSHA"
    
    /// NIOSH标准：85 dB(A) TWA限值，3 dB交换率（推荐标准）
    case niosh = "NIOSH"
    
    /// GBZ标准：85 dB(A) TWA限值，3 dB交换率（中国标准）
    case gbz = "GBZ"
    
    /// EU标准：87 dB(A) TWA限值，3 dB交换率（欧盟标准）
    case eu = "EU"
    
    /// 获取TWA限值（dB）
    var twaLimit: Double {
        switch self {
        case .osha:
            return 90.0
        case .niosh:
            return 85.0
        case .gbz:
            return 85.0
        case .eu:
            return 87.0
        }
    }
    
    /// 获取交换率（dB）
    ///
    /// 交换率定义：声级每增加一定dB，允许暴露时间减半
    var exchangeRate: Double {
        switch self {
        case .osha:
            return 5.0  // OSHA使用5dB交换率
        case .niosh:
            return 3.0  // NIOSH使用3dB交换率（更保守）
        case .gbz:
            return 3.0  // GBZ使用3dB交换率
        case .eu:
            return 3.0  // EU使用3dB交换率
        }
    }
    
    /// 获取参考声级（dB）
    ///
    /// 参考声级是计算剂量的基准，100%剂量对应的声级
    var criterionLevel: Double {
        return 85.0  // 所有标准都使用85dB作为参考声级
    }
    
    /// 获取峰值限值（dB）
    var peakLimit: Double {
        return 140.0  // 所有标准都使用140dB作为峰值限值
    }
    
    /// 获取行动值（dB）
    ///
    /// 行动值是需要采取听力保护措施的触发点
    var actionLevel: Double {
        switch self {
        case .osha:
            return 85.0  // OSHA行动值
        case .niosh:
            return 85.0  // NIOSH推荐值即为限值
        case .gbz:
            return 85.0  // GBZ限值
        case .eu:
            return 80.0  // EU下行动值
        }
    }
    
    /// 获取标准的完整名称
    var fullName: String {
        switch self {
        case .osha:
            return "OSHA 29 CFR 1910.95"
        case .niosh:
            return "NIOSH REL"
        case .gbz:
            return "GBZ 2.2-2007"
        case .eu:
            return "EU Directive 2003/10/EC"
        }
    }
    
    /// 获取标准描述
    var description: String {
        switch self {
        case .osha:
            return "美国职业安全健康管理局标准"
        case .niosh:
            return "美国国家职业安全健康研究所推荐标准"
        case .gbz:
            return "中国职业卫生标准"
        case .eu:
            return "欧盟职业噪声暴露标准"
        }
    }
}

// MARK: - 噪声剂量数据

/// 噪声剂量数据
///
/// 包含噪声剂量的完整计算结果
/// 符合 OSHA、NIOSH、GBZ 标准的剂量计算要求
struct NoiseDoseData: Codable {
    /// 噪声剂量百分比（%）
    let dosePercentage: Double
    
    /// 剂量率（%/小时）
    let doseRate: Double
    
    /// TWA值（dB）
    let twa: Double
    
    /// 测量时长（小时）
    let duration: Double
    
    /// 使用的标准
    let standard: NoiseStandard
    
    /// 是否超过限值
    let isExceeding: Bool
    
    /// 距离限值的余量（dB）
    let limitMargin: Double
    
    /// 预测达到100%剂量的时间（小时），nil表示不会达到
    let predictedTimeToFullDose: Double?
    
    /// 剩余允许暴露时间（小时），nil表示已超标
    let remainingAllowedTime: Double?
    
    /// 风险等级
    let riskLevel: RiskLevel
    
    /// 转换为JSON字符串
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// 从JSON字符串创建
    static func fromJSON(_ jsonString: String) -> NoiseDoseData? {
        let decoder = JSONDecoder()
        
        guard let data = jsonString.data(using: .utf8),
              let doseData = try? decoder.decode(NoiseDoseData.self, from: data) else {
            return nil
        }
        return doseData
    }
    
    /// 转换为Map格式
    func toMap() -> [String: Any] {
        return [
            "dosePercentage": dosePercentage,
            "doseRate": doseRate,
            "twa": twa,
            "duration": duration,
            "standard": standard.rawValue,
            "isExceeding": isExceeding,
            "limitMargin": limitMargin,
            "predictedTimeToFullDose": predictedTimeToFullDose as Any,
            "remainingAllowedTime": remainingAllowedTime as Any,
            "riskLevel": riskLevel.rawValue
        ]
    }
}

/// 风险等级
enum RiskLevel: String, Codable {
    case safe = "安全"           // 0-50%剂量
    case acceptable = "可接受"   // 50-100%剂量
    case exceeding = "超标"      // 100-200%剂量
    case dangerous = "严重超标"  // >200%剂量
    
    /// 根据剂量百分比判断风险等级
    static func from(dosePercentage: Double) -> RiskLevel {
        switch dosePercentage {
        case 0..<50:
            return .safe
        case 50..<100:
            return .acceptable
        case 100..<200:
            return .exceeding
        default:
            return .dangerous
        }
    }
    
    /// 获取风险等级的颜色（用于UI显示）
    var colorName: String {
        switch self {
        case .safe:
            return "green"
        case .acceptable:
            return "yellow"
        case .exceeding:
            return "orange"
        case .dangerous:
            return "red"
        }
    }
}

// MARK: - 剂量累积图数据

/// 剂量累积数据点
///
/// 表示剂量随时间累积的单个数据点
struct DoseAccumulationPoint: Codable, Identifiable {
    /// 唯一标识符
    let id = UUID()
    
    /// 时间戳
    let timestamp: Date
    
    /// 累积剂量百分比（%）
    let cumulativeDose: Double
    
    /// 当前TWA值（dB）
    let currentTWA: Double
    
    /// 暴露时长（小时）
    let exposureTime: Double
    
    enum CodingKeys: String, CodingKey {
        case timestamp, cumulativeDose, currentTWA, exposureTime
    }
}

/// 剂量累积图数据
///
/// 包含剂量随时间累积的完整数据，用于绘制剂量累积图
/// 符合 OSHA、NIOSH 标准的剂量监测要求
struct DoseAccumulationChartData: Codable {
    /// 所有累积数据点
    let dataPoints: [DoseAccumulationPoint]
    
    /// 当前累积剂量（%）
    let currentDose: Double
    
    /// 限值线（%），通常为100%
    let limitLine: Double
    
    /// 使用的标准
    let standard: NoiseStandard
    
    /// 总时间范围（小时）
    let timeRange: Double
    
    /// 图表标题
    let title: String
    
    /// 转换为JSON字符串
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// 从JSON字符串创建
    static func fromJSON(_ jsonString: String) -> DoseAccumulationChartData? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let data = jsonString.data(using: .utf8),
              let chartData = try? decoder.decode(DoseAccumulationChartData.self, from: data) else {
            return nil
        }
        return chartData
    }
}

// MARK: - TWA趋势图数据

/// TWA趋势数据点
///
/// 表示TWA随时间变化的单个数据点
struct TWATrendDataPoint: Codable, Identifiable {
    /// 唯一标识符
    let id = UUID()
    
    /// 时间戳
    let timestamp: Date
    
    /// 当前TWA值（dB）
    let twa: Double
    
    /// 暴露时长（小时）
    let exposureTime: Double
    
    /// 对应的剂量百分比（%）
    let dosePercentage: Double
    
    enum CodingKeys: String, CodingKey {
        case timestamp, twa, exposureTime, dosePercentage
    }
}

/// TWA趋势图数据
///
/// 包含TWA随时间变化的完整数据，用于绘制TWA趋势图
/// 符合职业健康监测要求
struct TWATrendChartData: Codable {
    /// 所有TWA数据点
    let dataPoints: [TWATrendDataPoint]
    
    /// 当前TWA值（dB）
    let currentTWA: Double
    
    /// TWA限值线（dB）
    let limitLine: Double
    
    /// 使用的标准
    let standard: NoiseStandard
    
    /// 总时间范围（小时）
    let timeRange: Double
    
    /// 图表标题
    let title: String
    
    /// 转换为JSON字符串
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// 从JSON字符串创建
    static func fromJSON(_ jsonString: String) -> TWATrendChartData? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let data = jsonString.data(using: .utf8),
              let chartData = try? decoder.decode(TWATrendChartData.self, from: data) else {
            return nil
        }
        return chartData
    }
}

// MARK: - 限值比较结果

/// 限值比较结果
///
/// 包含与特定标准限值的比较结果
struct LimitComparisonResult: Codable {
    /// 使用的标准
    let standard: NoiseStandard
    
    /// 当前TWA值（dB）
    let currentTWA: Double
    
    /// TWA限值（dB）
    let twaLimit: Double
    
    /// 当前剂量（%）
    let currentDose: Double
    
    /// 是否超过限值
    let isExceeding: Bool
    
    /// 是否达到行动值
    let isActionLevelReached: Bool
    
    /// 距离限值的余量（dB）
    let limitMargin: Double
    
    /// 距离限值的剂量余量（%）
    let doseMargin: Double
    
    /// 风险等级
    let riskLevel: RiskLevel
    
    /// 建议措施
    let recommendations: [String]
    
    /// 转换为JSON字符串
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// 从JSON字符串创建
    static func fromJSON(_ jsonString: String) -> LimitComparisonResult? {
        let decoder = JSONDecoder()
        
        guard let data = jsonString.data(using: .utf8),
              let result = try? decoder.decode(LimitComparisonResult.self, from: data) else {
            return nil
        }
        return result
    }
    
    /// 转换为Map格式
    func toMap() -> [String: Any] {
        return [
            "standard": standard.rawValue,
            "currentTWA": currentTWA,
            "twaLimit": twaLimit,
            "currentDose": currentDose,
            "isExceeding": isExceeding,
            "isActionLevelReached": isActionLevelReached,
            "limitMargin": limitMargin,
            "doseMargin": doseMargin,
            "riskLevel": riskLevel.rawValue,
            "recommendations": recommendations
        ]
    }
}

// MARK: - 噪音测量计综合报告

/// 噪音测量计综合报告
///
/// 包含噪音测量计的所有关键数据，用于生成完整的暴露评估报告
struct NoiseDosimeterReport: Codable {
    /// 报告生成时间
    let reportTime: Date
    
    /// 测量开始时间
    let measurementStartTime: Date
    
    /// 测量结束时间
    let measurementEndTime: Date
    
    /// 测量时长（小时）
    let measurementDuration: Double
    
    /// 使用的标准
    let standard: NoiseStandard
    
    /// 噪声剂量数据
    let doseData: NoiseDoseData
    
    /// 限值比较结果
    let comparisonResult: LimitComparisonResult
    
    /// LEQ值（dB）
    let leq: Double
    
    /// 统计指标
    let statistics: ReportStatistics
    
    /// 转换为JSON字符串
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// 从JSON字符串创建
    static func fromJSON(_ jsonString: String) -> NoiseDosimeterReport? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let data = jsonString.data(using: .utf8),
              let report = try? decoder.decode(NoiseDosimeterReport.self, from: data) else {
            return nil
        }
        return report
    }
}

/// 报告统计数据
struct ReportStatistics: Codable {
    let avg: Double
    let min: Double
    let max: Double
    let peak: Double
    let l10: Double
    let l50: Double
    let l90: Double
}

// MARK: - 允许暴露时长表

/// 允许暴露时长表项
///
/// 表示特定声级的暴露时长信息
/// 符合 NIOSH、OSHA、GBZ 标准的暴露时长计算要求
///
/// **属性说明**：
/// - `soundLevel`: 声级（dB）
/// - `allowedDuration`: 允许暴露时长（秒），根据标准计算
/// - `accumulatedDuration`: 累计达标时长（秒），实际测量中在该声级范围内的累计暴露时间
/// - `currentLevelDose`: 当前声级剂量百分比（%），计算公式：(累计时长 / 允许时长) × 100%
///
/// **计算公式**：
/// ```
/// 允许时长 = 8小时 × 2^((基准限值 - 声级) / 交换率)
/// 剂量 = (累计时长 / 允许时长) × 100%
/// ```
struct PermissibleExposureDuration: Codable, Identifiable {
    /// 唯一标识符
    let id = UUID()
    
    /// 声级（dB）
    let soundLevel: Double
    
    /// 允许暴露时长（秒）
    /// 根据标准计算：T = 8小时 × 2^((基准限值 - 声级) / 交换率)
    let allowedDuration: TimeInterval
    
    /// 累计达标时长（秒）
    /// 实际测量中在该声级范围内的累计暴露时间
    let accumulatedDuration: TimeInterval
    
    /// 是否为天花板限值
    let isCeilingLimit: Bool
    
    /// 当前声级剂量百分比（%）
    /// 计算公式：(累计时长 / 允许时长) × 100%
    var currentLevelDose: Double {
        guard allowedDuration > 0 else { return 0.0 }
        return (accumulatedDuration / allowedDuration) * 100.0
    }
    
    /// 是否超标
    var isExceeding: Bool {
        return accumulatedDuration > allowedDuration
    }
    
    /// 剩余允许时长（秒）
    var remainingDuration: TimeInterval {
        return max(0, allowedDuration - accumulatedDuration)
    }
    
    /// 格式化的允许时长显示
    var formattedAllowedDuration: String {
        return formatDuration(allowedDuration)
    }
    
    /// 格式化的累计时长显示
    var formattedAccumulatedDuration: String {
        return formatDuration(accumulatedDuration)
    }
    
    /// 格式化的剩余时长显示
    var formattedRemainingDuration: String {
        return formatDuration(remainingDuration)
    }
    
    /// 格式化时长（秒转换为时:分:秒或分:秒）
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%d:%02d", minutes, secs)
        } else {
            return String(format: "%d秒", secs)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case soundLevel, allowedDuration, accumulatedDuration, isCeilingLimit
    }
}

/// 允许暴露时长表
///
/// 包含所有声级的暴露时长信息列表
/// 用于显示和分析不同声级下的暴露情况
///
/// **用途**：
/// - 显示每个声级的允许暴露时间
/// - 统计实际累计暴露时间
/// - 计算每个声级的剂量贡献
/// - 评估总体暴露风险
///
/// **使用示例**：
/// ```swift
/// let table = manager.getPermissibleExposureDurationTable(standard: .niosh)
/// print("总剂量: \(table.totalDose)%")
/// for duration in table.durations {
///     print("\(duration.soundLevel) dB: \(duration.formattedAccumulatedDuration) / \(duration.formattedAllowedDuration)")
/// }
/// ```
struct PermissibleExposureDurationTable: Codable {
    /// 使用的标准
    let standard: NoiseStandard
    
    /// 基准限值（dB）
    let criterionLevel: Double
    
    /// 交换率（dB）
    let exchangeRate: Double
    
    /// 天花板限值（dB）
    let ceilingLimit: Double
    
    /// 所有声级的暴露时长列表
    let durations: [PermissibleExposureDuration]
    
    /// 总剂量百分比（%）
    /// 所有声级剂量的累加
    var totalDose: Double {
        return durations.reduce(0.0) { $0 + $1.currentLevelDose }
    }
    
    /// 超标的声级数量
    var exceedingLevelsCount: Int {
        return durations.filter { $0.isExceeding }.count
    }
    
    /// 有暴露记录的声级数量
    var exposedLevelsCount: Int {
        return durations.filter { $0.accumulatedDuration > 0 }.count
    }
    
    /// 转换为JSON字符串
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// 从JSON字符串创建
    static func fromJSON(_ jsonString: String) -> PermissibleExposureDurationTable? {
        let decoder = JSONDecoder()
        
        guard let data = jsonString.data(using: .utf8),
              let table = try? decoder.decode(PermissibleExposureDurationTable.self, from: data) else {
            return nil
        }
        return table
    }
}

