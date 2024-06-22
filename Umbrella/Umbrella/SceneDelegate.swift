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
        window?.rootViewController = MainTabController()
        window?.makeKeyAndVisible()
        
      
        
    }
    
  
    func sceneDidDisconnect(_ scene: UIScene) {
    
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
     
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
     
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }


}
//


//import UIKit
//
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//    
//    var window: UIWindow?
//    
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        
//        window = UIWindow(windowScene: windowScene)
//        
//        let firstViewController = MainViewController()
//        firstViewController.view.backgroundColor = .gray
//        firstViewController.tabBarItem.image = UIImage(systemName: "person.fill")
//        let firstNavi = UINavigationController(rootViewController: firstViewController)
//        
//        let secondViewController = PrecipitationViewController()
//        secondViewController.view.backgroundColor = .darkGray
//        secondViewController.title = "Second"
//        let secondNavi = UINavigationController(rootViewController: secondViewController)
//        
//        let thirdViewController = SearchViewController()
//        thirdViewController.view.backgroundColor = .lightGray
//        thirdViewController.title = "Third"
//        let thirdNavi = UINavigationController(rootViewController: thirdViewController)
//        
//        let customTabBarController = CustomTabBarController()
//        customTabBarController.setViewControllers([firstNavi, secondNavi, thirdNavi])
//        
//        window?.rootViewController = customTabBarController
//        window?.makeKeyAndVisible()
//    }
//}
