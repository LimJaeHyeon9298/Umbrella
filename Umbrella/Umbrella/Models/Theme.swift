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
    let backgroundImage:UIImage
    
    
    static let light = Theme(textColor: .black, backgroundColor: .white,backgroundImage: #imageLiteral(resourceName: "frame-harirak-5Q5jtb1SEVo-unsplash") )
    static let dark = Theme(textColor: .white, backgroundColor: .black,backgroundImage: #imageLiteral(resourceName: "nick-nice-ve-R7PCjJDk-unsplash") )
    
    
    
    
}
