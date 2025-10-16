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
        $0.image = UIImage(named: "joy-stamp-pGQbWXBC1dA-unsplash")
    }
    
    var titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.boldSystemFont(ofSize: 28)
        $0.textAlignment = .center
        $0.text = "빗소리"
        
    }
    
    private var progressView = UIProgressView().then {
        $0.progressTintColor = .systemBlue
        $0.trackTintColor = .systemGray5
        $0.layer.cornerRadius = 2
        $0.clipsToBounds = true
        $0.progress = 0.0
    }
    
    private var currentTimeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.text = "0:00"
    }
    
    private var totalTimeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.text = "0:00"
    }
    
    private var playPauseButton = UIButton().then {
        
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        $0.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        $0.setImage(UIImage(systemName: "pause.fill", withConfiguration: config), for: .selected)
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFill
    }
    
    private var previousButton = UIButton().then {
        $0.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    private var nextButton = UIButton().then {
        $0.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
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
        self.view.addSubview(progressView)
        self.view.addSubview(currentTimeLabel)
        self.view.addSubview(totalTimeLabel)
        self.view.addSubview(previousButton)
        self.view.addSubview(playPauseButton)
        self.view.addSubview(nextButton)
                
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
        
        progressView.snp.makeConstraints {
             $0.top.equalTo(titleLabel.snp.bottom).offset(32)
             $0.leading.equalToSuperview().offset(40)
             $0.trailing.equalToSuperview().offset(-40)
             $0.height.equalTo(4)
         }
        
        currentTimeLabel.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(8)
            $0.leading.equalTo(progressView)
        }
        
        totalTimeLabel.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(8)
            $0.trailing.equalTo(progressView)
        }
        
        playPauseButton.snp.makeConstraints {
            $0.top.equalTo(currentTimeLabel.snp.bottom).offset(32)
            $0.centerX.equalTo(progressView)
            $0.size.equalTo(40)
        }
        
        previousButton.snp.makeConstraints {
            $0.centerY.equalTo(playPauseButton)
            $0.trailing.equalTo(playPauseButton.snp.leading).offset(-24)
            $0.size.equalTo(35)
        }

        nextButton.snp.makeConstraints {
            $0.centerY.equalTo(playPauseButton)
            $0.leading.equalTo(playPauseButton.snp.trailing).offset(24)
            $0.size.equalTo(35)
        }
    }
    
    private func setupBinds() {
        
    }
    
    private func setAddTargets() {
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    @objc func enableDarkmode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let theme = isDarkMode ? Theme.dark : Theme.light
        self.view.backgroundColor = theme.backgroundColor
    }
    
    @objc func playPauseButtonTapped() {}
    @objc func previousButtonTapped() {}
    @objc func nextButtonTapped() {}
}
