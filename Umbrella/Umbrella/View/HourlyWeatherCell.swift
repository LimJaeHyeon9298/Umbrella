//
//  HoulryWeatherCell.swift
//  Umbrella
//
//  Created by 임재현 on 7/18/24.
//

import UIKit
import SnapKit

class HourlyWeatherCell:UICollectionViewCell {
    static let identifier = "HourlyWeatherCell"
    
    private let timeLabel = UILabel().then {$0.textColor = .black}
    private let iconImageView = UIImageView()
    private let precipitationLabel = UILabel().then {$0.textColor = .black}
 
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
        }
        
        addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        addSubview(precipitationLabel)
        
        precipitationLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        
    }
    
    func configure(with weather: HourlyWeather) {
           timeLabel.text = weather.time
           iconImageView.image = weather.icon
           precipitationLabel.text = weather.precipitationChance
    }
}
