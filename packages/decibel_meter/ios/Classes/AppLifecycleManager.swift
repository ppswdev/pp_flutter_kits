//
//  AppLifecycleManager.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//

import Foundation
import UIKit
import Combine

/// 应用生命周期管理器
class AppLifecycleManager: ObservableObject {
    
    // MARK: - 发布属性
    @Published var isAppInBackground: Bool = false
    @Published var backgroundTimeRemaining: TimeInterval = 0
    
    // MARK: - 私有属性
    private var cancellables = Set<AnyCancellable>()
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var backgroundTaskTimer: Timer?
    
    // MARK: - 单例
    static let shared = AppLifecycleManager()
    
    private init() {
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 公共方法
    
    /// 开始后台任务（用于分贝测量）
    func startBackgroundTaskForMeasurement() -> UIBackgroundTaskIdentifier {
        endBackgroundTask()
        
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "DecibelMeterBackgroundRecording") { [weak self] in
            print("后台任务即将过期，剩余时间: \(UIApplication.shared.backgroundTimeRemaining)")
            self?.handleBackgroundTaskExpiration()
        }
        
        print("开始后台测量任务，ID: \(backgroundTaskID.rawValue)")
        return backgroundTaskID
    }
    
    /// 结束后台任务
    func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            print("结束后台测量任务，ID: \(backgroundTaskID.rawValue)")
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
        
        backgroundTaskTimer?.invalidate()
        backgroundTaskTimer = nil
    }
    
    /// 获取剩余后台时间
    func getBackgroundTimeRemaining() -> TimeInterval {
        return UIApplication.shared.backgroundTimeRemaining
    }
    
    // MARK: - 私有方法
    
    private func setupNotificationObservers() {
        // 应用进入后台
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.handleAppDidEnterBackground()
            }
            .store(in: &cancellables)
        
        // 应用进入前台
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.handleAppWillEnterForeground()
            }
            .store(in: &cancellables)
        
        // 应用变为活跃状态
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppDidBecomeActive()
            }
            .store(in: &cancellables)
        
        // 应用变为非活跃状态
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppWillResignActive()
            }
            .store(in: &cancellables)
    }
    
    private func handleAppDidEnterBackground() {
        print("应用进入后台")
        isAppInBackground = true
        backgroundTimeRemaining = UIApplication.shared.backgroundTimeRemaining
        
        // 启动定时器监控剩余时间
        startBackgroundTimeMonitor()
    }
    
    private func handleAppWillEnterForeground() {
        print("应用即将进入前台")
        isAppInBackground = false
        backgroundTimeRemaining = 0
        
        // 停止定时器
        backgroundTaskTimer?.invalidate()
        backgroundTaskTimer = nil
    }
    
    private func handleAppDidBecomeActive() {
        print("应用变为活跃状态")
        isAppInBackground = false
    }
    
    private func handleAppWillResignActive() {
        print("应用即将变为非活跃状态")
    }
    
    private func handleBackgroundTaskExpiration() {
        print("后台任务即将过期，尝试延长任务")
        
        // 通知分贝测量管理器处理后台任务过期
        NotificationCenter.default.post(
            name: NSNotification.Name("BackgroundTaskExpiring"), 
            object: nil
        )
        
        // 尝试延长后台任务
        extendBackgroundTask()
    }
    
    private func extendBackgroundTask() {
        // 结束当前任务
        endBackgroundTask()
        
        // 开始新的后台任务
        let newTaskID = startBackgroundTaskForMeasurement()
        
        if newTaskID != .invalid {
            print("成功延长后台任务，新ID: \(newTaskID.rawValue)")
        } else {
            print("无法延长后台任务")
        }
    }
    
    private func startBackgroundTimeMonitor() {
        backgroundTaskTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateBackgroundTimeRemaining()
        }
    }
    
    private func updateBackgroundTimeRemaining() {
        let remaining = UIApplication.shared.backgroundTimeRemaining
        backgroundTimeRemaining = remaining
        
        // 当剩余时间少于30秒时发出警告
        if remaining < 30 && remaining > 0 {
            print("⚠️ 后台时间不足30秒: \(remaining)")
        }
        
        // 当剩余时间为无穷大时（音频后台模式），停止监控
        if remaining == .greatestFiniteMagnitude {
            backgroundTaskTimer?.invalidate()
            backgroundTaskTimer = nil
            print("✅ 应用支持无限后台运行（音频模式）")
        }
    }
}

// MARK: - 扩展方法

extension AppLifecycleManager {
    
    /// 检查是否支持后台音频处理
    func isBackgroundAudioSupported() -> Bool {
        let backgroundModes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String] ?? []
        return backgroundModes.contains("audio")
    }
    
    /// 获取后台模式信息
    func getBackgroundModes() -> [String] {
        return Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String] ?? []
    }
    
    /// 打印后台配置信息
    func printBackgroundConfiguration() {
        print("=== 后台配置信息 ===")
        print("支持的后台模式: \(getBackgroundModes())")
        print("支持音频后台: \(isBackgroundAudioSupported())")
        print("当前后台状态: \(isAppInBackground ? "后台" : "前台")")
        print("剩余后台时间: \(backgroundTimeRemaining)")
        print("==================")
    }
}
