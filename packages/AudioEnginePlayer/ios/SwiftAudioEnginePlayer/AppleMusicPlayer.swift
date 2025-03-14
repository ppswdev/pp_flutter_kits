//
//  AppleMusicPlayer.swift
//  SwiftAudioEnginePlayer
//
//  Created by xiaopin on 2025/3/10.
//

import Foundation
import MediaPlayer
import UIKit
/// 播放循环模式枚举
enum AMPRepeatMode {
    /// 不循环（默认模式）
    case none
    /// 列表循环
    case all
    /// 单曲循环
    case one
    /// 随机播放
    case shuffle
}

/// 音乐播放器封装类，提供对 Apple Music 的访问和控制
class AppleMusicPlayer:NSObject {
    // MARK: - 类型定义

    /// 授权回调闭包类型
    typealias AuthCallback = (Int) -> Void
    
    /// 音乐列表回调闭包类型
    typealias MusicListCallback = ([MPMediaItem]) -> Void

    /// 播放状态回调闭包类型
    typealias PlaybackStateCallback = (MPMusicPlaybackState) -> Void
    
    /// 播放进度回调闭包类型
    typealias PlaybackProgressCallback = (TimeInterval, TimeInterval) -> Void
    
    /// 当前播放项目变化回调闭包类型
    typealias NowPlayingItemCallback = (MPMediaItem?) -> Void
    
    /// 播放模式变化回调闭包类型
    typealias RepeatModeCallback = (AMPRepeatMode) -> Void

    /// 错误回调闭包类型
    typealias ErrorCallback = (String) -> Void
    
    // MARK: - 属性
    
    /// 音乐播放器实例
    private let player = MPMusicPlayerController.applicationMusicPlayer
    
    /// 进度更新定时器
    private var progressTimer: Timer?
    
    /// 通知观察者
    private var observers: [NSObjectProtocol] = []
    
    /// 当前音乐列表
    private(set) var songsList: [MPMediaItem] = []
    
    /// 当前播放模式
    private var _repeatMode: AMPRepeatMode = .none
    
    // MARK: - 回调闭包

    /// 授权回调
    /// - Parameter status: 授权状态 0: 未确定 1:拒绝授权 2: 受限的, 3.已授权
    var onAuth: AuthCallback?

    /// 音乐列表更新回调
    var onMusicListUpdated: MusicListCallback?
    
    /// 播放状态变化回调
    var onPlaybackStateChanged: PlaybackStateCallback?
    
    /// 播放进度变化回调
    var onPlaybackProgressChanged: PlaybackProgressCallback?
    
    /// 当前播放项目变化回调
    var onNowPlayingItemChanged: NowPlayingItemCallback?

    /// 播放模式变化回调
    var onRepeatModeChanged: RepeatModeCallback?

    /// 错误回调
    var onError: ErrorCallback?
    
    // MARK: - 初始化
    
    /// 初始化播放器
    override init() {
        super.init()
        setupNotifications()
    }
    
    deinit {
        stopProgressTimer()
        removeNotifications()
    }
    
    // MARK: - 通知设置
    
    /// 设置播放器通知
    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        
        // 播放状态变化通知
        let playbackStateObserver = notificationCenter.addObserver(
            forName: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: player,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            let state = self.player.playbackState
            self.onPlaybackStateChanged?(state)
            
            // 根据播放状态管理进度计时器
            if state == .playing {
                self.startProgressTimer()
            } else {
                self.stopProgressTimer()
            }
        }
        
        // 当前播放项目变化通知
        let nowPlayingItemObserver = notificationCenter.addObserver(
            forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: player,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            let item = self.player.nowPlayingItem
            self.onNowPlayingItemChanged?(item)
        }
        
        observers.append(contentsOf: [playbackStateObserver, nowPlayingItemObserver])
        
        // 开始接收通知
        player.beginGeneratingPlaybackNotifications()
    }
    
    /// 移除通知
    private func removeNotifications() {
        player.endGeneratingPlaybackNotifications()
        
        let notificationCenter = NotificationCenter.default
        for observer in observers {
            notificationCenter.removeObserver(observer)
        }
        observers.removeAll()
    }
    
    // MARK: - 进度跟踪
    
    /// 开始进度定时器
    private func startProgressTimer() {
        stopProgressTimer()
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self,
                  let currentItem = self.player.nowPlayingItem else { return }
            
            let currentTime = self.player.currentPlaybackTime
            let totalTime = TimeInterval(currentItem.playbackDuration)
            
            self.onPlaybackProgressChanged?(currentTime, totalTime)
        }
    }
    
    /// 停止进度定时器
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    // MARK: - 播放控制
    
    /// 播放
    func play() {
        player.play()
    }
    
    /// 暂停
    func pause() {
        player.pause()
    }
    
    /// 停止
    func stop() {
        player.stop()
    }
    
    /// 播放/暂停切换
    func togglePlayPause() {
        if player.playbackState == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    /// 播放下一首
    func skipToNextItem() {
        player.skipToNextItem()
    }
    
    /// 播放上一首
    func skipToPreviousItem() {
        player.skipToPreviousItem()
    }
    
    /// 从头开始播放当前歌曲
    func skipToBeginning() {
        player.skipToBeginning()
    }
    
    /// 设置播放位置
    func seekToTime(_ time: TimeInterval) {
        player.currentPlaybackTime = time
    }
    
    /// 设置播放位置（百分比）
    func seekToPercent(_ percent: Float) {
        guard let currentItem = player.nowPlayingItem else { return }
        let totalTime = currentItem.playbackDuration
        let newTime = Double(percent) * totalTime
        player.currentPlaybackTime = newTime
    }
    
    /// 播放指定歌曲ID
    @discardableResult
    func playItem(withID persistentID: MPMediaEntityPersistentID) -> Bool {
        let predicate = MPMediaPropertyPredicate(value: persistentID, forProperty: MPMediaItemPropertyPersistentID)
        let query = MPMediaQuery()
        query.addFilterPredicate(predicate)
        
        if let items = query.items, !items.isEmpty {
            player.setQueue(with: query)
            player.play()
            return true
        }
        return false
    }
    
    /// 播放指定歌曲集合
    func playItems(with query: MPMediaQuery) {
        player.setQueue(with: query)
        player.play()
    }
    
    /// 播放指定歌曲集合
    func playCollection(with collection: MPMediaItemCollection) {
        player.setQueue(with: collection)
        player.play()
    }
    
    /// 播放当前歌单
    func playCurrentPlaylist() {
        if !songsList.isEmpty {
            player.setQueue(with: MPMediaItemCollection(items: songsList))
            player.play()
        } else {
            onError?("当前歌单为空")
        }
    }
    
    // MARK: - 播放设置
    
    /// 设置播放模式
    func setRepeatMode(_ mode: AMPRepeatMode) {
        _repeatMode = mode
        
        switch mode {
        case .all:
            player.repeatMode = .all
            player.shuffleMode = .off
        case .one:
            player.repeatMode = .one
            player.shuffleMode = .off
        case .shuffle:
            player.repeatMode = .all
            player.shuffleMode = .songs
        case .none:
            player.repeatMode = .none
            player.shuffleMode = .off
        }
        
        // 触发模式变化回调
        onRepeatModeChanged?(mode)
    }
    
    /// 获取当前重复模式
    var repeatMode: AMPRepeatMode {
        get { return _repeatMode }
        set { setRepeatMode(newValue) }
    }
    
    // MARK: - 音乐库访问
    
    /// 同步所有音乐
    func syncAllMusic() {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            self.onAuth?(status.rawValue)
            if status == .authorized {
                let query = MPMediaQuery.songs()
                if let items = query.items {
                    DispatchQueue.main.async {
                        self.setCurrentSongsList(items)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.onError?("没有找到任何歌曲")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.onError?("媒体库访问被拒绝")
                }
            }
        }
    }
    
    /// 打开媒体选择器
    func openMediaPicker(from viewController: UIViewController) {
        // 确保在主线程上执行
        DispatchQueue.main.async {
            MPMediaLibrary.requestAuthorization { [weak self] status in
                // 授权回调可能在后台线程，所以需要再次确保在主线程上执行UI操作
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if status == .authorized {
                        let picker = MPMediaPickerController(mediaTypes: .music)
                        picker.delegate = self
                        picker.allowsPickingMultipleItems = true
                        viewController.present(picker, animated: true, completion: nil)
                    } else {
                        // 处理未授权情况
                        if let onError = self.onError {
                            onError("未获得媒体库访问权限")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 播放器信息
    
    /// 获取当前播放状态
    var playbackState: MPMusicPlaybackState {
        return player.playbackState
    }
    
    /// 获取当前播放项目
    var nowPlayingItem: MPMediaItem? {
        return player.nowPlayingItem
    }
    
    /// 获取当前播放时间
    var currentPlaybackTime: TimeInterval {
        get { return player.currentPlaybackTime }
        set { player.currentPlaybackTime = newValue }
    }
    
    /// 格式化时间
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 设置当前歌曲列表
    func setCurrentSongsList(_ songs: [MPMediaItem]) {
        self.songsList = songs
        self.onMusicListUpdated?(songs)
    }
}

// MARK: - 辅助类型

/// 媒体选择器委托
extension AppleMusicPlayer:MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true)
        setCurrentSongsList(mediaItemCollection.items)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }
}
