//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by xiaopin on 2024/7/26.
//

import WidgetKit
import SwiftUI

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        //可以添加最多5个Widget, 每个可以设置3个显示模式
        PlayerStandardWidget()
        //Widgets()
        //WidgetsLiveActivity()
    }
}
