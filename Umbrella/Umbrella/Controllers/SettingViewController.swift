//
//  ViewController6.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/15.
//


import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa


    
class SettingViewController:UIViewController {

    let userDefaults = UserDefaults.standard
    
    let tableView = UITableView().then {
        $0.register(SettingCell.self, forCellReuseIdentifier: SettingCell.reuseIdentifier)
    }
    
    let viewModel:SettingViewModel
    let mapViewModel:MapViewModel
    let disposeBag = DisposeBag()

    //MARK: - LifeCycle
  
    init(viewModel:SettingViewModel,mapViewModel:MapViewModel) {
        self.viewModel = viewModel
        self.mapViewModel = mapViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUpTableView()
        binds()
        tableView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adjustTableViewScroll()
    }
    //MARK: - Functions

    func adjustTableViewScroll() {
        let totalHeight = tableView.contentSize.height
        let tableViewHeight = tableView.frame.size.height
        tableView.isScrollEnabled = totalHeight > tableViewHeight
    }
    func setUpTableView() {
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
        
        }
        
        tableView.separatorStyle = .none
    }
    
    
    func binds() {

        viewModel.items
            .bind(to: tableView.rx.items(cellIdentifier: SettingCell.reuseIdentifier, cellType: SettingCell.self)) { row, cellType, cell in
                cell.configure(cellType: cellType, viewModel: self.viewModel)
                cell.accessoryButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.handleAccessoryButtonTap(for: cellType)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
           tableView.rx.modelSelected(SettingCellType.self)
               .subscribe(onNext: { cellType in
                   print("Selected \(cellType.title)")
               })
               .disposed(by: disposeBag)

        
        viewModel.theme
               .subscribe(onNext: { [weak self] theme in
                   self?.updateUI(with: theme)
                   self?.tableView.reloadData()  // 테마 변경시 테이블 뷰 전체 업데이트
               })
               .disposed(by: disposeBag)
        
        
    }
    
    private func updateUI(with theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        navigationController?.navigationBar.barTintColor = theme.backgroundColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: theme.textColor]
        tableView.backgroundColor = theme.backgroundColor
    }
   
   
    
    //MARK: - Actions
    
    private func handleAccessoryButtonTap(for cellType: SettingCellType) {
        switch cellType {
        case .alarm:
            navigateToNotificationViewController()
        case .location:
            navigateToMapViewController()
        default:
            break
        }
    }
    
    private func navigateToNotificationViewController() {
        let controller = NotificationViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            print("Navigation controller is nil")
        }
        print("button Tapped")
    }
    
    private func navigateToMapViewController() {
       
        let controller = MapViewController(viewModel: mapViewModel)
        if let navigationController = self.navigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            print("Navigation controller is nil")
        }
        print("Another button tapped")
    }
}

extension SettingViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
