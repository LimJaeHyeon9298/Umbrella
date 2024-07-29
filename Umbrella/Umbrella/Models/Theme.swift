//
//  Theme.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/23.
//

import UIKit

struct Theme {
    let textColor: UIColor
    let backgroundColor: UIColor
    let tabBarColor:UIColor
   
    static let light = Theme(textColor: .black, backgroundColor: .lightMode,tabBarColor: .lightModeTabBar )
    static let dark = Theme(textColor: .white, backgroundColor: .darkMode,tabBarColor: .darkModeTabBar )
    
}

