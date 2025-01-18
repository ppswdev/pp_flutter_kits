//
//  PlayerMediumWidget.swift
//  SwiftAudioEnginePlayer
//
//  Created by xiaopin on 2024/7/27.
//

import WidgetKit
import SwiftUI

struct PlayerMediumProvider: TimelineProvider {
    typealias Entry = MusicEntry
    
    func placeholder(in context: Context) -> MusicEntry {
        MusicEntry(date: Date(), songTitle: "HT Office Music", artistName: "Big Zhuzi", isPlaying: false)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MusicEntry) -> Void) {
        let entry = MusicEntry(date: Date(), songTitle: "World of peace", artistName: "Big Zhuzi", isPlaying: true)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MusicEntry>) -> Void) {
        var entries: [MusicEntry] = []
        
        if let dict = AppGroupsShared.dictionaryForFile(file: .fileKey_currentTrack) {
            let title = dict["title"] as? String ?? ""
            let artist = dict["artist"] as? String ?? ""
            let isPlaying = dict["isPlaying"] as? Bool ?? false
            //let fileName = dict["fileName"] as? String ?? ""
            entries.append(MusicEntry(date: Date(), songTitle: title, artistName: artist, isPlaying: isPlaying))
        }else{
            entries.append(MusicEntry(date: Date(), songTitle: "HT Office Music", artistName: "Big Zhuzi", isPlaying: false))
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct PlayerMediumEntryView : View {
    var entry: PlayerMediumProvider.Entry
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 渐变背景颜色
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: 0xA892FF), Color(hex: 0x7654FF)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .padding(-16)
                VStack {
                    // 歌曲标题
                    Text(entry.songTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 5)
                    
                    // 艺术家名称
                    Text(entry.artistName)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .padding(.top, 5)
                    
                    // 播放控制按钮
                    HStack {
                        Link(destination: URL(string: "myapp://action=prev")!) {
                            Image("player_prev_white")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding(.horizontal, -5)
                        }
                        
                        Link(destination: URL(string: "myapp://action=togglePlayPause")!) {
                            Image(entry.isPlaying ? "player_play_white" : "player_pause_white")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .padding(.horizontal, 8)
                        }
                        
                        Link(destination: URL(string: "myapp://action=next")!) {
                            Image("player_next_white")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .padding(.horizontal, -5)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
}

struct PlayerMediumWidget: Widget {
    private let kind: String = "HTOfflinePlayerMediumWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlayerMediumProvider()) { entry in
            PlayerMediumEntryView(entry: entry)
        }
        .configurationDisplayName("HT Offline Player Medium")
        .description("Play music in the Medium Player.")
        .supportedFamilies([.systemMedium])
    }
}

//#Preview(as: .systemSmall) {
//    PlayerMediumWidget()
//} timeline: {
//    PlayerMediumWidget.Entry(isPlaying: false)
//    PlayerMediumWidget.Entry(isPlaying: true)
//}

//提供预览支持, 这几把玩意，没法用，我的开发环境是最新的，一定要用最新的iOS17才能支持
//struct ConfigurationAppIntent_Previews: PreviewProvider {
//   static var previews: some View {
//       Group {
//           PlayerMediumEntryView(entry: MusicEntry(date: Date(), songTitle: "Preview Song", artistName: "Preview Artist", isPlaying: false)).previewContext(WidgetPreviewContext(family: .systemSmall))
////           PlayerMediumEntryView(entry: MusicEntry(date: Date(), songTitle: "Preview Song", artistName: "Preview Artist", isPlaying: false)).previewContext(WidgetPreviewContext(family: .systemMedium))
////           PlayerMediumEntryView(entry: MusicEntry(date: Date(), songTitle: "Preview Song", artistName: "Preview Artist", isPlaying: false)).previewContext(WidgetPreviewContext(family: .systemLarge))
//       }
//   }
//}
