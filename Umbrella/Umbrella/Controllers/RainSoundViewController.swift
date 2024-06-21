//
//  ViewController3.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/15.
//


import UIKit
import AVFoundation

class RainSoundViewController:UIViewController {
    
    
    //MARK: - Properties
    
    var player: AVAudioPlayer?
    
    var isChecked = false
    
    private let titleLabel:UILabel = {
        
        let label = UILabel()
        
        label.text = "빗소리 ASMR"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        
        return label
        
        
        
    }()
    
    
    private let heavyRainButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("빗소리", for: .normal)
        button.backgroundColor = .red
        button.tag = 1
        
        button.addTarget(self, action: #selector(playSound1), for: .touchUpInside)
        
        
        
        
        return button
        
        
        
    }()
    
    
    private let thunderRainButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("천둥소리", for: .normal)
        button.backgroundColor = .blue
        button.tag = 2
        button.addTarget(self, action: #selector(playSound2), for: .touchUpInside)
        
        return button
        
        
        
    }()
    
    private let lightRainButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("가벼운빗소리", for: .normal)
        button.backgroundColor = .orange
        button.tag = 3
        button.addTarget(self, action: #selector(playSound3), for: .touchUpInside)
        return button
        
        
        
    }()
    
    private let showerRainButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("소나기", for: .normal)
        button.backgroundColor = .gray
        button.tag = 4
        button.addTarget(self, action: #selector(playSound4), for: .touchUpInside)
        return button
        
        
    }()
    
    private let buttonBackImage1:UIImageView = {
        
        let ig = UIImageView()
        
        ig.image = #imageLiteral(resourceName: "kevin-wang-bI423DxLEYk-unsplash (1)")
        
        return ig
    }()
    
    
    private let buttonBackImage2:UIImageView = {
        
        let ig = UIImageView()
        
        ig.image = #imageLiteral(resourceName: "joy-stamp-pGQbWXBC1dA-unsplash")
        
        return ig
    }()
    
    private let buttonBackImage3:UIImageView = {
        
        let ig = UIImageView()
        
        ig.image = #imageLiteral(resourceName: "mike-kotsch-HNx4QLRgy2k-unsplash")
        
        return ig
    }()
    
    private let buttonBackImage4:UIImageView = {
        
        let ig = UIImageView()
        
        ig.image = #imageLiteral(resourceName: "alex-dukhanov-ZxZQk7777R4-unsplash")
        
        return ig
    }()
    
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      navigationController?.isNavigationBarHidden = true 
    }
    
    //MARK: - Functions
    
    
    func configUI() {
        
        view.backgroundColor = .white
        
        
        view.addSubview(buttonBackImage1)
        buttonBackImage1.anchor(top:view.topAnchor,left: view.leftAnchor,bottom:view.bottomAnchor,right: view.rightAnchor,paddingTop:140,paddingLeft: 30,paddingBottom: 550,paddingRight: 30)
        buttonBackImage1.layer.masksToBounds = true
        buttonBackImage1.layer.cornerRadius = 16
        
        
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top:view.topAnchor,left: view.leftAnchor,paddingTop: 100,paddingLeft: 20)
        
        
        view.addSubview(heavyRainButton)
        heavyRainButton.anchor(top:view.topAnchor,left: view.leftAnchor,bottom:view.bottomAnchor,right: view.rightAnchor,paddingTop:140,paddingLeft: 30,paddingBottom: 550,paddingRight: 30)
        heavyRainButton.layer.cornerRadius = 16
        heavyRainButton.backgroundColor = .none
        // heavyRainButton.setImage(UIImage(named: "buttonrain"), for: .normal)
        //        heavyRainButton.contentVerticalAlignment = .fill
        //        heavyRainButton.contentHorizontalAlignment = .fill
        //        heavyRainButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        
        view.addSubview(buttonBackImage2)
        buttonBackImage2.anchor(top:heavyRainButton.bottomAnchor,left: view.leftAnchor,bottom:view.bottomAnchor,right: view.rightAnchor,paddingTop: 30,paddingLeft: 30,paddingBottom: 420,paddingRight: 30)
        buttonBackImage2.layer.masksToBounds = true
        buttonBackImage2.layer.cornerRadius = 16
        
        
        
        
        
        view.addSubview(thunderRainButton)
        thunderRainButton.anchor(top:heavyRainButton.bottomAnchor,left: view.leftAnchor,bottom:view.bottomAnchor,right: view.rightAnchor,paddingTop: 30,paddingLeft: 30,paddingBottom: 420,paddingRight: 30)
        thunderRainButton.layer.cornerRadius = 16
        thunderRainButton.backgroundColor = .none
        
        view.addSubview(buttonBackImage3)
        buttonBackImage3.anchor(top:thunderRainButton.bottomAnchor,left: view.leftAnchor,bottom: view.bottomAnchor,right: view.rightAnchor,paddingTop: 30,paddingLeft: 30,paddingBottom: 290,paddingRight: 30)
        buttonBackImage3.layer.masksToBounds = true
        buttonBackImage3.layer.cornerRadius = 16
        
        
        view.addSubview(lightRainButton)
        lightRainButton.anchor(top:thunderRainButton.bottomAnchor,left: view.leftAnchor,bottom: view.bottomAnchor,right: view.rightAnchor,paddingTop: 30,paddingLeft: 30,paddingBottom: 290,paddingRight: 30)
        lightRainButton.layer.cornerRadius = 16
        lightRainButton.backgroundColor = .none
        
        
        
        view.addSubview(buttonBackImage4)
        buttonBackImage4.anchor(top:lightRainButton.bottomAnchor,left: view.leftAnchor,bottom: view.bottomAnchor,right: view.rightAnchor,paddingTop: 30,paddingLeft: 30,paddingBottom: 160,paddingRight: 30)
        buttonBackImage4.layer.masksToBounds = true
        buttonBackImage4.layer.cornerRadius = 16
        
        
        view.addSubview(showerRainButton)
        showerRainButton.anchor(top:lightRainButton.bottomAnchor,left: view.leftAnchor,bottom: view.bottomAnchor,right: view.rightAnchor,paddingTop: 30,paddingLeft: 30,paddingBottom: 160,paddingRight: 30)
        showerRainButton.layer.cornerRadius = 16
        showerRainButton.backgroundColor = .none
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    //MARK: - Actions
    
    
    
    @objc func playSound1(_ sender:UIButton) {
        
        isChecked = !isChecked
       
        if isChecked {
            guard let url = Bundle.main.url(forResource: "rain", withExtension: "mp3") else { return }
            
            do {
                
                
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                
                /* iOS 10 and earlier require the following line:
                 player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
                
                guard let player = player else { return }
                
                player.play()
                print("sound1 start")
            } catch let error {
                print(error.localizedDescription)
                
                
                
                
            }
            
        } else {
            player?.stop()
            print("sound1 end")
        }
        
        
    }
    @objc func playSound2(_ sender:UIButton) {
        
        isChecked = !isChecked
        
        if isChecked {
            guard let url = Bundle.main.url(forResource: "thunder", withExtension: "mp3") else { return }
            
            do {
                
                
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                
                /* iOS 10 and earlier require the following line:
                 player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
                
                guard let player = player else { return }
                
                player.play()
                print("sound2 start")
            } catch let error {
                print(error.localizedDescription)
                
                
                
                
            }
            
        } else {
            print("sound2 end")
            player?.stop()
        }
        
        
    }
    @objc func playSound3(_ sender:UIButton) {
        
        isChecked = !isChecked
        
        if isChecked {
            guard let url = Bundle.main.url(forResource: "birdsoundrain", withExtension: "wav") else { return }
            
            do {
                
                
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                
                /* iOS 10 and earlier require the following line:
                 player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
                
                guard let player = player else { return }
                
                player.play()
                print("sound3 start")
            } catch let error {
                print(error.localizedDescription)
                
                
                
                
            }
            
        } else {
            
            
            print("sound3 end")
            player?.stop()
            
        }
        
        
    }
    @objc func playSound4(_ sender:UIButton) {
        
        isChecked = !isChecked
        
        if isChecked {
        guard let url = Bundle.main.url(forResource: "rainrain", withExtension: "wav") else { return }
        
        do {
            
            
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            print("sound4 start")
            
        } catch let error {
            print(error.localizedDescription)
            
            
            
            
        }
        
        
        } else {
            player?.stop()
            print("sound4 end")
        }
        
    }
    
    
}


