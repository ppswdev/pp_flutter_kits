//
//  PlayerSmallWidget.swift
//  SwiftAudioEnginePlayer
//
//  Created by xiaopin on 2024/7/27.
//

import WidgetKit
import SwiftUI
import AppIntents

struct MusicEntry: TimelineEntry {
    let date: Date
    let songTitle: String
    let artistName: String
    let isPlaying: Bool
}

//为小组件展示提供一切必要信息的结构体，遵守TimelineProvider协议，产生一个时间线，告诉 WidgetKit 何时渲染与刷新 Widget，时间线包含一个你定义的自定义TimelineEntry类型。时间线条目标识了你希望WidgetKit更新Widget内容的日期。在自定义类型中包含你的Widget的视图需要渲染的属性。
struct PlayerStandardProvider: TimelineProvider {
    typealias Entry = MusicEntry
    
    // 占位视图，例如网络请求失败、发生未知错误、第一次展示小组件都会展示这个view
    func placeholder(in context: Context) -> MusicEntry {
        MusicEntry(date: Date(), songTitle: "HT Office Music", artistName: "Mobiunity", isPlaying: false)
    }
    
    // 编辑屏幕在左上角选择添加Widget、第一次展示时会调用该方法(并不是每一次调用都会触发该方法，只有第一次展示或者到了固定的时间周期才会刷新，期间系统会缓存你上一次展示的内容展示出来)
    func getSnapshot(in context: Context, completion: @escaping (MusicEntry) -> Void) {
        completion(MusicEntry(date: Date(), songTitle: "Welcome HT Music World", artistName: "Mobiunity", isPlaying: true))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MusicEntry>) -> Void) {
        var entries: [MusicEntry] = []
        
        if let dict = AppGroupsShared.dictionaryForFile(file: .fileKey_currentTrack) {
            let title = dict["title"] as? String ?? "Welcome HT Music World"
            let artist = dict["artist"] as? String ?? "Mobiunity"
            let isPlaying = dict["isPlaying"] as? Bool ?? false
            //let fileName = dict["fileName"] as? String ?? ""
            entries.append(MusicEntry(date: Date(), songTitle: title, artistName: artist, isPlaying: isPlaying))
        }else{
            entries.append(MusicEntry(date: Date(), songTitle: "Welcome HT Music World", artistName: "Big Zhuzi", isPlaying: false))
        }
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct PlayerStandardEntryView : View {
    var entry: PlayerStandardProvider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @AppStorage("isVip", store: UserDefaults(suiteName: DataKeys.appGroupKey.rawValue))
    var isVip: Bool = AppGroupsShared.boolForKey(key:DataKeys.udKey_IsVIP)
    
    @AppStorage("isPlaying", store: UserDefaults(suiteName: DataKeys.appGroupKey.rawValue))
    var isPlaying: Bool = AppGroupsShared.boolForKey(key:DataKeys.udKey_IsPlaying)
    
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        if isVip {
            switch family {
            case .systemLarge:
                buildMediumView()
            case .systemMedium:
                buildMediumView()
            default:
                buildSmallView()
            }
        } else {
            ZStack {
                // 渐变背景颜色
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: 0xA892FF), Color(hex: 0x7654FF)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .padding(-16)
                
                //图标和文本
                VStack {
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                    
                    Text(NSLocalizedString("UpgradePremium", comment: "Upgrade Premium"))
                        .font(.system(size: family == .systemSmall ? 10 : 14))
                        .foregroundColor(.white)
                }
                .padding()
            }
            
        }
    }
    
    fileprivate func buildMediumView() -> some View {
        return GeometryReader { geo in
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
                        if #available(iOS 17.0, *) {
                            Button(intent: PlayerPlayPrevIntent()) {
                                Image("player_prev_white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.horizontal, -5)
                            }.buttonStyle(.plain)
                            
                            Button(intent: PlayerPlayPauseIntent()) {
                                Image(isPlaying ? "player_pause_white" : "player_play_white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 45, height: 45)
                                    .padding(.horizontal, 8)
                            }.buttonStyle(.plain)
                            
                            Button(intent: PlayerPlayNextIntent()) {
                                Image("player_next_white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.horizontal, -5)
                            }.buttonStyle(.plain)
                        }else{
                            Button(action: {
                                AppGroupsShared.setValue("playPrev", forKey: DataKeys.udKey_control_command)
                            }) {
                                Image("player_prev_white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.horizontal, -5)
                            }
                            
                            Button(action: {
                                AppGroupsShared.setValue("togglePlayPause", forKey: DataKeys.udKey_control_command)
                            }) {
                                Image(isPlaying ? "player_pause_white" : "player_play_white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 45, height: 45)
                                    .padding(.horizontal, 8)
                            }
                            
                            Button(action: {
                                AppGroupsShared.setValue("playNext", forKey: DataKeys.udKey_control_command)
                            }) {
                                Image("player_next_white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.horizontal, -5)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
    
    fileprivate func buildSmallView() -> some View {
        return GeometryReader { geo in
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
                        if #available(iOS 17.0, *) {
                            Button(intent: PlayerPlayPrevIntent()) {
                                Image("player_prev_white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.horizontal, -5)
                            }.buttonStyle(.plain)
                            
                            Button(intent: PlayerPlayPauseIntent()) {
                                Image(isPlaying ? "player_pause_white" : "player_play_white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 45, height: 45)
                                    .padding(.horizontal, 8)
                            }.buttonStyle(.plain)
                            
                            Button(intent: PlayerPlayNextIntent()) {
                                Image("player_next_white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.horizontal, -5)
                            }.buttonStyle(.plain)
                        }else{
                            Button(action: {
                                AppGroupsShared.setValue("playPrev", forKey: DataKeys.udKey_control_command)
                            }) {
                                Image("player_prev_white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.horizontal, -5)
                            }
                            
                            Button(action: {
                                AppGroupsShared.setValue("togglePlayPause", forKey: DataKeys.udKey_control_command)
                            }) {
                                Image(isPlaying ? "player_pause_white" : "player_play_white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 45, height: 45)
                                    .padding(.horizontal, 8)
                            }
                            
                            Button(action: {
                                AppGroupsShared.setValue("playNext", forKey: DataKeys.udKey_control_command)
                            }) {
                                Image("player_next_white")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.horizontal, -5)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
    
    
}

struct PlayerStandardWidget: Widget {
    let kind: String = DataKeys.widget_kind_default.rawValue
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlayerStandardProvider()) { entry in
            if #available(iOS 17.0, *) {
                PlayerStandardEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PlayerStandardEntryView(entry: entry)
            }
        }
        .configurationDisplayName(NSLocalizedString("PlayerStandardWidgetDisplayName", comment: "On-screen Control"))
        .description(NSLocalizedString("PlayerStandardWidgetDescription", comment: "Track can be controlled on the screen"))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

//#Preview(as: .systemSmall) {
//    PlayerSmallWidget()
//} timeline: {
//    PlayerSmallWidget.Entry(isPlaying: false)
//    PlayerSmallWidget.Entry(isPlaying: true)
//}

//提供预览支持, 这几把玩意，没法用，我的开发环境是最新的，一定要用最新的iOS17才能支持
//struct ConfigurationAppIntent_Previews: PreviewProvider {
//   static var previews: some View {
//       Group {
//           PlayerSmallEntryView(entry: MusicEntry(date: Date(), songTitle: "Preview Song", artistName: "Preview Artist", isPlaying: false)).previewContext(WidgetPreviewContext(family: .systemSmall))
////           PlayerSmallEntryView(entry: MusicEntry(date: Date(), songTitle: "Preview Song", artistName: "Preview Artist", isPlaying: false)).previewContext(WidgetPreviewContext(family: .systemMedium))
////           PlayerSmallEntryView(entry: MusicEntry(date: Date(), songTitle: "Preview Song", artistName: "Preview Artist", isPlaying: false)).previewContext(WidgetPreviewContext(family: .systemLarge))
//       }
//   }
//}
