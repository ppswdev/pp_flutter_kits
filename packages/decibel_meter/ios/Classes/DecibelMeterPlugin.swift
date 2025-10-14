import Flutter
import UIKit

public class DecibelMeterPlugin: NSObject, FlutterPlugin {
  
  private let manager = DecibelMeterManager.shared
  private var eventSink: FlutterEventSink?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "decibel_meter", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "decibel_meter_events", binaryMessenger: registrar.messenger())
    let instance = DecibelMeterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    // MARK: - 基础方法
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
      
    // MARK: - 核心测量方法
    case "startMeasurement":
      Task {
        await manager.startMeasurement()
        await MainActor.run {
          result(true)
        }
      }
      
    case "stopMeasurement":
      manager.stopMeasurement()
      result(true)
      
    // MARK: - 状态和数据获取方法
    case "getCurrentState":
      let state = manager.getCurrentState()
      result(convertMeasurementStateToString(state))
      
    case "getCurrentDecibel":
      result(manager.getCurrentDecibel())
      
    case "getCurrentMeasurement":
      if let measurement = manager.getCurrentMeasurement() {
        result(convertMeasurementToDict(measurement))
      } else {
        result(nil)
      }
      
    case "getStatistics":
      let stats = manager.getStatistics()
      result([
        "current": stats.current,
        "max": stats.max,
        "min": stats.min
      ])
      
    case "getMeasurementHistory":
      let history = manager.getMeasurementHistory()
      result(history.map { convertMeasurementToDict($0) })
      
    case "getCurrentStatistics":
      if let statistics = manager.getCurrentStatistics() {
        result(convertStatisticsToDict(statistics))
      } else {
        result(nil)
      }
      
    case "getRealTimeLeq":
      result(manager.getRealTimeLeq())
      
    case "getCurrentPeak":
      result(manager.getCurrentPeak())
      
    // MARK: - 校准方法
    case "setCalibrationOffset":
      guard let args = call.arguments as? [String: Any],
            let offset = args["offset"] as? Double else {
        result(FlutterError(code: "INVALID_ARGS", message: "需要offset参数", details: nil))
        return
      }
      manager.setCalibrationOffset(offset)
      result(true)
      
    case "getCalibrationOffset":
      result(manager.getCalibrationOffset())
      
    // MARK: - 频率权重方法
    case "getCurrentFrequencyWeighting":
      let weighting = manager.getCurrentFrequencyWeighting()
      result(weighting.rawValue)
      
    case "setFrequencyWeighting":
      guard let args = call.arguments as? [String: Any],
            let weightingStr = args["weighting"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "需要weighting参数", details: nil))
        return
      }
      if let weighting = convertStringToFrequencyWeighting(weightingStr) {
        manager.setFrequencyWeighting(weighting)
        result(true)
      } else {
        result(FlutterError(code: "INVALID_WEIGHTING", message: "无效的频率权重类型", details: nil))
      }
      
    case "getAvailableFrequencyWeightings":
      let weightings = manager.getAvailableFrequencyWeightings()
      result(weightings.map { $0.rawValue })
      
    case "getFrequencyWeightingCurve":
      guard let args = call.arguments as? [String: Any],
            let weightingStr = args["weighting"] as? String,
            let weighting = convertStringToFrequencyWeighting(weightingStr) else {
        result(FlutterError(code: "INVALID_ARGS", message: "需要weighting参数", details: nil))
        return
      }
      let curve = manager.getFrequencyWeightingCurve(weighting)
      result(curve)
      
    case "getFrequencyWeightingsList":
      let list = manager.getFrequencyWeightingsList()
      result(list.toJSON())
      
    // MARK: - 时间权重方法
    case "getCurrentTimeWeighting":
      let weighting = manager.getCurrentTimeWeighting()
      result(weighting.rawValue)
      
    case "setTimeWeighting":
      guard let args = call.arguments as? [String: Any],
            let weightingStr = args["weighting"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "需要weighting参数", details: nil))
        return
      }
      if let weighting = convertStringToTimeWeighting(weightingStr) {
        manager.setTimeWeighting(weighting)
        result(true)
      } else {
        result(FlutterError(code: "INVALID_WEIGHTING", message: "无效的时间权重类型", details: nil))
      }
      
    case "getAvailableTimeWeightings":
      let weightings = manager.getAvailableTimeWeightings()
      result(weightings.map { $0.rawValue })
      
    case "getTimeWeightingsList":
      let list = manager.getTimeWeightingsList()
      result(list.toJSON())
      
    // MARK: - 扩展的公共获取方法
    case "getFormattedMeasurementDuration":
      result(manager.getFormattedMeasurementDuration())
      
    case "getMeasurementDuration":
      result(manager.getMeasurementDuration())
      
    case "getWeightingDisplayText":
      result(manager.getWeightingDisplayText())
      
    case "getMinDecibel":
      result(manager.getMinDecibel())
      
    case "getMaxDecibel":
      result(manager.getMaxDecibel())
      
    case "getLeqDecibel":
      result(manager.getLeqDecibel())
      
    // MARK: - 图表数据获取方法
    case "getTimeHistoryChartData":
      let args = call.arguments as? [String: Any]
      let timeRange = args?["timeRange"] as? Double ?? 60.0
      let chartData = manager.getTimeHistoryChartData(timeRange: timeRange)
      result(chartData.toJSON())
      
    case "getRealTimeIndicatorData":
      let indicatorData = manager.getRealTimeIndicatorData()
      result(indicatorData.toJSON())
      
    case "getSpectrumChartData":
      let args = call.arguments as? [String: Any]
      let bandType = args?["bandType"] as? String ?? "1/3"
      let chartData = manager.getSpectrumChartData(bandType: bandType)
      result(chartData.toJSON())
      
    case "getStatisticalDistributionChartData":
      let chartData = manager.getStatisticalDistributionChartData()
      result(chartData.toJSON())
      
    case "getLEQTrendChartData":
      let args = call.arguments as? [String: Any]
      let interval = args?["interval"] as? Double ?? 10.0
      let chartData = manager.getLEQTrendChartData(interval: interval)
      result(chartData.toJSON())
      
        // MARK: - 设置方法
        case "resetAllData":
          manager.resetAllData()
          result(true)

        case "clearHistory":
          manager.clearHistory()
          result(true)

        // MARK: - 噪音测量计功能
        case "getNoiseDoseData":
          let args = call.arguments as? [String: Any]
          let standardStr = args?["standard"] as? String
          let standard = convertStringToNoiseStandard(standardStr)
          let doseData = manager.getNoiseDoseData(standard: standard)
          result(doseData.toMap())

        case "isExceedingLimit":
          guard let args = call.arguments as? [String: Any],
                let standardStr = args["standard"] as? String,
                let standard = convertStringToNoiseStandard(standardStr) else {
            result(FlutterError(code: "INVALID_ARGS", message: "需要standard参数", details: nil))
            return
          }
          let isExceeding = manager.isExceedingLimit(standard: standard)
          result(isExceeding)

        case "getLimitComparisonResult":
          guard let args = call.arguments as? [String: Any],
                let standardStr = args["standard"] as? String,
                let standard = convertStringToNoiseStandard(standardStr) else {
            result(FlutterError(code: "INVALID_ARGS", message: "需要standard参数", details: nil))
            return
          }
          let comparisonResult = manager.getLimitComparisonResult(standard: standard)
          result(comparisonResult.toMap())

        case "getDoseAccumulationChartData":
          let args = call.arguments as? [String: Any]
          let interval = args?["interval"] as? Double ?? 60.0
          let standardStr = args?["standard"] as? String
          let standard = convertStringToNoiseStandard(standardStr)
          let chartData = manager.getDoseAccumulationChartData(interval: interval, standard: standard)
          result(chartData.toJSON())

        case "getTWATrendChartData":
          let args = call.arguments as? [String: Any]
          let interval = args?["interval"] as? Double ?? 60.0
          let standardStr = args?["standard"] as? String
          let standard = convertStringToNoiseStandard(standardStr)
          let chartData = manager.getTWATrendChartData(interval: interval, standard: standard)
          result(chartData.toJSON())

        case "setNoiseStandard":
          guard let args = call.arguments as? [String: Any],
                let standardStr = args["standard"] as? String,
                let standard = convertStringToNoiseStandard(standardStr) else {
            result(FlutterError(code: "INVALID_ARGS", message: "需要standard参数", details: nil))
            return
          }
          manager.setNoiseStandard(standard)
          result(true)

        case "getCurrentNoiseStandard":
          let standard = manager.getCurrentNoiseStandard()
          result(standard.rawValue)

        case "getAvailableNoiseStandards":
          let standards = manager.getAvailableNoiseStandards()
          result(standards.map { $0.rawValue })

        case "generateNoiseDosimeterReport":
          let args = call.arguments as? [String: Any]
          let standardStr = args?["standard"] as? String
          let standard = convertStringToNoiseStandard(standardStr)
          if let report = manager.generateNoiseDosimeterReport(standard: standard) {
            result(report.toJSON())
          } else {
            result(nil)
          }

        case "getPermissibleExposureDurationTable":
          let args = call.arguments as? [String: Any]
          let standardStr = args?["standard"] as? String
          let standard = convertStringToNoiseStandard(standardStr)
          let table = manager.getPermissibleExposureDurationTable(standard: standard)
          result(table.toJSON())

        default:
          result(FlutterMethodNotImplemented)
    }

  }
  
  // MARK: - 回调设置
  
  private func setupCallbacks() {
      manager.onMeasurementUpdate = { [weak self] measurement in
          guard let self = self, let eventSink = self.eventSink else { return }
          eventSink(["event": "measurementUpdate", "measurement": measurement.toMap()])
      }
      
      manager.onStateChange = { [weak self] state in
          guard let self = self, let eventSink = self.eventSink else { return }
          eventSink(["event": "stateChange", "state": state.stringValue])
      }
      
      manager.onDecibelUpdate = { [weak self] decibel in
          guard let self = self, let eventSink = self.eventSink else { return }
          eventSink(["event": "decibelUpdate", "decibel": decibel])
      }
      
      manager.onStatisticsUpdate = { [weak self] current, max, min in
          guard let self = self, let eventSink = self.eventSink else { return }
          eventSink(["event": "statisticsUpdate", "current": current, "max": max, "min": min])
      }

      manager.onAdvancedStatisticsUpdate = { [weak self] current, peak, min, max in
          guard let self = self, let eventSink = self.eventSink else { return }
          eventSink(["event": "advancedStatisticsUpdate", "current": current, "peak": peak, "min": min, "max": max])
      }
  }

  private func convertMeasurementStateToString(_ state: MeasurementState) -> String {
    switch state {
    case .idle:
      return "idle"
    case .measuring:
      return "measuring"
    case .error(let message):
      return "error: \(message)"
    }
  }
  
  /// 将字符串转换为频率权重
  private func convertStringToFrequencyWeighting(_ str: String) -> FrequencyWeighting? {
    return FrequencyWeighting.allCases.first { $0.rawValue == str }
  }
  
  /// 将字符串转换为时间权重
  private func convertStringToTimeWeighting(_ str: String) -> TimeWeighting? {
    return TimeWeighting.allCases.first { $0.rawValue == str }
  }
  
  /// 将DecibelMeasurement转换为Dictionary
  private func convertMeasurementToDict(_ measurement: DecibelMeasurement) -> [String: Any] {
    return [
      "timestamp": ISO8601DateFormatter().string(from: measurement.timestamp),
      "rawDecibel": measurement.rawDecibel,
      "aWeightedDecibel": measurement.aWeightedDecibel,
      "fastDecibel": measurement.fastDecibel,
      "slowDecibel": measurement.slowDecibel,
      "calibratedDecibel": measurement.calibratedDecibel,
      "frequencySpectrum": measurement.frequencySpectrum,
      "displayDecibel": measurement.displayDecibel,
      "levelDescription": measurement.levelDescription,
      "levelColor": measurement.levelColor
    ]
  }
  
      /// 将DecibelStatistics转换为Dictionary
      private func convertStatisticsToDict(_ statistics: DecibelStatistics) -> [String: Any] {
        return [
          "timestamp": ISO8601DateFormatter().string(from: statistics.timestamp),
          "measurementDuration": statistics.measurementDuration,
          "sampleCount": statistics.sampleCount,
          "avgDecibel": statistics.avgDecibel,
          "minDecibel": statistics.minDecibel,
          "maxDecibel": statistics.maxDecibel,
          "peakDecibel": statistics.peakDecibel,
          "leqDecibel": statistics.leqDecibel,
          "l10Decibel": statistics.l10Decibel,
          "l50Decibel": statistics.l50Decibel,
          "l90Decibel": statistics.l90Decibel,
          "standardDeviation": statistics.standardDeviation,
          "summary": statistics.summary,
          "detailedSummary": statistics.detailedSummary
        ]
      }

      /// 将字符串转换为噪声标准
      private func convertStringToNoiseStandard(_ str: String?) -> NoiseStandard? {
        guard let str = str else { return nil }
        return NoiseStandard.allCases.first { $0.rawValue == str }
      }
}

extension DecibelMeterPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        setupCallbacks()
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
