//
//  RainSoundPlayerViewController.swift
//  Umbrella
//
//  Created by 임재현 on 10/7/25.
//

import UIKit
import SnapKit
import Then

class RainSoundPlayerViewController: UIViewController {
    
    private var rainImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
    }
    
    var titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.boldSystemFont(ofSize: 28)
        $0.textAlignment = .center
        $0.text = "빗소리"
        
    }
    
    private var isDarkMode: Bool {
            return UserDefaults.standard.bool(forKey: "isDarkMode")
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBinds()
        
        let name = Notification.Name("darkModeHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkmode), name: name, object: nil)
    }
}

extension RainSoundPlayerViewController {
    private func setupUI() {
        self.view.addSubview(rainImageView)
        self.view.addSubview(titleLabel)
        rainImageView.backgroundColor = .red
        
        self.view.backgroundColor = isDarkMode ? Theme.dark.backgroundColor : Theme.light.backgroundColor
    }
    
    private func setupConstraints() {
        rainImageView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(240)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(rainImageView.snp.bottom).offset(16)
            $0.centerX.equalTo(rainImageView)
        }
    }
    
    private func setupBinds() {
        
    }
    
    @objc func enableDarkmode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let theme = isDarkMode ? Theme.dark : Theme.light
        self.view.backgroundColor = theme.backgroundColor
    }
}
