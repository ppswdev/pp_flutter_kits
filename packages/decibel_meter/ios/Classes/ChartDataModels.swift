//
//  ChartDataModels.swift
//  DecibelMeterDemo
//
//  Created by AI Assistant on 2025/1/23.
//
//  本文件定义了分贝测量仪所有图表相关的数据模型
//  所有模型都支持 Codable 协议，可以进行 JSON 序列化和反序列化
//

import Foundation

// MARK: - 图表数据模型

/// 时间历程图数据点
///
/// 用于表示时间历程图中的单个数据点，包含时间戳、分贝值和权重类型
/// 符合 IEC 61672-1 标准的时间历程记录要求
struct TimeHistoryDataPoint: Codable, Identifiable {
    /// 唯一标识符
    let id = UUID()
    
    /// 测量时间戳
    let timestamp: Date
    
    /// 分贝值（已校准）
    let decibel: Double
    
    /// 时间权重类型："Fast"（快）、"Slow"（慢）、"Impulse"（脉冲）
    let weightingType: String
    
    enum CodingKeys: String, CodingKey {
        case timestamp, decibel, weightingType
    }
}

/// 时间历程图数据
///
/// 包含完整的时间历程图所需的所有数据，用于绘制实时分贝变化曲线
/// 横轴为时间，纵轴为分贝值，符合专业声级计的时间历程显示标准
struct TimeHistoryChartData: Codable {
    /// 所有数据点的数组
    let dataPoints: [TimeHistoryDataPoint]
    
    /// 时间范围（秒），表示图表显示的时间跨度
    let timeRange: TimeInterval
    
    /// 数据中的最小分贝值，用于设置图表Y轴范围
    let minDecibel: Double
    
    /// 数据中的最大分贝值，用于设置图表Y轴范围
    let maxDecibel: Double
    
    /// 图表标题，包含权重信息，如"实时分贝曲线 - dB(A)F"
    let title: String
    
    /// 转换为JSON字符串
    ///
    /// - Returns: JSON格式的字符串，如果转换失败则返回nil
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
    
    /// 从JSON字符串创建时间历程图数据对象
    ///
    /// - Parameter jsonString: JSON格式的字符串
    /// - Returns: 解析成功返回TimeHistoryChartData对象，失败返回nil
    static func fromJSON(_ jsonString: String) -> TimeHistoryChartData? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let data = jsonString.data(using: .utf8),
              let chartData = try? decoder.decode(TimeHistoryChartData.self, from: data) else {
            return nil
        }
        return chartData
    }
}

/// 频谱分析数据点
///
/// 用于表示频谱分析图中的单个频率点，包含频率、声压级和倍频程类型
/// 符合 IEC 61260-1 标准的倍频程滤波器要求
struct SpectrumDataPoint: Codable, Identifiable {
    /// 唯一标识符
    let id = UUID()
    
    /// 中心频率（Hz），如31.5、63、125、250、500、1000等
    let frequency: Double
    
    /// 该频率的声压级（dB）
    let magnitude: Double
    
    /// 倍频程类型："1/1"（1/1倍频程）或"1/3"（1/3倍频程）
    let bandType: String
    
    enum CodingKeys: String, CodingKey {
        case frequency, magnitude, bandType
    }
}

/// 频谱分析图数据
///
/// 包含完整的频谱分析图所需的所有数据，用于绘制各频段的声压级分布
/// 符合 IEC 61260-1 标准的倍频程分析要求
struct SpectrumChartData: Codable {
    /// 所有频率点的数据数组
    let dataPoints: [SpectrumDataPoint]
    
    /// 倍频程类型："1/1倍频程"（10个频点）或"1/3倍频程"（30个频点）
    let bandType: String
    
    /// 频率范围（Hz），用于设置图表X轴范围
    let frequencyRange: (min: Double, max: Double)
    
    /// 图表标题，包含权重信息，如"频谱分析 - dB(A)F"
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case dataPoints, bandType, frequencyRangeMin, frequencyRangeMax, title
    }
    
    init(dataPoints: [SpectrumDataPoint], bandType: String, frequencyRange: (min: Double, max: Double), title: String) {
        self.dataPoints = dataPoints
        self.bandType = bandType
        self.frequencyRange = frequencyRange
        self.title = title
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dataPoints = try container.decode([SpectrumDataPoint].self, forKey: .dataPoints)
        bandType = try container.decode(String.self, forKey: .bandType)
        let min = try container.decode(Double.self, forKey: .frequencyRangeMin)
        let max = try container.decode(Double.self, forKey: .frequencyRangeMax)
        frequencyRange = (min: min, max: max)
        title = try container.decode(String.self, forKey: .title)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dataPoints, forKey: .dataPoints)
        try container.encode(bandType, forKey: .bandType)
        try container.encode(frequencyRange.min, forKey: .frequencyRangeMin)
        try container.encode(frequencyRange.max, forKey: .frequencyRangeMax)
        try container.encode(title, forKey: .title)
    }
    
    /// 转换为JSON字符串
    ///
    /// - Returns: JSON格式的字符串，如果转换失败则返回nil
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// 从JSON字符串创建频谱分析图数据对象
    ///
    /// - Parameter jsonString: JSON格式的字符串
    /// - Returns: 解析成功返回SpectrumChartData对象，失败返回nil
    static func fromJSON(_ jsonString: String) -> SpectrumChartData? {
        let decoder = JSONDecoder()
        
        guard let data = jsonString.data(using: .utf8),
              let chartData = try? decoder.decode(SpectrumChartData.self, from: data) else {
            return nil
        }
        return chartData
    }
}

/// 统计分布数据点
///
/// 用于表示统计分布图中的单个百分位数点
/// 符合 ISO 1996-2 标准的统计分析要求
struct StatisticalDistributionPoint: Codable, Identifiable {
    /// 唯一标识符
    let id = UUID()
    
    /// 百分位数（0-100），表示有多少百分比的时间低于此声级
    let percentile: Double
    
    /// 该百分位数对应的分贝值
    let decibel: Double
    
    /// 标签，如"L10"（10%时间超过）、"L50"（中位数）、"L90"（背景噪声）
    let label: String
    
    enum CodingKeys: String, CodingKey {
        case percentile, decibel, label
    }
}

/// 统计分布图数据
///
/// 包含完整的统计分布图所需的所有数据，用于分析噪声的统计特性
/// L10、L50、L90是噪声评估中最重要的三个统计指标
struct StatisticalDistributionChartData: Codable {
    /// 所有百分位数数据点的数组
    let dataPoints: [StatisticalDistributionPoint]
    
    /// L10值（dB）：10%时间超过的声级，表示噪声峰值特征
    let l10: Double
    
    /// L50值（dB）：50%时间超过的声级，即中位数
    let l50: Double
    
    /// L90值（dB）：90%时间超过的声级，表示背景噪声水平
    let l90: Double
    
    /// 图表标题，包含L10、L50、L90的数值
    let title: String
    
    /// 转换为JSON字符串
    ///
    /// - Returns: JSON格式的字符串，如果转换失败则返回nil
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// 从JSON字符串创建统计分布图数据对象
    ///
    /// - Parameter jsonString: JSON格式的字符串
    /// - Returns: 解析成功返回StatisticalDistributionChartData对象，失败返回nil
    static func fromJSON(_ jsonString: String) -> StatisticalDistributionChartData? {
        let decoder = JSONDecoder()
        
        guard let data = jsonString.data(using: .utf8),
              let chartData = try? decoder.decode(StatisticalDistributionChartData.self, from: data) else {
            return nil
        }
        return chartData
    }
}

/// LEQ趋势数据点
///
/// 用于表示LEQ趋势图中的单个时间点，包含时段LEQ和累积LEQ
/// 符合 ISO 1996-1 标准的等效连续声级计算要求
struct LEQTrendDataPoint: Codable, Identifiable {
    /// 唯一标识符
    let id = UUID()
    
    /// 测量时间戳
    let timestamp: Date
    
    /// 该时段的LEQ值（dB），表示该时间段内的等效连续声级
    let leq: Double
    
    /// 累积LEQ值（dB），表示从测量开始到当前时间的总体LEQ
    let cumulativeLeq: Double
    
    enum CodingKeys: String, CodingKey {
        case timestamp, leq, cumulativeLeq
    }
}

/// LEQ趋势图数据
///
/// 包含完整的LEQ趋势图所需的所有数据，用于显示LEQ随时间的变化趋势
/// 适用于职业健康监测和长期噪声暴露评估
struct LEQTrendChartData: Codable {
    /// 所有时间点的LEQ数据数组
    let dataPoints: [LEQTrendDataPoint]
    
    /// 总时间范围（秒），表示测量的总时长
    let timeRange: TimeInterval
    
    /// 当前累积LEQ值（dB）
    let currentLeq: Double
    
    /// 图表标题，包含当前LEQ值
    let title: String
    
    /// 转换为JSON字符串
    ///
    /// - Returns: JSON格式的字符串，如果转换失败则返回nil
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
    
    /// 从JSON字符串创建LEQ趋势图数据对象
    ///
    /// - Parameter jsonString: JSON格式的字符串
    /// - Returns: 解析成功返回LEQTrendChartData对象，失败返回nil
    static func fromJSON(_ jsonString: String) -> LEQTrendChartData? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let data = jsonString.data(using: .utf8),
              let chartData = try? decoder.decode(LEQTrendChartData.self, from: data) else {
            return nil
        }
        return chartData
    }
}

/// 实时指示器数据
///
/// 包含当前所有关键测量指标，用于实时显示分贝测量仪的核心数据
/// 这是最常用的数据模型，适合实时更新UI显示
struct RealTimeIndicatorData: Codable {
    /// 当前分贝值（dB），已应用频率权重、时间权重和校准
    let currentDecibel: Double
    
    /// 等效连续声级LEQ（dB），表示能量平均值
    let leq: Double
    
    /// 最小分贝值（dB），测量期间的最小值（应用时间权重）
    let min: Double
    
    /// 最大分贝值（dB），测量期间的最大值（应用时间权重）
    let max: Double
    
    /// 峰值PEAK（dB），测量期间的瞬时峰值（不应用时间权重）
    let peak: Double
    
    /// 权重显示文本，格式如"dB(A)F"、"dB(C)S"等
    let weightingDisplay: String
    
    /// 数据采集时间戳
    let timestamp: Date
    
    /// 转换为JSON字符串
    ///
    /// - Returns: JSON格式的字符串，如果转换失败则返回nil
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
    
    /// 从JSON字符串创建实时指示器数据对象
    ///
    /// - Parameter jsonString: JSON格式的字符串
    /// - Returns: 解析成功返回RealTimeIndicatorData对象，失败返回nil
    static func fromJSON(_ jsonString: String) -> RealTimeIndicatorData? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let data = jsonString.data(using: .utf8),
              let indicatorData = try? decoder.decode(RealTimeIndicatorData.self, from: data) else {
            return nil
        }
        return indicatorData
    }
}

/// 权重选项数据
///
/// 表示单个权重选项的详细信息，包括显示名称、符号、描述和标准
/// 用于在UI中展示可选的频率权重或时间权重列表
struct WeightingOption: Codable, Identifiable {
    /// 唯一标识符，通常为权重的rawValue，如"dB-A"、"Fast"
    let id: String
    
    /// 显示名称，如"dB-A"、"F"
    let displayName: String
    
    /// 符号，如"A"、"F"，用于简短显示
    let symbol: String
    
    /// 详细描述，如"A权重 - 环境噪声标准"
    let description: String
    
    /// 相关标准，如"IEC 61672-1, ISO 226"
    let standard: String
    
    /// 转换为JSON字符串
    ///
    /// - Returns: JSON格式的字符串，如果转换失败则返回nil
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// 从JSON字符串创建权重选项对象
    ///
    /// - Parameter jsonString: JSON格式的字符串
    /// - Returns: 解析成功返回WeightingOption对象，失败返回nil
    static func fromJSON(_ jsonString: String) -> WeightingOption? {
        let decoder = JSONDecoder()
        
        guard let data = jsonString.data(using: .utf8),
              let option = try? decoder.decode(WeightingOption.self, from: data) else {
            return nil
        }
        return option
    }
}

/// 权重选项列表
///
/// 包含所有可用的权重选项和当前选择的权重
/// 用于在UI中显示权重选择列表（频率权重或时间权重）
struct WeightingOptionsList: Codable {
    /// 所有可用的权重选项数组
    let options: [WeightingOption]
    
    /// 当前选择的权重ID，如"dB-A"、"Fast"
    let currentSelection: String
    
    /// 转换为JSON字符串
    ///
    /// - Returns: JSON格式的字符串，如果转换失败则返回nil
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// 从JSON字符串创建权重选项列表对象
    ///
    /// - Parameter jsonString: JSON格式的字符串
    /// - Returns: 解析成功返回WeightingOptionsList对象，失败返回nil
    static func fromJSON(_ jsonString: String) -> WeightingOptionsList? {
        let decoder = JSONDecoder()
        
        guard let data = jsonString.data(using: .utf8),
              let list = try? decoder.decode(WeightingOptionsList.self, from: data) else {
            return nil
        }
        return list
    }
}

