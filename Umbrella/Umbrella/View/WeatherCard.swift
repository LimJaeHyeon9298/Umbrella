//
//  WeatherCard.swift
//  Umbrella
//
//  Created by 임재현 on 7/18/24.
//

import UIKit
import SnapKit
import Then


class WeatherCard:UIView {
    private let weatherIcon = UIImageView()
    private let weatherLabel = UILabel()
    private let weatherState = UILabel()
    
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
        
        
        
        let vStack = UIStackView(arrangedSubviews: [weatherIcon,weatherLabel,weatherState])
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 5
        
        addSubview(vStack)
        vStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        
        
    }
    
    func updateStateText(_ text: String) {
        weatherState.text = text
    }
    
}
