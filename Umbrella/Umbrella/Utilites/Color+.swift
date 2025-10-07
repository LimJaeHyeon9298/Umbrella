//
//  Color+.swift
//  Umbrella
//
//  Created by 임재현 on 7/28/24.
//

import UIKit

extension UIColor {
    static let lightMode = UIColor(red: 169.5 / 255.0,
                                   green: 215.0 / 255.0,
                                   blue: 217.0 / 255.0,
                                   alpha: 1.0)
    
    
    static let darkMode = UIColor(red:  34.0 / 255.0,
                                  green: 34.0 / 255.0,
                                  blue:  34.0 / 255.0,
                                  alpha: 1.0)
   
//    static let lightModeTabBar = UIColor(red: 149.0 / 255.0,
//                                         green: 195.0 / 255.0,
//                                         blue: 197.0 / 255.0,
//                                         alpha: 1.0)

//    static let darkModeTabBar = UIColor(red: 54.0 / 255.0,
//                                        green: 54.0 / 255.0,
//                                        blue: 54.0 / 255.0,
//                                        alpha: 1.0)
    
    static let darkModeTabBar2 = UIColor(red: 94.0 / 255.0,
                                         green: 89.0 / 255.0,
                                         blue: 98.0 / 255.0,
                                        alpha: 1.0)
    
    static let darkModeTabBar3 = UIColor(red: 239 / 255.0,
                                         green: 226 / 255.0,
                                         blue: 250 / 255.0,
                                        alpha: 1.0)
    
    
    static let darkModeTabBar = UIColor(red: 195 / 255.0,
                                         green: 209 / 255.0,
                                         blue: 128 / 255.0,
                                        alpha: 1.0)
    
    
    static let lightModeTabBar = UIColor(red: 221 / 255.0,
                                         green: 255 / 255.0,
                                         blue: 170 / 255.0,
                                        alpha: 1.0)
 
 
    }



extension NSString {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return ceil(boundingBox.height)
    }
}




//extension CommunityDetailViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
//       
//        
//        self.imagePageCount.text = "\(pageIndex + 1)/\(self.contentImages.count)"
//    }
//}
