//
//  SoundCollectionViewCell.swift
//  Umbrella
//
//  Created by 임재현 on 6/25/24.
//

import UIKit
import Then
import SnapKit
import AVFoundation

class SoundCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SoundCell" 
    
    
    
    var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
    }
    
    var titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textAlignment = .center
        
    }
    
    var player:AVAudioPlayer?
    var soundFileName:String?
    var soundFileType:String?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpLayout() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSound))
        contentView.addGestureRecognizer(tapGesture)
        
        
    }
    
    func configure(with item:SoundItems) {
        imageView.image = item.backgroundImage
        titleLabel.text = item.title
        soundFileName = item.fileName
        soundFileType = item.fileType
    }
    
    
    
    @objc func toggleSound() {
        if let player = player, player.isPlaying {
            player.stop()
        } else {
            guard let fileName = soundFileName, let fileType = soundFileType else {return}
            guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {return}
            
            
            print("\(fileName) play start")
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                print("Failed to play sound: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    
}


