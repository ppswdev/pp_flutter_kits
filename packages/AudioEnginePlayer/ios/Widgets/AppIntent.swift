//
//  AppIntent.swift
//  Widgets
//
//  Created by xiaopin on 2024/7/26.
//

import WidgetKit
import AppIntents

@available(iOS 17.0, *)
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}

@available(iOS 16, *)
struct PlayerPlayPrevIntent: AppIntent {
    static var title: LocalizedStringResource = "PlayerPlayPrevIntent"
    
    func perform() async throws -> some IntentResult {
    
        AppGroupsShared.setValue("playPrev", forKey: DataKeys.udKey_control_command)
        return .result()
    }
}

@available(iOS 16.0, *)
struct PlayerPlayPauseIntent: AppIntent {
    static var title: LocalizedStringResource = "PlayerPlayPauseIntent"
    
    func perform() async throws -> some IntentResult {
    
        AppGroupsShared.setValue("togglePlayPause", forKey: DataKeys.udKey_control_command)
        return .result()
    }
}

@available(iOS 16, *)
struct PlayerPlayNextIntent: AppIntent {
    static var title: LocalizedStringResource = "PlayerPlayPauseIntent"
    
    func perform() async throws -> some IntentResult {
    
        AppGroupsShared.setValue("playNext", forKey: DataKeys.udKey_control_command)
        return .result()
    }
}
