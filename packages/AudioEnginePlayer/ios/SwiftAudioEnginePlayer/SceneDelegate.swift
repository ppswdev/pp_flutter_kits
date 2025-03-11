//
//  SceneDelegate.swift
//  SwiftAudioEqualizer
//
//  Created by xiaopin on 2024/7/17.
//

import UIKit
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let winScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: winScene)
        
        //let vc = EqualizerViewController()
        let vc = AppleMusicPlayerExampleViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        let url = urlContext.url
        
        // 处理URL Scheme
        if url.scheme == "myapp" {
            handleCustomURL(url)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    private func handleCustomURL(_ url: URL) {
        // 解析URL并执行相应的操作
        if let action = url.host {
            switch action {
            case "prev":
                // 执行上一首操作
                print("Previous track")
                // 在这里添加你的逻辑来处理上一首操作
                break
            case "togglePlayPause":
                // 执行播放/暂停操作
                print("Toggle play/pause")
                // 在这里添加你的逻辑来处理播放/暂停操作
                break
            case "next":
                // 执行下一首操作
                print("Next track")
                // 在这里添加你的逻辑来处理下一首操作
                break
            default:
                break
            }
        }
        
        // 手动刷新Timeline
        WidgetCenter.shared.reloadAllTimelines()
    }
}

