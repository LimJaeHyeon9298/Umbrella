//
//  SceneDelegate.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/15.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        UILabel.appearance().textColor = UIColor.white
        window?.rootViewController = MainTabController()
        window?.makeKeyAndVisible()
    }
}
