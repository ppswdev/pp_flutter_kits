//
//  AppleMusicPlayerExample.swift
//  SwiftAudioEnginePlayer
//
//  Created by xiaopin on 2025/3/10.
//

import UIKit
import MediaPlayer

class AppleMusicPlayerExampleViewController: UIViewController {
    
    // MARK: - 属性
    
    private let musicPlayer = AppleMusicPlayer()
    private var songsList: [MPMediaItem] = []
    
    // MARK: - UI元素
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SongCell")
        return tableView
    }()
    
    private lazy var syncButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("同步音乐", for: .normal)
        button.addTarget(self, action: #selector(syncMusicTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var playlistButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("播放歌单", for: .normal)
        button.addTarget(self, action: #selector(playPlaylistTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("播放", for: .normal)
        button.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("上一首", for: .normal)
        button.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("下一首", for: .normal)
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var repeatModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("循环模式", for: .normal)
        button.addTarget(self, action: #selector(repeatModeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(progressChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var nowPlayingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "未播放"
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var controlsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [previousButton, playPauseButton, nextButton, repeatModeButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var timeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentTimeLabel, totalTimeLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMusicPlayer()
        updateRepeatModeButtonTitle(musicPlayer.repeatMode)
    }
    
    // MARK: - 设置方法
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 添加UI元素到视图
        view.addSubview(syncButton)
        view.addSubview(playlistButton)
        view.addSubview(tableView)
        view.addSubview(nowPlayingLabel)
        view.addSubview(progressSlider)
        view.addSubview(timeStackView)
        view.addSubview(controlsStackView)
        
        // 设置约束
        NSLayoutConstraint.activate([
            syncButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            syncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            playlistButton.topAnchor.constraint(equalTo: syncButton.bottomAnchor, constant: 10),
            playlistButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: playlistButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            nowPlayingLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            nowPlayingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nowPlayingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            progressSlider.topAnchor.constraint(equalTo: nowPlayingLabel.bottomAnchor, constant: 20),
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            timeStackView.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 5),
            timeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            controlsStackView.topAnchor.constraint(equalTo: timeStackView.bottomAnchor, constant: 20),
            controlsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlsStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupMusicPlayer() {
        musicPlayer.onAuth = { [weak self] status in
            
        }
        // 设置播放状态变化回调
        musicPlayer.onPlaybackStateChanged = { [weak self] state in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if state == .playing {
                    self.playPauseButton.setTitle("暂停", for: .normal)
                } else {
                    self.playPauseButton.setTitle("播放", for: .normal)
                }
            }
        }
        
        // 设置播放进度变化回调
        musicPlayer.onPlaybackProgressChanged = { [weak self] currentTime, totalTime in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.progressSlider.value = Float(currentTime / totalTime)
                self.currentTimeLabel.text = self.musicPlayer.formatTime(currentTime)
                self.totalTimeLabel.text = self.musicPlayer.formatTime(totalTime)
            }
        }
        
        // 设置当前播放项目变化回调
        musicPlayer.onNowPlayingItemChanged = { [weak self] item in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let item = item {
                    let title = item.title ?? "未知标题"
                    let artist = item.artist ?? "未知艺术家"
                    self.nowPlayingLabel.text = "\(title)\n\(artist)"
                    self.totalTimeLabel.text = self.musicPlayer.formatTime(item.playbackDuration)
                } else {
                    self.nowPlayingLabel.text = "未播放"
                }
                
                self.tableView.reloadData()
            }
        }
        
        // 设置音乐列表更新回调
        musicPlayer.onMusicListUpdated = { [weak self] items in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.songsList = items
                self.tableView.reloadData()
            }
        }
        
        // 设置错误回调
        musicPlayer.onError = { [weak self] errorMessage in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "错误", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                self.present(alert, animated: true)
            }
        }
        
        // 设置播放模式变化回调
        musicPlayer.onRepeatModeChanged = { [weak self] mode in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.updateRepeatModeButtonTitle(mode)
            }
        }
    }
    
    private func updateRepeatModeButtonTitle(_ mode: AMPRepeatMode) {
        switch mode {
        case .one:
            repeatModeButton.setTitle("单曲循环", for: .normal)
        case .all:
            repeatModeButton.setTitle("列表循环", for: .normal)
        case .shuffle:
            repeatModeButton.setTitle("随机播放", for: .normal)
        case .none:
            repeatModeButton.setTitle("不循环", for: .normal)
        }
    }
    
    // MARK: - 按钮动作
    
    @objc private func syncMusicTapped() {
        // 显示导入选项
        let alert = UIAlertController(title: "选择导入方式", message: nil, preferredStyle: .actionSheet)
        
        // 导入所有选项
        alert.addAction(UIAlertAction(title: "导入所有", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.musicPlayer.syncAllMusic()
        })
        
        // 打开媒体库选项
        alert.addAction(UIAlertAction(title: "打开媒体库", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.musicPlayer.openMediaPicker(from: self)
        })
        
        // 取消选项
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func playPlaylistTapped() {
        musicPlayer.playCurrentPlaylist()
    }
    
    @objc private func playPauseTapped() {
        musicPlayer.togglePlayPause()
    }
    
    @objc private func previousTapped() {
        musicPlayer.skipToPreviousItem()
    }
    
    @objc private func nextTapped() {
        musicPlayer.skipToNextItem()
    }
    
    @objc private func repeatModeTapped() {
        let alert = UIAlertController(title: "选择循环模式", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "不循环", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.musicPlayer.repeatMode = .none
        })
        
        alert.addAction(UIAlertAction(title: "单曲循环", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.musicPlayer.repeatMode = .one
        })
        
        alert.addAction(UIAlertAction(title: "列表循环", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.musicPlayer.repeatMode = .all
        })
        
        alert.addAction(UIAlertAction(title: "随机播放", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.musicPlayer.repeatMode = .shuffle
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func progressChanged(_ sender: UISlider) {
        musicPlayer.seekToPercent(sender.value)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AppleMusicPlayerExampleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        
        let song = songsList[indexPath.row]
        let title = song.title ?? "未知标题"
        let artist = song.albumArtist ?? "未知艺术家"
        let album = song.albumTitle ?? "未知专辑"
        
        var content = cell.defaultContentConfiguration()
        content.text = title + " - " + artist
        content.secondaryText = album
        
        // 检查当前歌曲是否正在播放
        if let nowPlayingItem = musicPlayer.nowPlayingItem, nowPlayingItem.persistentID == song.persistentID {
            content.textProperties.color = .systemGreen
            content.secondaryTextProperties.color = .systemGreen
        } else {
            content.textProperties.color = .black
            content.secondaryTextProperties.color = .black
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 播放选中的歌曲
        let selectedSong = songsList[indexPath.row]
        let logInfo = "\(selectedSong.persistentID)"
        print(logInfo)
        musicPlayer.playItem(withID: selectedSong.persistentID)
    }
} 
