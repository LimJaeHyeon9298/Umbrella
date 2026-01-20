//
//  RainSoundPlayerViewController.swift
//  Umbrella
//
//  Created by 임재현 on 10/7/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class RainSoundPlayerViewController: UIViewController {
    
    private let viewModel: RainSoundPlayerViewModel
    private let disposeBag = DisposeBag()
    
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
    
    private var shuffleButton = UIButton(type: .system).then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        $0.setImage(UIImage(systemName: "shuffle", withConfiguration: config), for: .normal)
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
        $0.alpha = 0.6
    }
    
    private var repeatButton = UIButton(type: .system).then {
        let normalConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let selectedConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)  // 두껍게만
        
        $0.setImage(UIImage(systemName: "repeat", withConfiguration: normalConfig), for: .normal)
        $0.setImage(UIImage(systemName: "repeat.1", withConfiguration: selectedConfig), for: .selected)
        $0.tintColor = .white  // 흰색 고정
        $0.contentMode = .scaleAspectFit
        $0.alpha = 0.6
    }
    
    private var isDarkMode: Bool {
            return UserDefaults.standard.bool(forKey: "isDarkMode")
        }
    
    init(viewModel: RainSoundPlayerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBinds()
        setupNavigationBar()
        
        let name = Notification.Name("darkModeHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkmode), name: name, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.isNavigationBarHidden = false  // 네비게이션 바 보이기
        }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            // 화면 나갈 때 재생 중이면 멈춤 (선택사항)
            // viewModel.playPauseTrigger.accept(())
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
        self.view.addSubview(shuffleButton)
        self.view.addSubview(repeatButton)
        
        self.view.backgroundColor = isDarkMode ? Theme.dark.backgroundColor : Theme.light.backgroundColor
        
        // ProgressView에 탭 제스처 추가 (seek 기능)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProgressTap(_:)))
        progressView.addGestureRecognizer(tapGesture)
        progressView.isUserInteractionEnabled = true
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
        
        shuffleButton.snp.makeConstraints {
            $0.centerY.equalTo(playPauseButton)
            $0.trailing.equalTo(previousButton.snp.leading).offset(-20)
            $0.size.equalTo(20)
        }
        
        repeatButton.snp.makeConstraints {
            $0.centerY.equalTo(playPauseButton)
            $0.leading.equalTo(nextButton.snp.trailing).offset(20)
            $0.size.equalTo(20)
        }
    }
    
    private func setupBinds() {
        // MARK: - Outputs (ViewModel → UI)
        
        // 앨범 이미지 바인딩
        viewModel.albumImage
            .bind(to: rainImageView.rx.image)
            .disposed(by: disposeBag)
        
        // 제목 바인딩
        viewModel.titleText
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 재생/일시정지 상태 바인딩
        viewModel.isPlaying
            .bind(to: playPauseButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        // 현재 시간 바인딩
        viewModel.currentTimeText
            .bind(to: currentTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 총 시간 바인딩
        viewModel.totalTimeText
            .bind(to: totalTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 프로그레스 바인딩
        viewModel.progress
            .bind(to: progressView.rx.progress)
            .disposed(by: disposeBag)
        
        viewModel.isRepeatEnabled
            .bind(to: repeatButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        // Repeat 버튼 색상
//        viewModel.isRepeatEnabled
//            .map { $0 ? UIColor.systemBlue : UIColor.white }
//            .bind(to: repeatButton.rx.tintColor)
//            .disposed(by: disposeBag)
        
        // Repeat 버튼 투명도
//        viewModel.isRepeatEnabled
//            .map { $0 ? 1.0 : 0.6 }
//            .bind(to: repeatButton.rx.alpha)
//            .disposed(by: disposeBag)
        
        
        // MARK: - Inputs (UI → ViewModel)
        
        // Play/Pause 버튼
        playPauseButton.rx.tap
            .bind(to: viewModel.playPauseTrigger)
            .disposed(by: disposeBag)
        
        // Previous 버튼 (나중에 구현)
        previousButton.rx.tap
            .bind(to: viewModel.previousTrigger)
            .disposed(by: disposeBag)
        
        // Next 버튼 (나중에 구현)
        nextButton.rx.tap
            .bind(to: viewModel.nextTrigger)
            .disposed(by: disposeBag)
        
        repeatButton.rx.tap
            .bind(to: viewModel.repeatTrigger)
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
            // 네비게이션 바 색상 설정
            navigationController?.navigationBar.tintColor = .white
            
            // 투명 배경 (선택사항)
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = isDarkMode ? Theme.dark.backgroundColor : Theme.light.backgroundColor
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    
    // MARK: - Actions
    @objc private func handleProgressTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: progressView)
        let progress = Float(location.x / progressView.bounds.width)
        viewModel.seekTo.accept(progress)
    }
    
    @objc func enableDarkmode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let theme = isDarkMode ? Theme.dark : Theme.light
        self.view.backgroundColor = theme.backgroundColor
    }
}
