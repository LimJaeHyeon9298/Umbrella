//
//  CumstomTabBar.swift
//  Umbrella
//
//  Created by 임재현 on 6/22/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

    
enum TabItem:Int,CaseIterable,Equatable {
    case sound
    case main
    case setting
    
    
    var normalImage:UIImage? {
        switch self {
        case .main:
            return UIImage(named: "free-icon-font-umbrella-3914416")
           
        case .setting:
            return UIImage(named: "free-icon-font-settings-3917035")
        case .sound:
            return UIImage(named: "free-icon-font-music-alt-3914938")
        }
    }
    
    var selectedImage:UIImage? {
        switch self {
        case .main:
            return UIImage(named: "free-icon-font-umbrella-3914522 (1)")
        case .setting:
            return UIImage(named: "free-icon-font-settings-3917110")
        case .sound:
            return UIImage(named:"free-icon-font-music-alt-3915153")
        }
    }
    
}

final class CustomTabBar:UIView {
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
    }
    
    private var buttons = [UIButton]()
    
    let tabItems = TabItem.allCases
    
     var selectedIndex = 0 {
        didSet {
            buttons.enumerated()
                .forEach { index,button in
                    button.isSelected = index == selectedIndex
                }
        }
    }
    private let disposeBag = DisposeBag()
    fileprivate var tabSubject = PublishSubject<Int>()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        tabItems.enumerated()
            .forEach { index,items in
                let button = UIButton().then {
                    $0.setImage(items.normalImage, for: .normal)
                    $0.setImage(items.selectedImage, for: .selected)
                }
                button.isSelected = index == 0
                button.rx.tap
                    .map {_ in index}
                    .bind(to: tabSubject)
                    .disposed(by: disposeBag)
                buttons.append(button)
            }
        
        tabSubject
            .bind(to: rx.selectedIndex)
            .disposed(by: disposeBag)
        
        backgroundColor = .white
        
        addSubview(stackView)
        buttons.forEach(stackView.addArrangedSubview(_:))
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}


extension Reactive where Base:CustomTabBar {
    var tabButton:Observable<Int> {
        base.tabSubject
    }
    
    var changeIndex:Binder<Int> {
        Binder(base) { base,index in
            base.selectedIndex = index
        }
    }
    
}
