//
//  SwiftUIExtensions.swift
//  SwiftAudioEnginePlayer
//
//  Created by xiaopin on 2024/7/27.
//

import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

//extension View {
//     func widgetBackground() -> some View {
//         if #available(iOSApplicationExtension 17.0, *) {
//             return containerBackground(for: .widget) {
//                 Color(red: 0.988, green: 0.416, blue: 0.239, opacity: 1)
//             }
//         } else {
//             if #available(iOSApplicationExtension 15.0, *) {
//                 return background {
//                     Color(red: 0.988, green: 0.416, blue: 0.239, opacity: 1)
//                 }
//             } else {
//                 // Fallback on earlier versions
//             }
//         }
//    }
//}
