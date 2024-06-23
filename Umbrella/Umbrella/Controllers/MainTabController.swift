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

//class MainTabController:UITabBarController {
//   
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureViewControllers()
//        self.selectedIndex = 2
//        let tabBarAppearance = UITabBarAppearance()
//          tabBarAppearance.configureWithOpaqueBackground()
//          tabBarAppearance.backgroundColor = UIColor.blue // 배경색을 파란색으로 설정
//
//          // iOS 15 이상의 버전에서는 아래와 같이 설정합니다.
//          if #available(iOS 15.0, *) {
//              self.tabBar.standardAppearance = tabBarAppearance
//              self.tabBar.scrollEdgeAppearance = tabBarAppearance
//          } else {
//              // iOS 15 미만의 버전에서는 기존 방식을 사용합니다.
//              self.tabBar.barTintColor = UIColor.blue
//          }
//        
//    }
//    
//    func templateNavigationController(image:UIImage?,rootViewController:UIViewController) -> UINavigationController {
//        
//        let nav = UINavigationController(rootViewController: rootViewController)
//        nav.tabBarItem.image = image
//        nav.navigationBar.barTintColor = .red
//        
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .white
//        nav.navigationBar.standardAppearance = appearance
//        nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance
//        
//        
//        
//        
//        return nav
//        
//    }
//    
//    func configureViewControllers() {
//        
//        let mainVC = MainViewController()
//        let precipitationVC = PrecipitationViewController()
//        let rainSoundVC = RainSoundViewController()
//        let searchVC = SearchViewController()
//        let settingVC = SettingViewController()
//        
//        let nav1 = templateNavigationController(image: UIImage(systemName: "person.fill"), rootViewController: rainSoundVC)
//        let nav2 = templateNavigationController(image: UIImage(systemName: "person.fill"), rootViewController: precipitationVC)
//        let nav3 = templateNavigationController(image: UIImage(systemName: "person.fill"), rootViewController: mainVC)
//        let nav4 = templateNavigationController(image: UIImage(systemName: "person.fill"), rootViewController: searchVC)
//        let nav5 = templateNavigationController(image: UIImage(systemName: "person.fill"), rootViewController: settingVC)
//        
//        nav1.tabBarItem.title = "메인"
//        nav2.tabBarItem.title = "메인"
//        nav3.tabBarItem.title = "메인"
//        nav4.tabBarItem.title = "메인"
//        nav5.tabBarItem.title = "메인"
//        
//        viewControllers = [nav1,nav2,nav3,nav4,nav5]
//     
//    }
//    
//    
//    
//    
//}
//
//


//import UIKit
//
//final class CustomTabBarController: UIViewController {
//    
//    private lazy var viewControllers: [UIViewController] = []
//    private lazy var buttons: [UIButton] = []
//    
//    
//    
//    
//    
//    private lazy var tabBarView: UIView = {
//        let view = UIView()
//        
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 35
//         
//        return view
//    }()
//    
//    var selectedIndex = 0 {
//        willSet {
//            previewsIndex = selectedIndex
//        }
//        didSet {
//            updateView()
//        }
//    }
//    private var previewsIndex = 0
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupTabBar()
//    }
//    
//    func setViewControllers(_ viewControllers: [UIViewController]) {
//        self.viewControllers = viewControllers
//        setupButtons()
//        updateView()
//    }
//    
//    private func setupTabBar() {
//        view.addSubview(tabBarView)
//        
//        tabBarView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -50),
//            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tabBarView.heightAnchor.constraint(equalToConstant: 90)
//        ])
//    }
//    
//    private func setupButtons() {
//        // 버튼의 넓이는 tab 개수에 맞춰서 유동적으로 변함
//        let buttonWidth = view.bounds.width / CGFloat(viewControllers.count)
//        
//        for (index, viewController) in viewControllers.enumerated() {
//            let button = UIButton()
//            button.tag = index
//            button.setTitle(viewController.title, for: .normal)
//            button.setTitleColor(.black, for: .normal)
//            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
//            tabBarView.addSubview(button)
//            
//            button.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                button.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor),
//                button.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor, constant: CGFloat(index) * buttonWidth),
//                button.widthAnchor.constraint(equalToConstant: buttonWidth),
//                button.heightAnchor.constraint(equalTo: tabBarView.heightAnchor)
//            ])
//            button.setImage(UIImage(systemName: "person.fill"), for: .normal)
//            buttons.append(button)
//        }
//    }
//    private func updateView() {
//        deleteView()
//        setupView()
//        
//        buttons.forEach { $0.isSelected = ($0.tag == selectedIndex) }
//    }
//        
//    private func deleteView() {
//        let previousVC = viewControllers[previewsIndex]
//        previousVC.willMove(toParent: nil)
//        previousVC.view.removeFromSuperview()
//        previousVC.removeFromParent()
//    }
//        
//    private func setupView() {
//        let selectedVC = viewControllers[selectedIndex]
//        
//        self.addChild(selectedVC)
//        view.insertSubview(selectedVC.view, belowSubview: tabBarView)
//        selectedVC.view.frame = view.bounds
//        selectedVC.didMove(toParent: self)
//    }
//    
//    @objc private func tabButtonTapped(_ sender: UIButton) {
//        selectedIndex = sender.tag
//    }
//}

final class MainTabController:UIViewController {
    fileprivate let tabBar = CustomTabBar()
    private var childVCs = [UIViewController]()
    private let disposeBag = DisposeBag()
    
    private var backgroundImage:UIImageView = {
        
        let ig = UIImageView()
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")

        let theme = isDarkMode ? Theme.dark : Theme.light
        ig.image = theme.backgroundImage
        return ig
        
    }()
    
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setUpTabBarControllers()
        setUpBind() // 탭 이벤트 바인딩 호출
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        view.backgroundColor = .blue
        view.addSubview(tabBar)
        tabBar.backgroundColor = .red
//        tabBar.snp.makeConstraints {
//            $0.leading.trailing.equalToSuperview()
//            $0.top.equalTo(view.snp.bottom).offset(-500)
//            $0.bottom.equalTo(view.snp.bottom).offset(300)
//        }
        
        tabBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom) // 안전 영역 하단에 맞춤
            $0.height.equalTo(75) // 탭바의 높이를 50포인트로 설정
            
        }
        tabBar.layer.cornerRadius = 40 // 모서리 둥글기를 20포인트로 설정
        tabBar.layer.masksToBounds = true // 뷰의 경계를 넘어가는 내용을 잘라냄
    }
    private func setUpTabBarControllers() {
        // Enum에 정의된 각 탭 아이템에 대응하는 뷰 컨트롤러 생성
        tabBar.tabItems.forEach { item in
            let vc: UIViewController
            switch item {
            case .main:
                vc = MainViewController()  // 메인 뷰 컨트롤러
            case .setting:
                vc = SettingViewController()  // 설정 뷰 컨트롤러
            case .sound:
                vc = RainSoundViewController()  // 사운드 설정 뷰 컨트롤러
            }
            
            // 뷰 컨트롤러의 배경색과 타이틀 설정
            vc.view.backgroundColor = .white
            
           
            
            
            
            //let imageView = UIImageView(image:Theme.light.backgroundImage)
            backgroundImage.contentMode = .scaleAspectFill
               view.insertSubview(backgroundImage, at: 0) // 이미지 뷰를 뷰 계층에서 가장 아래로 추가

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

    private func setUpBind() {
        // 탭바의 tabButton Observable을 구독하여 인덱스에 따른 처리를 수행
        tabBar.rx.tabButton
            .bind { [weak self] index in
                guard let self = self, self.childVCs.indices.contains(index) else { return }
                
                // 현재 화면에 표시된 뷰 컨트롤러를 전환
                let targetVC = self.childVCs[index]
                self.view.bringSubviewToFront(targetVC.view)
                
                // 선택된 인덱스 업데이트
                self.tabBar.selectedIndex = index
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
