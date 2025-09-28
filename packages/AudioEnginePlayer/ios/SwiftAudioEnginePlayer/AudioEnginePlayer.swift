//
//  AudioEnginePlayer.swift
//  SwiftAudioEqualizer
//
//  Created by xiaopin on 2024/7/17.
//

import AVFoundation
import MediaPlayer

enum LoopMode {
    case single
    case all
    case shuffle
}

struct TrackModel {
    var source: String
    var title: String
    var artist: String
    var album: String
    var albumArt: UIImage?
}

class AudioEnginePlayer {
    //MARK: Public Property
    /// 播放状态改变
    var onPlayingStatusChanged: ((Bool) -> Void)?
    /// 播放索引改变
    var onPlayingIndexChanged: ((Int) -> Void)?
    /// 播放完成
    var onPlayCompleted: (() -> Void)?
    /// 播放进度更新
    var onPlaybackProgressUpdate: ((Int) -> Void)?
    /// 频谱数据
    var onSpectrumDataAvailable: (([Float]) -> Void)?

    /// 播放总时长，单位毫秒
    var totalDuration: Int = 0
    /// 是否静音
    var isMute: Bool = false
    /// 是否启用淡入淡出效果
    var enableFadeEffect: Bool = true
    /// 音量控制，限制音量范围在 0.0 到 1.0 之间
    var volume: Float = 1.0
    /// 音量增强，限制增益范围在 0 dB 到 24 dB 之间
    var volumeBV: Float = 0.0
    /// 播放速度，限制播放速度范围在 0.25 到 4.0 之间
    var speed: Float = 1.0
    /// 当前播放索引
    var currentPlayIndex: Int = 0
    /// 播放状态
    var isPlaying: Bool = false {
        didSet {
            if !isPlaying {
                // 如果没有播放，则所有频谱柱显示为 0 值
                onSpectrumDataAvailable?([Float](repeating: 0.0, count: 24))
            }
        }
    }

    //MARK: Private Property
    /// 音频回话
    private var audioSession: AVAudioSession
    /// 音频文件
    private var audioFile: AVAudioFile?
    /// 音频引擎
    private var audioEngine: AVAudioEngine
    /// 播放节点
    private var playerNode: AVAudioPlayerNode
    /// 播放速度
    private var varispeed: AVAudioUnitVarispeed
    /// 低音增强器
    private var bassBooster: AVAudioUnitEQ
    /// 均衡器
    private var equalizer: AVAudioUnitEQ
    /// 混响
    private var reverb: AVAudioUnitReverb
    /// 频谱分析对象
    private var spectrumAnalyzer: SpectrumAnalyzer
    /// 是否进行中
    private var isProcessing: Bool = false
    /// 是否暂停
    private var isPaused: Bool = false
    /// 单位：毫秒
    private var seekPosition: Int = 0

    /// 播放进度，单位毫秒
    private var playbackProgress: Int = 0
    private var progressUpdateTimer: DispatchSourceTimer?

    /// 播放列表
    private var playlist: [TrackModel] = []
    /// 循环模式
    private var loopMode: LoopMode = .all

    init() {
        audioSession = AVAudioSession.sharedInstance()
        playerNode = AVAudioPlayerNode()
        audioEngine = AVAudioEngine()
        varispeed = AVAudioUnitVarispeed()
        bassBooster = AVAudioUnitEQ(numberOfBands: 3)
        equalizer = AVAudioUnitEQ(numberOfBands: 10)
        reverb = AVAudioUnitReverb()

        spectrumAnalyzer = SpectrumAnalyzer(bufferSize: 1024, downsampleFactor: 100)

        initEqualizer()
        setupAudioEngine()
        setupAudioSession()
        setupRemoteTransportControls()
        setupAudioEngineTap()

        // 监听音频会话中断通知
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification, object: nil)
    }

    //MARK: Private Methods
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else {
            return
        }

        if type == .began {
            // 音频会话中断开始
            print("音频会话中断开始")
            if isPlaying {
                pause()
            }
        } else if type == .ended {
            // 音频会话中断结束
            print("音频会话中断结束")
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // 重新配置音频会话和音频引擎
                setupAudioSession()
                restartEngine()
                if isPaused {
                    play()
                }
            }
        }
    }

    private func setupAudioEngine() {
        // 按处理顺序附加音频单元
        audioEngine.attach(playerNode)
        audioEngine.attach(varispeed)      // 1. 变速处理（最先处理）
        audioEngine.attach(bassBooster)    // 2. 低音增强（在均衡器之前）
        audioEngine.attach(equalizer)      // 3. 均衡器（主要音色调整）
        audioEngine.attach(reverb)         // 4. 混响（最后处理）

        // 优化后的音频处理链路：playerNode -> varispeed -> bassBooster -> equalizer -> reverb -> mainMixerNode
        audioEngine.connect(playerNode, to: varispeed, format: nil)
        audioEngine.connect(varispeed, to: bassBooster, format: nil)
        audioEngine.connect(bassBooster, to: equalizer, format: nil)
        audioEngine.connect(equalizer, to: reverb, format: nil)
        audioEngine.connect(reverb, to: audioEngine.mainMixerNode, format: nil)

        do {
            try audioEngine.start()
        } catch {
            print("音频引擎启动失败: \(error)")
        }
    }

    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("设置音频会话失败: \(error)")
        }
    }

    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.isPaused {
                self.playOrPause()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.isPlaying {
                self.playOrPause()
                return .success
            }
            return .commandFailed
        }

        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.playNext()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.playPrevious()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self.seekTo(milliseconds: Int(event.positionTime * 1000))
                return .success
            }
            return .commandFailed
        }
    }

    private func setupAudioEngineTap() {
        audioEngine.mainMixerNode.installTap(
            onBus: 0, bufferSize: AVAudioFrameCount(spectrumAnalyzer.bufferSize),
            format: audioEngine.mainMixerNode.outputFormat(forBus: 0)
        ) { [weak self] (buffer, time) in
            guard let self = self else { return }
            let magnitudes = self.spectrumAnalyzer.analyze(buffer: buffer)
            DispatchQueue.main.async {
                if self.isPlaying {
                    //print("\(magnitudes)\n\n\n")
                    self.onSpectrumDataAvailable?(magnitudes)
                }
            }
        }
    }

    // 更新锁屏和控制中心的播放信息
    private func updateNowPlayingInfo(time: Int? = nil) {
        var nowPlayingInfo = [String: Any]()

        if let currentTrack = getCurrentTrack() {
            // 设置标题、歌手和专辑
            nowPlayingInfo[MPMediaItemPropertyTitle] = currentTrack.title
            nowPlayingInfo[MPMediaItemPropertyArtist] = currentTrack.artist
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = currentTrack.album

            // 设置专辑封面（Artwork）
            if let artwork = currentTrack.artwork {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                    boundsSize: artwork.size
                ) { size in
                    return artwork
                }
            }
        }

        //print("当前进度：\(playbackProgress / 1000) newTime : \(time)")
        // 设置当前播放进度
        if let newTime = time {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = newTime / 1000
        } else {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playbackProgress / 1000
        }

        // 设置音频总时长
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = totalDuration / 1000
        // 设置播放速率（1.0 正常播放，0.0 暂停）
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    // 添加获取当前播放曲目信息的方法
    private func getCurrentTrack() -> (
        title: String, artist: String, album: String, artwork: UIImage?
    )? {
        guard !playlist.isEmpty, currentPlayIndex < playlist.count else {
            return nil
        }

        let currentTrack = playlist[currentPlayIndex]
        return (
            title: currentTrack.title,
            artist: currentTrack.artist,
            album: currentTrack.album,
            artwork: currentTrack.albumArt
        )
    }

    private func restartEngine() {
        audioEngine.stop()
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("音频引擎重新启动失败: \(error)")
        }
    }

    private func initEqualizer() {
        // 标准10段均衡器配置 - 基于ISO标准频段
        let frequencies: [Float] = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        let initialGains: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

        for i in 0..<equalizer.bands.count {
            let band = equalizer.bands[i]
            band.filterType = .parametric
            band.frequency = frequencies[i]
            band.bandwidth = 1.0
            band.gain = initialGains[i]
            band.bypass = false
        }

        // 优化后的低音增强器配置 - 基于低频段科学分布
        setupBassBooster()
    }
    
    /// 设置低音增强器 - 基于低频段科学分布
    private func setupBassBooster() {
        let bassBands = bassBooster.bands
        
        // 第一频段：超低频 (40Hz) - 重低音基础
        bassBands[0].filterType = .parametric
        bassBands[0].frequency = 40
        bassBands[0].bandwidth = 0.6  // 很窄的带宽，避免共振
        bassBands[0].gain = 0
        bassBands[0].bypass = false
        
        // 第二频段：低频 (60Hz) - 主要低音频段
        bassBands[1].filterType = .parametric
        bassBands[1].frequency = 60
        bassBands[1].bandwidth = 0.7  // 窄带宽，精确控制
        bassBands[1].gain = 0
        bassBands[1].bypass = false
        
        // 第三频段：中低频 (100Hz) - 低音过渡频段
        bassBands[2].filterType = .lowShelf  // 使用lowShelf更合适
        bassBands[2].frequency = 100
        bassBands[2].bandwidth = 1.0
        bassBands[2].gain = 0
        bassBands[2].bypass = false
    }

    private func loadAndPlayAudioFile(from url: URL) {
        do {
            self.audioFile = try AVAudioFile(forReading: url)
            if let audioFile = self.audioFile {
                let duration = Double(audioFile.length) / audioFile.processingFormat.sampleRate
                self.totalDuration = Int(duration * 1000)
            }
            self.playerNode.scheduleFile(self.audioFile!, at: nil, completionHandler: nil)
            self.restartEngine()
            self.playerNode.play()
            self.isPlaying = true
            if !self.isMute {
                self.playerNode.volume = self.volume
            }

            startProgressUpdateTimer()

            updateNowPlayingInfo()
        } catch {
            print("Error loading audio file: \(error)")
        }
    }

    private func startProgressUpdateTimer() {
        stopProgressUpdateTimer()
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
        timer.schedule(deadline: .now(), repeating: .milliseconds(100))
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            let currentTime = self.playerNode.current + Double(seekPosition / 1000)
            let progress = max(0, Int(currentTime * 1000))
            //print("self.playerNode.current :\(self.playerNode.current) + \(seekPosition/1000) = currentTime: \(currentTime)")
            //print("PlayerNode isPlayer = \(self.playerNode.isPlaying)")
            DispatchQueue.main.async {
                self.updateNowPlayingInfo(time: progress)
                self.playbackProgress = progress
                //print("self.playbackProgress \(self.playbackProgress)/\(self.totalDuration)")
                self.onPlaybackProgressUpdate?(self.playbackProgress)
                if self.playbackProgress >= self.totalDuration {
                    self.stopProgressUpdateTimer()
                    self.handlePlaybackCompletion()
                }
            }
        }
        timer.resume()
        progressUpdateTimer = timer
        onPlayingStatusChanged?(true)
    }

    private func stopProgressUpdateTimer() {
        playbackProgress = 0
        progressUpdateTimer?.cancel()
        progressUpdateTimer = nil
        onPlayingStatusChanged?(false)
    }

    private func downloadFile(from url: URL, completion: @escaping (URL?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            guard let localURL = localURL, error == nil else {
                print("Download error: \(String(describing: error))")
                completion(nil)
                return
            }
            do {
                let documentsURL = FileManager.default.urls(
                    for: .cachesDirectory, in: .userDomainMask
                ).first!
                let audioCacheURL = documentsURL.appendingPathComponent("AudioEnginePlayer")

                if !FileManager.default.fileExists(atPath: audioCacheURL.path) {
                    try FileManager.default.createDirectory(
                        at: audioCacheURL, withIntermediateDirectories: true, attributes: nil)
                }

                let destinationURL = audioCacheURL.appendingPathComponent(url.lastPathComponent)
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    do {
                        try FileManager.default.removeItem(at: destinationURL)
                    } catch {
                        print("无法删除现有文件: \(error)")
                        completion(destinationURL)
                        return
                    }
                }
                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                completion(destinationURL)
            } catch {
                print("File move error: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }

    private func handlePlaybackCompletion() {
        onPlayCompleted?()
        seekPosition = 0
        isProcessing = false
        stopProgressUpdateTimer()
        switch loopMode {
        case .single:
            playCurrentTrack()
        case .all:
            playNextTrack()
        case .shuffle:
            playRandomTrack()
        }
    }

    private func playCurrentTrack() {
        guard !playlist.isEmpty, currentPlayIndex < playlist.count else {
            print("播放列表为空或索引无效")
            return
        }

        let track = playlist[currentPlayIndex]
        play(with: track)
    }

    private func playNextTrack() {
        guard !playlist.isEmpty else {
            print("播放列表为空")
            return
        }
        if loopMode == .shuffle {
            playRandomTrack()
            return
        }
        currentPlayIndex = (currentPlayIndex + 1) % playlist.count
        playCurrentTrack()
    }

    private func playPreviousTrack() {
        guard !playlist.isEmpty else {
            print("播放列表为空")
            return
        }
        if loopMode == .shuffle {
            playRandomTrack()
            return
        }
        currentPlayIndex = (currentPlayIndex - 1 + playlist.count) % playlist.count
        playCurrentTrack()
    }

    private func playRandomTrack() {
        guard !playlist.isEmpty else {
            print("播放列表为空")
            return
        }
        currentPlayIndex = Int.random(in: 0..<playlist.count)
        playCurrentTrack()
    }

    private func fadeVolume(
        to targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil
    ) {
        let steps = 50
        let stepDuration = duration / Double(steps)
        let currentVolume = self.playerNode.volume
        let volumeStep = (targetVolume - currentVolume) / Float(steps)

        //print("current: \(currentVolume) targetVolume:\(targetVolume)")

        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                self.playerNode.volume = currentVolume + volumeStep * Float(step)
                if step == steps {
                    completion?()
                }
            }
        }
    }

    //MARK: Public Methods
    public func ensureEngineRunning() {
        if !audioEngine.isRunning {
            setupAudioSession()
            do {
                try audioEngine.start()
            } catch {
                print("无法重新启动音频引擎: \(error)")
            }
        }
    }

    public func play(with track: TrackModel) {
        let filePath = track.source
        print("Play filePath \(filePath)")
        stop()
        if !playlist.contains(where: { $0.source == filePath }) {
            playlist.append(track)
            currentPlayIndex = playlist.count - 1
        } else {
            currentPlayIndex = playlist.firstIndex(where: { $0.source == filePath }) ?? 0
        }
        onPlayingIndexChanged?(currentPlayIndex)
        if let url = URL(string: filePath), url.scheme == "http" || url.scheme == "https" {
            downloadFile(from: url) { localURL in
                guard let localURL = localURL else {
                    print("Failed to download file")
                    return
                }
                print("成功下载：\(filePath)\n存储位置：\(localURL)")
                self.loadAndPlayAudioFile(from: localURL)
            }
        } else {
            let localURL = URL(fileURLWithPath: filePath)
            loadAndPlayAudioFile(from: localURL)
        }
    }

    public func seekTo(milliseconds: Int) {
        guard let audioFile = self.audioFile else {
            print("音频文件未加载")
            return
        }

        if isProcessing {
            print("isProcessing")
            return
        }

        // 设置跳转标志位和目标时间
        isProcessing = true
        seekPosition = milliseconds

        do {
            ensureEngineRunning()
            if !isPaused && isPlaying {
                pause()
            }
            playerNode.play()

            guard let nodeTime = self.playerNode.lastRenderTime,
                let playerTime = self.playerNode.playerTime(forNodeTime: nodeTime)
            else {
                print("无法获取播放节点时间")
                return
            }
            let sampleRate = playerTime.sampleRate

            // 计算新的采样时间（将毫秒转换为秒再乘以采样率）
            let newSampleTime = AVAudioFramePosition(sampleRate * (Double(milliseconds) / 1000.0))
            // 计算剩余播放时长（单位：秒）
            let length = (totalDuration - milliseconds) / 1000
            // 计算剩余播放帧数
            let framesToPlay = AVAudioFrameCount(
                max(0, Float(playerTime.sampleRate) * Float(length)))

            print("newSampleTime \(newSampleTime) framesToPlay: \(framesToPlay)")

            // 停止当前播放
            playerNode.stop()

            // 如果剩余帧数大于1000，则重新调度播放
            if framesToPlay > 1000 {
                playerNode.scheduleSegment(
                    audioFile, startingFrame: newSampleTime, frameCount: framesToPlay, at: nil,
                    completionHandler: nil)
            }

            // 开始播放
            if !self.isMute {
                self.playerNode.volume = self.volume
            }
            playerNode.play()
            isPaused = false
            isPlaying = true

            // 开始更新播放进度的定时器
            startProgressUpdateTimer()
        } catch {
            print("Seek操作失败: \(error)")
        }
        isProcessing = false
    }

    public func seekToIndex(_ index: Int) {
        guard index >= 0 && index < playlist.count else {
            print("无效的索引：\(index)")
            return
        }
        currentPlayIndex = index
        playCurrentTrack()
    }

    public func playOrPause() {
        if isProcessing {
            print("playOrPause isProcessing")
            return
        }
        isProcessing = true
        if isPlaying {
            if enableFadeEffect {
                self.isPaused = true
                self.isPlaying = false
                self.stopProgressUpdateTimer()
                fadeVolume(to: 0.0, duration: 0.7) { [weak self] in  // 淡出
                    self?.playerNode.pause()
                    self?.isProcessing = false
                }
            } else {
                self.playerNode.pause()
                self.isPaused = true
                self.isPlaying = false
                self.isProcessing = false
                self.stopProgressUpdateTimer()
            }
        } else if isPaused {
            ensureEngineRunning()
            if enableFadeEffect {
                self.playerNode.play()
                self.isPaused = false
                self.isPlaying = true
                self.startProgressUpdateTimer()
                fadeVolume(to: self.volume, duration: 1.5)  // 淡入
            } else {
                self.playerNode.play()
                self.isPaused = false
                self.isPlaying = true
                self.startProgressUpdateTimer()
            }
            self.isProcessing = false
        }
        updateNowPlayingInfo()
    }

    public func play() {
        self.playerNode.play()
        self.isPaused = false
        self.isPlaying = true
        self.startProgressUpdateTimer()
        updateNowPlayingInfo()
    }

    public func pause() {
        playerNode.pause()
        isPaused = true
        isPlaying = false
        stopProgressUpdateTimer()
        updateNowPlayingInfo()
    }

    public func stop() {
        // 停止更新播放进度的定时器
        stopProgressUpdateTimer()

        // 停止播放节点和音频引擎
        playerNode.stop()
        audioEngine.stop()

        // 重置播放节点和音频引擎
        playerNode.reset()
        audioEngine.reset()

        // 更新播放状态
        isPlaying = false
        isPaused = false
        onPlayingStatusChanged?(false)

        // 重置播放进度
        seekPosition = 0
        isProcessing = false
        playbackProgress = 0
        onPlaybackProgressUpdate?(playbackProgress)
        updateNowPlayingInfo()
    }

    public func setPlaylist(_ tracks: [TrackModel], autoPlay: Bool = true) {
        stop()
        playlist = tracks
        currentPlayIndex = 0
        if autoPlay {
            play(with: tracks[currentPlayIndex])
        }
    }

    public func appendToPlaylist(_ track: TrackModel, autoPlay: Bool = false) {
        playlist.append(track)
        if autoPlay {
            currentPlayIndex = playlist.count - 1
            play(with: playlist[currentPlayIndex])
        }
    }

    public func updatePlaylistInfos(_ tracks: [TrackModel]) {
        playlist = tracks
        updateNowPlayingInfo()
    }

    public func removeFromPlaylist(_ index: Int) {
        guard index >= 0 && index < playlist.count else {
            print("无效的索引：\(index)")
            return
        }

        // 如果移除的是当前正在播放的歌曲
        if index == currentPlayIndex {
            stop()
            // 移除播放列表中的指定项
            playlist.remove(at: index)

            // 调整当前播放索引
            if !playlist.isEmpty {
                currentPlayIndex = index % playlist.count
                playCurrentTrack()
            }
        } else {
            // 移除播放列表中的指定项
            playlist.remove(at: index)

            // 调整当前播放索引
            if index < currentPlayIndex {
                currentPlayIndex -= 1
            }
        }
    }

    public func moveOnPlaylist(_ oldIndex: Int, _ newIndex: Int) {
        guard oldIndex >= 0 && oldIndex < playlist.count,
            newIndex >= 0 && newIndex < playlist.count
        else {
            print("无效的索引：oldIndex: \(oldIndex), newIndex: \(newIndex)")
            return
        }

        // 获取要移动的元素
        let element = playlist.remove(at: oldIndex)

        // 将元素插入到新位置
        playlist.insert(element, at: newIndex)

        // 更新当前播放索引
        if currentPlayIndex == oldIndex {
            currentPlayIndex = newIndex
        } else if oldIndex < currentPlayIndex && newIndex >= currentPlayIndex {
            currentPlayIndex -= 1
        } else if oldIndex > currentPlayIndex && newIndex <= currentPlayIndex {
            currentPlayIndex += 1
        }
    }

    public func playNext() {
        playNextTrack()
    }

    public func playPrevious() {
        playPreviousTrack()
    }

    public func setSpeed(_ speed: Float) {
        let clampedRate = max(0.25, min(speed, 4.0))  // 限制播放速度范围在 0.25 到 4.0 之间
        self.speed = clampedRate
        varispeed.rate = clampedRate
        print("播放速度设置为：\(clampedRate)")
    }

    public func setVolume(_ volume: Float) {
        let clampedVolume = max(0.0, min(volume, 1.0))  // 限制音量范围在 0.0 到 1.0 之间
        self.volume = clampedVolume
        playerNode.volume = clampedVolume
        print("音量设置为：\(clampedVolume)")
    }

     public func setVolumeBoost(_ volume: Float) {
        let clampedVolume = max(0.0, min(volume, 10.0))
        self.volume = clampedVolume
        playerNode.volume = clampedVolume
        print("音量增强设置为：\(clampedVolume)")
    }

    public func setIsMute(_ isMute: Bool) {
        self.isMute = isMute
        playerNode.volume = isMute ? 0 : 1
        print("静音状态为：\(isMute)")
    }

    public func setEnableFadeEffect(_ value: Bool) {
        self.enableFadeEffect = value
        print("是否启用淡入淡出：\(value)")
    }

    public func setLoopMode(_ mode: LoopMode) {
        loopMode = mode
        print("切换到：\(loopMode)")
    }

    public func setBandGain(bandIndex: Int, gain: Float) {
        if isPlaying {
            pause()
        }
        guard bandIndex >= 0 && bandIndex < equalizer.bands.count else {
            print("无效的频段索引： \(bandIndex)/\(equalizer.bands.count) \(gain)")
            return
        }
        let clampedGain = max(-12.0, min(gain, 12.0))  // 限制增益范围在 -12 dB 到 +12 dB 之间
        equalizer.bands[bandIndex].gain = clampedGain
        restartEngine()

        if !isPlaying {
            play()
        }
    }

    public func setReverb(id: Int, wetDryMix: Float = 50) {
        let recordTime = playbackProgress
        if isPlaying {
            pause()
        }
        if let preset = AVAudioUnitReverbPreset(rawValue: id) {
            reverb.loadFactoryPreset(preset)
        } else {
            print("无效的混响预设ID: \(id)")
            return
        }

        let clampedMix = max(0.0, min(wetDryMix, 100.0))  // 限制混响范围在 0% 到 100% 之间
        reverb.wetDryMix = clampedMix

        audioEngine.disconnectNodeInput(varispeed)
        audioEngine.disconnectNodeOutput(varispeed)
        audioEngine.disconnectNodeInput(bassBooster)
        audioEngine.disconnectNodeOutput(bassBooster)
        audioEngine.disconnectNodeInput(equalizer)
        audioEngine.disconnectNodeOutput(equalizer)
        audioEngine.disconnectNodeInput(reverb)
        audioEngine.disconnectNodeOutput(reverb)

        // 使用优化后的连接顺序
        audioEngine.connect(playerNode, to: varispeed, format: nil)
        audioEngine.connect(varispeed, to: bassBooster, format: nil)
        audioEngine.connect(bassBooster, to: equalizer, format: nil)
        audioEngine.connect(equalizer, to: reverb, format: nil)
        audioEngine.connect(reverb, to: audioEngine.mainMixerNode, format: nil)

        restartEngine()

        seekTo(milliseconds: recordTime)
    }


    public func setBassBoost(_ gain: Float, smooth: Bool = true, duration: TimeInterval = 0.4) {
        // 限制最大增益，防止失真
        let clampedGain = max(-12.0, min(gain, 12.0))  // 进一步降低最大增益
        
        // 基于频段特性的权重分配
        func getBassBandWeight(_ index: Int) -> Float {
            switch index {
            case 0: return 0.5  // 超低频(40Hz) - 重低音基础
            case 1: return 0.7  // 低频(60Hz) - 主要低音频段
            case 2: return 0.3  // 中低频(100Hz) - 过渡频段
            default: return 1.0
            }
        }
        
        // 计算安全的总增益
        let totalWeight: Float = 0.5 + 0.7 + 0.3  // 1.5倍
        let maxSafeGain: Float = 8.0  // 更保守的安全增益
        
        let finalGain: Float
        if abs(clampedGain * totalWeight) > maxSafeGain {
            finalGain = clampedGain * (maxSafeGain / abs(clampedGain * totalWeight))
            print("警告：增益过高，已自动降低到安全范围")
        } else {
            finalGain = clampedGain
        }
        
        if smooth && duration > 0 {
            // 平滑过渡
            let steps = 20
            let stepDur = duration / Double(steps)
            let startGains = bassBooster.bands.map { $0.gain }
            let targetGains = bassBooster.bands.enumerated().map { index, _ in
                finalGain * getBassBandWeight(index)
            }
            let deltas = zip(startGains, targetGains).map { $1 - $0 }.map { $0 / Float(steps) }
            
            for i in 1...steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + stepDur * Double(i)) {
                    for (index, band) in self.bassBooster.bands.enumerated() {
                        band.gain = startGains[index] + deltas[index] * Float(i)
                    }
                }
            }
        } else {
            // 立即设置
            for (index, band) in bassBooster.bands.enumerated() {
                band.gain = finalGain * getBassBandWeight(index)
            }
        }
        
        // 协同调整均衡器的低频段
        if equalizer.bands.count > 2 {
            let lowBass = equalizer.bands[0]  // 32Hz频段
            let midBass = equalizer.bands[1]  // 64Hz频段
            
            // 协同增强，但幅度较小
            let synergyGain = finalGain * 0.2
            lowBass.gain = synergyGain
            midBass.gain = synergyGain * 0.5
        }
        
        
        print("优化后的多频段低音增强设置：")
        for (index, band) in bassBooster.bands.enumerated() {
            print("  频段\(index): \(band.frequency)Hz, 增益=\(band.gain)dB")
        }
    }

    public func resetAll() {
        let recordTime = playbackProgress
        if isPlaying {
            pause()
        }

        let initialGains: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]  // 重置为初始标准模式的增益值
        for i in 0..<equalizer.bands.count {
            equalizer.bands[i].gain = initialGains[i]
        }

        audioEngine.disconnectNodeInput(varispeed)
        audioEngine.disconnectNodeOutput(varispeed)
        audioEngine.disconnectNodeInput(bassBooster)
        audioEngine.disconnectNodeOutput(bassBooster)
        audioEngine.disconnectNodeInput(equalizer)
        audioEngine.disconnectNodeOutput(equalizer)
        audioEngine.disconnectNodeInput(reverb)
        audioEngine.disconnectNodeOutput(reverb)

        // 使用优化后的连接顺序（不包含混响）
        audioEngine.connect(playerNode, to: varispeed, format: nil)
        audioEngine.connect(varispeed, to: bassBooster, format: nil)
        audioEngine.connect(bassBooster, to: equalizer, format: nil)
        audioEngine.connect(equalizer, to: audioEngine.mainMixerNode, format: nil)

        restartEngine()

        seekTo(milliseconds: recordTime)
    }

    public func clearCaches() {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let audioCacheURL = documentsURL.appendingPathComponent("AudioEnginePlayer")
            do {
                if fileManager.fileExists(atPath: audioCacheURL.path) {
                    let fileURLs = try fileManager.contentsOfDirectory(
                        at: audioCacheURL, includingPropertiesForKeys: nil, options: [])
                    for fileURL in fileURLs {
                        try fileManager.removeItem(at: fileURL)
                    }
                    print("缓存清理成功")
                } else {
                    print("缓存目录不存在")
                }
            } catch {
                print("缓存清理失败: \(error)")
            }
        }
    }
    
    // MARK: - 预置配置方法
    
    /// 应用预置均衡器配置
    public func applyEqualizerPreset(_ preset: EqualizerPreset) {
        let recordTime = playbackProgress
        if isPlaying {
            pause()
        }
        
        let gains = preset.gains
        for i in 0..<min(equalizer.bands.count, gains.count) {
            equalizer.bands[i].gain = gains[i]
        }
        
        restartEngine()
        seekTo(milliseconds: recordTime)
        print("已应用均衡器预置: \(preset.name)")
    }
    
    /// 应用预置音效配置
    public func applyAudioEffectPreset(_ preset: AudioEffectPreset) {
        let recordTime = playbackProgress
        if isPlaying {
            pause()
        }
        
        // 应用低音增强
        setBassBoost(preset.bassBoost, smooth: false)
        
        // 应用混响
        if let reverbPreset = preset.reverbPreset {
            setReverb(id: reverbPreset.rawValue, wetDryMix: preset.reverbMix)
        }
        
        restartEngine()
        seekTo(milliseconds: recordTime)
        print("已应用音效预置: \(preset.name)")
    }
}

// MARK: - 预置配置结构体

/// 均衡器预置配置
struct EqualizerPreset {
    let name: String
    let gains: [Float]
    
    // 标准预置
    static let flat = EqualizerPreset(name: "平坦", gains: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    static let vocal = EqualizerPreset(name: "人声", gains: [-2, -1, 2, 3, 2, 0, -1, -2, -1, 0])
    static let bass = EqualizerPreset(name: "低音", gains: [4, 3, 2, 1, 0, 0, 0, 0, 0, 0])
    static let treble = EqualizerPreset(name: "高音", gains: [0, 0, 0, 0, 0, 0, 1, 2, 3, 4])
    static let rock = EqualizerPreset(name: "摇滚", gains: [3, 2, 1, 0, 0, 0, 1, 2, 3, 2])
    static let jazz = EqualizerPreset(name: "爵士", gains: [1, 1, 0, 0, 0, 0, 0, 1, 1, 1])
    static let classical = EqualizerPreset(name: "古典", gains: [0, 0, 0, 0, 0, 0, 0, 1, 2, 3])
    static let pop = EqualizerPreset(name: "流行", gains: [1, 2, 2, 1, 0, 0, 0, 0, 1, 2])
}

/// 音效预置配置
struct AudioEffectPreset {
    let name: String
    let bassBoost: Float
    let reverbPreset: AVAudioUnitReverbPreset?
    let reverbMix: Float
    
    // 标准预置
    static let none = AudioEffectPreset(name: "无效果", bassBoost: 0, reverbPreset: nil, reverbMix: 0)
    static let live = AudioEffectPreset(name: "现场", bassBoost: 1, reverbPreset: .mediumHall, reverbMix: 20)
    static let club = AudioEffectPreset(name: "俱乐部", bassBoost: 4, reverbPreset: .largeHall, reverbMix: 30)
    static let studio = AudioEffectPreset(name: "录音棚", bassBoost: 0, reverbPreset: .smallRoom, reverbMix: 10)
    static let concert = AudioEffectPreset(name: "音乐会", bassBoost: 2, reverbPreset: .cathedral, reverbMix: 25)
}


extension AVAudioFile {
    /// Unit:  Seconds
    var duration: TimeInterval {
        let sampleRateSong = Double(processingFormat.sampleRate)
        let lengthSongSeconds = Double(length) / sampleRateSong
        return lengthSongSeconds
    }
}

extension AVAudioPlayerNode {
    /// Unit:  Seconds
    var current: TimeInterval {
        if let nodeTime = lastRenderTime, let playerTime = playerTime(forNodeTime: nodeTime) {
            return Double(playerTime.sampleTime) / playerTime.sampleRate
        }
        return 0
    }
}
