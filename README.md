# pp_flutter_kits

## 创建插件工程

### 纯Dart库插件

``` bash
flutter create --template=package 插件名
```

### 原生插件

``` bash
flutter create --template=plugin --platforms=android,ios 插件名
#--org 指定组织
flutter create --org com.ppsw --template=plugin --platforms=android,ios 插件名

flutter create --org com.ppsw --template=plugin --platforms=android,ios,web,macos,windows,linux 插件名
```

### 创建示例工程

``` bash
flutter create example
```

## 插件说明

pp_kits: 我的工具箱
pp_fan_menu: 高度自定义的扇形菜单
pp_progress_bar: 高度自定义进度条
pp_spin_wheel: 高度自定义旋转轮盘
pp_purchase: 内购订阅
pp_guides: 新功能引导(规划中)
pp_tutorial: 新功能教程 (规划中)
pp_pay: 支付宝、微信支付、苹果支付等(规划中)
pp_audio_player: 音频播放器(规划中)
pp_video_player: 视频播放器(规划中)

audio_engine_player: 音频引擎播放
AudioEnginePlayer: 音频引擎播放(原生示例)
    播放文件必须是本地文件，或者下载到沙盒文件
custom_background_scaffold: 自定义背景的Scaffold
ndt7_service: NDT7测速服务
