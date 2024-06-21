//
//  MainTabController.swift
//  Umbrella
//
//  Created by 임재현 on 6/21/24.
//

import UIKit

class MainTabController:UITabBarController {
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        self.selectedIndex = 2
    }
    
    func templateNavigationController(image:UIImage?,rootViewController:UIViewController) -> UINavigationController {
        
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        nav.navigationBar.barTintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance
        
        return nav
        
    }
    
    func configureViewControllers() {
        
        let mainVC = MainViewController()
        let precipitationVC = PrecipitationViewController()
        let rainSoundVC = RainSoundViewController()
        let searchVC = SearchViewController()
        let settingVC = SettingViewController()
        
        let nav1 = templateNavigationController(image: UIImage(systemName: "person.fill"), rootViewController: rainSoundVC)
        let nav2 = templateNavigationController(image: UIImage(systemName: "person.fill"), rootViewController: precipitationVC)
        let nav3 = templateNavigationController(image: UIImage(systemName: "person.fill"), rootViewController: mainVC)
        let nav4 = templateNavigationController(image: UIImage(systemName: "person.fill"), rootViewController: searchVC)
        let nav5 = templateNavigationController(image: UIImage(systemName: "person.fill"), rootViewController: settingVC)
        
        nav1.tabBarItem.title = "메인"
        nav2.tabBarItem.title = "메인"
        nav3.tabBarItem.title = "메인"
        nav4.tabBarItem.title = "메인"
        nav5.tabBarItem.title = "메인"
        
        viewControllers = [nav1,nav2,nav3,nav4,nav5]
       
    }
    
    
    
    
}


