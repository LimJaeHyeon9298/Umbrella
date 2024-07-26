//
//  WeatherCard.swift
//  Umbrella
//
//  Created by 임재현 on 7/18/24.
//

import UIKit
import SnapKit
import Then
import FLAnimatedImage


class WeatherCard:UIView {
    private let weatherIcon = UIImageView()
    private let weatherLabel = UILabel()
    private let weatherState = UILabel()
    
//    private let weatherIcon = FLAnimatedImageView().then {
//             $0.contentMode = .scaleAspectFit
//        $0.backgroundColor = .lightGray
//         }
    
    init(iconImage:UIImage,labelText:String,stateText:String) {
        super.init(frame: .zero)
        setupViews(iconImage: iconImage, labelText: labelText, stateText: stateText)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(iconImage:UIImage,labelText:String,stateText:String) {
        
        self.weatherIcon.image = iconImage
        
        weatherIcon.snp.makeConstraints { $0.width.height.equalTo(40) }
        weatherLabel.text = labelText
        weatherLabel.textAlignment = .center
        weatherState.text = stateText
        weatherState.textAlignment = .center
        weatherIcon.tintColor = .blue
       
//        if let gifPath = Bundle.main.path(forResource: "free-animated-icon-umbrella-6455007", ofType: "gif") {
//                    let gifURL = URL(fileURLWithPath: gifPath)
//                    do {
//                        let gifData = try Data(contentsOf: gifURL)
//                        let animatedImage = FLAnimatedImage(animatedGIFData: gifData)
//                        weatherIcon.animatedImage = animatedImage
//                    } catch {
//                        print("GIF 파일을 로드하는 데 실패했습니다: \(error)")
//                    }
//                }
         
       
        let vStack = UIStackView(arrangedSubviews: [weatherIcon,weatherLabel,weatherState])
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 5
        
        addSubview(vStack)
        vStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        
        self.backgroundColor = .lightGray
                self.layer.masksToBounds = true
                self.layer.cornerRadius = 30
        
        
    }
    
    func updateStateText(_ text: String) {
        weatherState.text = text
    }
   
   
    
}
