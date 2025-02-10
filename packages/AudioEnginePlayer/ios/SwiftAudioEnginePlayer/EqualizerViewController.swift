//
//  SceneDelegate.swift
//  SwiftAudioEqualizer
//
//  Created by xiaopin on 2024/7/17.
//

import UIKit
import AVFoundation

class EqualizerViewController: UIViewController {
    private var visualizerView: VisualizerView!
    lazy var audioEnginePlayer = AudioEnginePlayer()
    
    @IBOutlet weak var btnPlayOrPause: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var labPlayProgress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualizerView = VisualizerView(frame: CGRectMake(0, 0, view.bounds.width, 300))
        view.addSubview(visualizerView)
        view.sendSubviewToBack(visualizerView)
        
        audioEnginePlayer.onSpectrumDataAvailable = { [weak self] magnitudes in
            //print(magnitudes)
            self?.visualizerView.update(with: magnitudes)
        }
        
        audioEnginePlayer.onPlaybackProgressUpdate = { [weak self] millseconds in
            guard let self = self else { return }
            //print("millseconds \(millseconds)")
            DispatchQueue.main.async {
                self.slider.minimumValue = 0
                self.slider.maximumValue = Float(self.audioEnginePlayer.totalDuration)
                self.slider.value = Float(millseconds)
                self.labPlayProgress.text = "当前播放进度:\(millseconds)/\(self.audioEnginePlayer.totalDuration)"
            }
        }
        audioEnginePlayer.onPlayingIndexChanged = { playIndex in
            print("playIndex : \(playIndex)")
        }
        
        audioEnginePlayer.onPlayingStatusChanged = { [weak self] isPlaying in
            print("onPlayingStatusChanged isPlaying : \(isPlaying)")
            DispatchQueue.main.async {
                self?.btnPlayOrPause.setTitle(isPlaying ? "暂停" : "播放", for: .normal)
            }
        }
        
        audioEnginePlayer.onPlayCompleted = {
            print("onPlayCompleted");
        }
        
    }
    
    //均衡器设置
    @IBAction func adjustEqualizer(_ sender: UISlider) {
        let bandIndex = sender.tag - 1000;
        let gain = sender.value
        
        print("adjustEqualizer: \(bandIndex) \(gain)")
        audioEnginePlayer.setBandGain(bandIndex: bandIndex, gain: gain)
    }
    
    //随机混响
    var reverbId:Int = 0
    @IBAction func randomReverbAction(_ sender: Any) {
        reverbId += 1
        if (reverbId == 13){
            reverbId = 0
        }
        print("reverbId : \(reverbId)")
        audioEnginePlayer.setReverb(id: reverbId, wetDryMix: 50)
    }
    
    //恢复默认播放
    @IBAction func restoreAction(_ sender: Any) {
        audioEnginePlayer.resetAll()
        for i in 0..<10 {
            if let slider = view.viewWithTag(1000+i) as? UISlider{
                slider.setValue(0, animated: true)
            }
            
        }
    }
    
    @IBAction func pauseAction(_ sender: Any) {
        audioEnginePlayer.playOrPause()
    }
    
    @IBAction func prevAction(_ sender: Any) {
        audioEnginePlayer.playPrevious()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        audioEnginePlayer.playNext()
    }
    
    @IBAction func singleLoopAction(_ sender: Any) {
        audioEnginePlayer.setLoopMode(.single)
    }
    
    @IBAction func loopAction(_ sender: Any) {
        audioEnginePlayer.setLoopMode(.all)
    }
    
    @IBAction func randomLoopAction(_ sender: Any) {
        audioEnginePlayer.setLoopMode(.shuffle)
    }
    
    @IBAction func setPlaylistAction(_ sender: Any) {
        // 海阔天空、月半小弯曲、墨尔本的秋天、暖一杯茶、奢香夫人
        let tracks: [TrackModel] = [
            TrackModel(source: "http://192.168.1.225/musics/BEYOND%20-%20%E6%B5%B7%E9%98%94%E5%A4%A9%E7%A9%BA.mp3",
                       title: "海阔天空",
                       artist: "BEYOND",
                       album: "乐与怒",
                       albumArt: UIImage(named: "albumArt")),
            TrackModel(source: "http://192.168.1.225/musics/%E9%99%88%E4%B9%90%E5%9F%BA%20-%20%E6%9C%88%E5%8D%8A%E5%B0%8F%E5%A4%9C%E6%9B%B2.mp3",
                       title: "月半小夜曲",
                       artist: "陈乐基",
                       album: "月半小夜曲",
                       albumArt: nil),
            TrackModel(source: "http://192.168.1.225/musics/%E5%A2%A8%E5%B0%94%E6%9C%AC%E7%9A%84%E7%A7%8B%E5%A4%A9.m4a",
                       title: "墨尔本的秋天",
                       artist: "未知艺术家",
                       album: "未知专辑",
                       albumArt: nil),
            TrackModel(source: "http://192.168.1.225/musics/%E9%82%B5%E5%B8%85-%E6%9A%96%E4%B8%80%E6%9D%AF%E8%8C%B6.mp3",
                       title: "暖一杯茶",
                       artist: "邵帅",
                       album: "暖一杯茶",
                       albumArt: nil),
            TrackModel(source: "http://192.168.1.225/musics/%E5%A5%A2%E9%A6%99%E5%A4%AB%E4%BA%BA.m4a",
                       title: "奢香夫人",
                       artist: "未知艺术家",
                       album: "未知专辑",
                       albumArt: nil)
        ]
        
        audioEnginePlayer.setPlaylist(tracks, autoPlay: true)
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        print("移动到：\(sender.value)")
        audioEnginePlayer.seekTo(milliseconds: Int(sender.value))
    }
    @IBAction func muteChanged(_ sender: UISwitch) {
        audioEnginePlayer.setIsMute(sender.isOn)
    }
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        audioEnginePlayer.setVolume(sender.value)
    }
    
    @IBAction func volumeBVChanged(_ sender: UISlider) {
        audioEnginePlayer.setVolumeBoost(sender.value)
    }
    
    @IBAction func speedChanged(_ sender: UISlider) {
        audioEnginePlayer.setSpeed(sender.value)
    }
    
}



