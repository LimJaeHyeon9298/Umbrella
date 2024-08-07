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
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    //MARK: - LifeCycle
   
    init(viewModel:RainSoundViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupAudioPlayers()
        configureAudioSession()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        print("rainSoundVC viewDidLoad")
       
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
    
    func setupAudioPlayers() {
            viewModel.items
                .subscribe(onNext: { [weak self] items in
                    items.forEach { item in
                        guard let url = Bundle.main.url(forResource: item.fileName, withExtension: item.fileType) else {
                            print("Failed to find sound file: \(item.fileName).\(item.fileType)")
                            return
                        }
                        do {
                            let player = try AVAudioPlayer(contentsOf: url)
                            self?.audioPlayers[item.fileName] = player
                            print("Loaded sound file: \(item.fileName).\(item.fileType)")
                        } catch {
                            print("Failed to load sound: \(error.localizedDescription)")
                        }
                    }
                })
                .disposed(by: disposeBag)
        }
    
    func configureAudioSession() {
           do {
               try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
               try AVAudioSession.sharedInstance().setActive(true)
               print("Audio session configured successfully")
           } catch {
               print("Failed to configure audio session: \(error.localizedDescription)")
           }
       }
    
    func binds() {
            viewModel.items
                .bind(to: collectionView.rx.items(cellIdentifier: SoundCollectionViewCell.reuseIdentifier,
                                                  cellType: SoundCollectionViewCell.self)) { [weak self] index, item, cell in
                    guard let self = self else { return }
                    cell.configure(with: item)
                    cell.tapSubject
                        .subscribe(onNext: { [weak self] (fileName, fileType) in
                            print("Tapped on sound: \(fileName).\(fileType)")
                            self?.toggleSound(for: fileName, fileType: fileType)
                        })
                        .disposed(by: cell.disposeBag)
                }
                .disposed(by: disposeBag)
        }
    
    func toggleSound(for fileName: String, fileType: String) {
            guard let player = audioPlayers[fileName] else {
                print("No player found for sound file: \(fileName).\(fileType)")
                return
            }
            
            if player.isPlaying {
                print("Stopping sound: \(fileName).\(fileType)")
                player.stop()
            } else {
                print("Playing sound: \(fileName).\(fileType)")
                player.play()
            }
        }
        
    
    @objc func enableDarkmode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let theme = isDarkMode ? Theme.dark : Theme.light    
        collectionView.backgroundColor = theme.backgroundColor
  

    }
    
}


