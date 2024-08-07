//
//  extenstions.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/15.
//

import UIKit
//import JGProgressHUD
import MapKit





extension UIViewController {
    
    
    //static let hud = JGProgressHUD(style: .dark)
    
    
    func configureGradientLayer() {
        
        
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemPurple.cgColor,UIColor.systemBlue.cgColor]
        gradient.locations = [0,1]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
        
        
        
        
        
    }
//
//    func showLoader(_ show: Bool) {
//
//        view.endEditing(true)
//
//        if show {
//            UIViewController.hud.show(in: view)
//
//
//        } else {
//
//            UIViewController.hud.dismiss()
//
//        }
//
//
//    }
    
    
    
}





extension UIButton {
    
    
    func attributedTitle(firstPart:String,secondPart:String) {
        
        let atts: [NSAttributedString.Key:Any] = [.foregroundColor: UIColor(white: 1, alpha: 0.87),
                                                  .font:UIFont.systemFont(ofSize: 16)]
        
        let attributedTitle = NSMutableAttributedString(string: "\(firstPart)  ",attributes: atts)
        
        let boldAtts: [NSAttributedString.Key:Any] = [.foregroundColor: UIColor(white: 1, alpha: 0.7),
                                                      .font:UIFont.boldSystemFont(ofSize: 16)]
        
        attributedTitle.append(NSMutableAttributedString(string: secondPart,attributes: boldAtts))
        
        setAttributedTitle(attributedTitle, for: .normal)
        
        
    }
    
    
    
}










extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func center(inView view: UIView, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }
    
    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
        }
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(_ width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func fillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.topAnchor, left: view.leftAnchor,
               bottom: view.bottomAnchor, right: view.rightAnchor)
    }
}

extension UIScrollView {
    func updateContentSize() {
        let unionCalculatedTotalRect = recursiveUnionInDepthFor(view: self)
        
        // 계산된 크기로 컨텐츠 사이즈 설정
        self.contentSize = CGSize(width: self.frame.width, height: unionCalculatedTotalRect.height+50)
    }
    
    private func recursiveUnionInDepthFor(view: UIView) -> CGRect {
        var totalRect: CGRect = .zero
        
        // 모든 자식 View의 컨트롤의 크기를 재귀적으로 호출하며 최종 영역의 크기를 설정
        for subView in view.subviews {
            totalRect = totalRect.union(recursiveUnionInDepthFor(view: subView))
        }
        
        // 최종 계산 영역의 크기를 반환
        return totalRect.union(view.frame)
    }
}

extension String {
    func stringFromDate() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: now)
    }
}

extension MKMapItem {
    func addressLine() -> String {
        var addressParts: [String] = []
        
        if let street = self.placemark.thoroughfare {
            if let nr = self.placemark.subThoroughfare {
                addressParts.append("\(street) \(nr)")
            } else {
                addressParts.append(street)
            }
        }
        
        if let city = self.placemark.locality {
            addressParts.append(city)
        }
        
        if let postalCode = self.placemark.postalCode {
            addressParts.append(postalCode)
        }
        
        if addressParts.isEmpty {
            return "-"
        } else {
            return addressParts.joined(separator: ", ")
        }
    }
    
    func countryLine() -> String {
        var countryParts: [String] = []
        
        if let countryCode = self.placemark.isoCountryCode {
            countryParts.append(countryCode)
        }
        
        if let country = self.placemark.country {
            countryParts.append(country)
        }
        
        if countryParts.isEmpty {
            return "-"
        } else {
            return countryParts.joined(separator: ", ")
        }
    }
}
