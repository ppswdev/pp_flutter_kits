//
//  Widgets2LiveActivity.swift
//  Widgets2
//
//  Created by xiaopin on 2025/2/15.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Widgets2Attributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Widgets2LiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Widgets2Attributes.self) { context in
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

extension Widgets2Attributes {
    fileprivate static var preview: Widgets2Attributes {
        Widgets2Attributes(name: "World")
    }
}

extension Widgets2Attributes.ContentState {
    fileprivate static var smiley: Widgets2Attributes.ContentState {
        Widgets2Attributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Widgets2Attributes.ContentState {
         Widgets2Attributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Widgets2Attributes.preview) {
   Widgets2LiveActivity()
} contentStates: {
    Widgets2Attributes.ContentState.smiley
    Widgets2Attributes.ContentState.starEyes
}
