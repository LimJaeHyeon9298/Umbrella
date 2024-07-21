//
//  SettingCell.swift
//  Umbrella
//
//  Created by 임재현 on 6/23/24.
//

import UIKit
import SnapKit
import RxSwift



enum SettingCellType {
    case darkMode
    case alarm
    case location
    
    var title: String {
        switch self {
        case .darkMode:
            return "다크모드"
        case .alarm:
            return "알림"
        case .location:
            return "지역선택"
        }
    }
    
}

class SettingCell:UITableViewCell {
    static let reuseIdentifier = "SettingCell"
    var disposeBag = DisposeBag()
    
    var iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "Vector")?.withRenderingMode(.alwaysTemplate)
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
    
    func configure(cellType: SettingCellType, viewModel: SettingViewModel) {
        titleLabel.text = cellType.title
        
        switch cellType {
        case .darkMode:
            accessoryButton.isHidden = true
            accessorySwitch.isHidden = false
            accessorySwitch.isOn = viewModel.isDarkModeEnabled.value
            
            // 구독을 생성하기 전에 이전 구독을 해제해야 합니다.
            disposeBag = DisposeBag()
            
            accessorySwitch.rx.isOn
                .skip(1) // 초기 값 로드 시 트리거 방지
                .distinctUntilChanged() // 값의 변화가 없다면 이벤트 발생 방지
                .bind(to: viewModel.isDarkModeEnabled)
                .disposed(by: disposeBag)
            
            viewModel.isDarkModeEnabled
                .subscribe(onNext: { [weak self] isDarkMode in
                    self?.updateUI(isDarkMode: isDarkMode)
                })
                .disposed(by: disposeBag)
            
        case .alarm:
            accessoryButton.isHidden = false
            accessorySwitch.isHidden = true
            
            viewModel.isDarkModeEnabled
                .subscribe(onNext: { [weak self] isDarkMode in
                    self?.updateUI(isDarkMode: isDarkMode)
                })
                .disposed(by: disposeBag)
        case .location:
            accessoryButton.isHidden = false
            accessorySwitch.isHidden = true
            
            viewModel.isDarkModeEnabled
                .subscribe(onNext: { [weak self] isDarkMode in
                    self?.updateUI(isDarkMode: isDarkMode)
                })
                .disposed(by: disposeBag)
        }
    }
    
    
    private func updateUI(isDarkMode: Bool) {
        backgroundColor = isDarkMode ? Theme.dark.backgroundColor : Theme.light.backgroundColor
        titleLabel.textColor = isDarkMode ? .white : .black
        iconImageView.tintColor = isDarkMode ? Theme.light.backgroundColor : Theme.dark.backgroundColor
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
