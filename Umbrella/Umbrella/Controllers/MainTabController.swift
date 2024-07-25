//
//  MainTabController.swift
//  Umbrella
//
//  Created by 임재현 on 6/21/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa


final class MainTabController:UIViewController {
    let mainViewModel = MainViewModel()
    let settingViewModel = SettingViewModel()
    let soundViewModel = RainSoundViewModel()
    let mapViewModel = MapViewModel()
    private var isHidden = false
    private var isDarkMode: Bool {
           return UserDefaults.standard.bool(forKey: "isDarkMode")
       }
    fileprivate let tabBar = CustomTabBar()
    private var childVCs = [UIViewController]()
    private let disposeBag = DisposeBag()
    
    private lazy var backgroundImage = UIImageView().then {
       
        let theme = isDarkMode ? Theme.dark : Theme.light

       
        $0.image = theme.backgroundImage
    }
        
    
   
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setUpTabBarControllers()
        setUpBind() // 탭 이벤트 바인딩 호출
        let name = Notification.Name("darkModeHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkmode), name: name, object: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func enableDarkmode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let theme = isDarkMode ? Theme.dark : Theme.light        //view.backgroundColor = theme.backgroundColor
        view.backgroundColor = theme.backgroundColor
        self.backgroundImage.image = theme.backgroundImage

    }
    
    private func setUp() {
        view.backgroundColor = isDarkMode ? Theme.dark.backgroundColor : Theme.light.backgroundColor
        view.addSubview(tabBar)
        updateTheme()
        tabBar.backgroundColor = .red

        tabBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom) // 안전 영역 하단에 맞춤
            $0.height.equalTo(75) // 탭바의 높이를 50포인트로 설정
            
        }
        tabBar.layer.cornerRadius = 40 // 모서리 둥글기를 20포인트로 설정
        tabBar.layer.masksToBounds = true // 뷰의 경계를 넘어가는 내용을 잘라냄
    }
    private func setUpTabBarControllers() {
        tabBar.selectedIndex = 1
        // Enum에 정의된 각 탭 아이   @objc private 템에 대응하는 뷰 컨트롤러 생성
        tabBar.tabItems.forEach { item in
            let vc: UIViewController
            switch item {
            case .main:
                let mainVC = MainViewController(viewModel: mainViewModel,mapViewModel: mapViewModel)
                vc = UINavigationController(rootViewController: mainVC)
               // vc = MainViewController()  // 메인 뷰 컨트롤러
            case .setting:
                let settingVC = SettingViewController(viewModel: settingViewModel, mapViewModel: mapViewModel)
                vc = UINavigationController(rootViewController: settingVC)
               // vc = SettingViewController()  // 설정 뷰 컨트롤러
            case .sound:
                let soundVC = RainSoundViewController(viewModel: soundViewModel)
                vc = UINavigationController(rootViewController: soundVC)
             //   vc = RainSoundViewController()  // 사운드 설정 뷰 컨트롤러
            }
            
            // 뷰 컨트롤러의 배경색과 타이틀 설정
            vc.view.backgroundColor = .white
            
           
            
            
            
            //let imageView = UIImageView(image:Theme.light.backgroundImage)
            backgroundImage.contentMode = .scaleAspectFill
               view.insertSubview(backgroundImage, at: 0) // 이미지 뷰를 뷰 계층에서 가장 아래로 추가
//
            backgroundImage.snp.makeConstraints { make in
                   make.edges.equalToSuperview()
               }
            
           //     view.addSubview(UIImageView(image: Theme.light.backgroundImage))
            
           // addLabel(in: vc, text: String(describing: item))

            // 뷰 컨트롤러를 자식으로 추가하고 뷰 계층에 포함
            addChild(vc)
            view.addSubview(vc.view)
            vc.didMove(toParent: self)

            // 뷰 컨트롤러 뷰의 제약 조건 설정
            vc.view.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.bottom.equalTo(tabBar.snp.top)
            }

            // 생성된 뷰 컨트롤러를 배열에 추가
            childVCs.append(vc)
           
        }

        // 첫 번째 뷰 컨트롤러를 화면 전면에 표시
        if let firstView = childVCs.first?.view {
            view.bringSubviewToFront(firstView)
        }
        
        
    }
    
    private func updateTheme() {
            let theme = isDarkMode ? Theme.dark : Theme.light
            view.backgroundColor = theme.backgroundColor
            backgroundImage.image = theme.backgroundImage
        }


       
       deinit {
           NotificationCenter.default.removeObserver(self)
       }

    private func setUpBind() {
            // 초기 탭 인덱스를 설정하고 MainViewController를 표시
            tabBar.selectedIndex = 1
            let initialVC = childVCs[1]
            view.bringSubviewToFront(initialVC.view)
            view.bringSubviewToFront(tabBar)
            backgroundImage.isHidden = !(initialVC is UINavigationController && (initialVC as! UINavigationController).topViewController is MainViewController)
            
            // 탭바의 tabButton Observable을 구독하여 인덱스에 따른 처리를 수행
            tabBar.rx.tabButton
                .bind { [weak self] index in
                    guard let self = self, self.childVCs.indices.contains(index) else { return }
                    
                    // 현재 화면에 표시된 뷰 컨트롤러를 전환
                    let targetVC = self.childVCs[index]
                    self.view.bringSubviewToFront(targetVC.view)
                    
                    // 선택된 인덱스 업데이트
                    self.tabBar.selectedIndex = index
                    if targetVC is UINavigationController, (targetVC as! UINavigationController).topViewController is MainViewController {
                        self.backgroundImage.isHidden = false
                    } else {
                        self.backgroundImage.isHidden = true
                    }
                }
                .disposed(by: disposeBag)
        }
      
    
   
}

extension Reactive where Base: MainTabController {
    var changeIndex: Binder<Int> {
        Binder(base) { base, index in
            base.tabBar.rx.changeIndex.onNext(index)
        }
    }
    
    
    
    
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
