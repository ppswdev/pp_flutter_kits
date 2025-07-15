import AVFoundation
import Foundation
import ShazamKit
import UIKit

// MARK: - 音乐识别结果模型
struct MusicRecognitionResult {
    let title: String?
    let artist: String?
    let album: String?
    let genres: [String]
    let releaseDate: Date?
    let artworkURL: URL?
    let webURL: URL?
    let appleMusicURL: URL?
    let videoURL: URL?

    init(from mediaItem: SHMediaItem) {
        self.title = mediaItem.title
        self.artist = mediaItem.artist
        self.album = mediaItem[SHMediaItemProperty(rawValue: "sh_albumName")] as? String
        self.genres = mediaItem.genres
        self.releaseDate = mediaItem[SHMediaItemProperty(rawValue: "sh_releaseDate")] as? Date
        self.artworkURL = mediaItem.artworkURL
        self.webURL = mediaItem.webURL
        self.appleMusicURL = mediaItem.appleMusicURL
        self.videoURL = mediaItem.videoURL
    }

    func toJSON() -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var json: [String: Any] = [:]
        json["title"] = title ?? ""
        json["artist"] = artist ?? ""
        json["album"] = album ?? ""
        json["genres"] = genres.isEmpty ? [] : genres
        json["releaseDate"] = releaseDate.map { dateFormatter.string(from: $0) } ?? ""
        json["artworkURL"] = artworkURL?.absoluteString ?? ""
        json["webURL"] = webURL?.absoluteString ?? ""
        json["appleMusicURL"] = appleMusicURL?.absoluteString ?? ""
        json["videoURL"] = videoURL?.absoluteString ?? ""
        return json
    }
}

// MARK: - 识别状态枚举
enum RecognitionState: Equatable {
    case idle
    case listening
    case recognizing
    case error(String)

    // 自定义Equatable实现，因为error case包含关联值
    static func == (lhs: RecognitionState, rhs: RecognitionState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.listening, .listening):
            return true
        case (.recognizing, .recognizing):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

// MARK: - ShazamKit 管理器
class ShazamManager: NSObject {

    // MARK: - 闭包回调
    var onMatchFound: ((MusicRecognitionResult) -> Void)?
    var onMatchNotFound: ((Error?) -> Void)?
    var onStateChanged: ((RecognitionState) -> Void)?
    var onError: ((Error) -> Void)?

    // MARK: - 属性
    private let audioEngine = AVAudioEngine()
    private let session = SHSession()
    private var currentState: RecognitionState = .idle {
        didSet {
            onStateChanged?(currentState)
        }
    }

    // MARK: - 初始化
    override init() {
        super.init()
        setupSession()
    }

    // MARK: - 设置
    private func setupSession() {
        session.delegate = self
    }

    // MARK: - 权限检查
    func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        @unknown default:
            completion(false)
        }
    }

    // MARK: - 音频会话配置
    func setupAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)
    }

    // MARK: - 开始识别
    func startRecognition() {
        if currentState != .idle {
            print("识别已在进行中")
            return
        }

        checkMicrophonePermission { [weak self] granted in
            guard let self = self else { return }

            if granted {
                self.performStartRecognition()
            } else {
                self.currentState = .error("麦克风权限被拒绝")
                let error = NSError(
                    domain: "ShazamManager", code: 1001,
                    userInfo: [NSLocalizedDescriptionKey: "麦克风权限被拒绝"])
                self.onError?(error)
            }
        }
    }

    private func performStartRecognition() {
        do {
            try setupAudioSession()
            setupAudioTap()
            audioEngine.prepare()
            try audioEngine.start()
            currentState = .listening
        } catch {
            currentState = .error("启动音频引擎失败")
            onError?(error)
        }
    }

    // MARK: - 停止识别
    func stopRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        currentState = .idle
    }

    // MARK: - 音频设置
    private func setupAudioTap() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            [weak self] buffer, time in
            guard let self = self else { return }
            self.currentState = .recognizing
            self.session.matchStreamingBuffer(buffer, at: nil)
        }
    }

    // MARK: - 获取当前状态
    var isListening: Bool {
        return currentState == .listening || currentState == .recognizing
    }

    var state: RecognitionState {
        return currentState
    }
}

// MARK: - SHSessionDelegate
extension ShazamManager: SHSessionDelegate {

    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let mediaItem = match.mediaItems.first else {
            onMatchNotFound?(nil)
            return
        }

        let result = MusicRecognitionResult(from: mediaItem)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onMatchFound?(result)
        }
    }

    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onMatchNotFound?(error)
        }
    }
}

// MARK: - 扩展功能
extension ShazamManager {

    /// 打开音乐链接
    func openMusicURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    /// 获取专辑封面图片
    func loadArtworkImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    /// 格式化发行日期
    func formatReleaseDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
