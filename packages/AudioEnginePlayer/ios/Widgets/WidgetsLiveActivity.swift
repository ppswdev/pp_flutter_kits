//
//  WidgetsLiveActivity.swift
//  Widgets
//
//  Created by xiaopin on 2024/7/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct WidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}
@available(iOS 16.1, *)
struct WidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}
@available(iOS 16.1, *)
extension WidgetsAttributes {
    fileprivate static var preview: WidgetsAttributes {
        WidgetsAttributes(name: "World")
    }
}
@available(iOS 16.1, *)
extension WidgetsAttributes.ContentState {
    fileprivate static var smiley: WidgetsAttributes.ContentState {
        WidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WidgetsAttributes.ContentState {
         WidgetsAttributes.ContentState(emoji: "🤩")
     }
}

//#Preview("Notification", as: .content, using: WidgetsAttributes.preview) {
//   WidgetsLiveActivity()
//} contentStates: {
//    WidgetsAttributes.ContentState.smiley
//    WidgetsAttributes.ContentState.starEyes
//}
