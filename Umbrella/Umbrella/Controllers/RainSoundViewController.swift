//
//  ViewController3.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/15.
//


import UIKit
import AVFoundation
import SnapKit
import Then
import RxSwift
import RxCocoa

class RainSoundViewController:UIViewController {
    
    //MARK: - Properties
    var collectionView:UICollectionView!
    let viewModel: RainSoundViewModel
    let disposeBag = DisposeBag()
    private var isDarkMode: Bool {
            return UserDefaults.standard.bool(forKey: "isDarkMode")
        }
    
    //MARK: - LifeCycle
   
    init(viewModel:RainSoundViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
       
        binds()
        let name = Notification.Name("darkModeHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkmode), name: name, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
      navigationController?.isNavigationBarHidden = true 
    }
    
    //MARK: - Functions
    func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout().then {
            $0.itemSize = CGSize(width: view.frame.width - 60 , height: 100)
            $0.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30)
            $0.minimumLineSpacing = 20
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then({
            $0.register(SoundCollectionViewCell.self, forCellWithReuseIdentifier: SoundCollectionViewCell.reuseIdentifier)
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        })
        
        collectionView.backgroundColor = isDarkMode ? Theme.dark.backgroundColor : Theme.light.backgroundColor
        
    }
    
    func binds() {
        viewModel.items
            .bind(to: collectionView.rx.items(cellIdentifier: SoundCollectionViewCell.reuseIdentifier,
                                              cellType: SoundCollectionViewCell.self)) { index, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
    }
    
    @objc func enableDarkmode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let theme = isDarkMode ? Theme.dark : Theme.light    
        collectionView.backgroundColor = theme.backgroundColor
  

    }
    
}


