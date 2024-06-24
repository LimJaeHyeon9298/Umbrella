//
//  SettingCell.swift
//  Umbrella
//
//  Created by 임재현 on 6/23/24.
//

import UIKit
import SnapKit



enum SettingCellType {
    case darkMode
    case alarm
    
    var title: String {
        switch self {
        case .darkMode:
            return "다크모드"
        case .alarm:
            return "알림"
        }
    }
    
}




class SettingCell:UITableViewCell {
    static let reuseIdentifier = "SettingCell"
    
    var iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "Vector")
    }
    var titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    var accessorySwitch = UISwitch().then {
        $0.isHidden = true
    }
    var accessoryButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.isHidden = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpLayout() {
        [iconImageView, titleLabel, accessorySwitch, accessoryButton].forEach {
                   contentView.addSubview($0)
               }
        
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
        }
        
        accessoryButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        accessorySwitch.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
        self.selectionStyle = .none
    }
    
    func configure(cellType:SettingCellType) {
        titleLabel.text = cellType.title
        
        switch cellType {
            
        case .darkMode:
            accessoryButton.isHidden = false
            accessorySwitch.isHidden = true
        case .alarm:
            accessoryButton.isHidden = true
            accessorySwitch.isHidden = false
        }
    }
    
}
