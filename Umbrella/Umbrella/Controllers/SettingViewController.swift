//
//  ViewController6.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/15.
//


import UIKit


class SettingViewController:UIViewController {
    
    
    //MARK: - Properties
    
    let userDefaults = UserDefaults.standard

    
    
    private let settingButton:UIButton = {
        
        let button = UIButton()
        
       // button.backgroundColor = .white
        button.addTarget(self, action: #selector(alertButtonTapped), for: .touchUpInside)
        
        return button
        
        
        
    }()
    
    private let alertImage:UIImageView = {
        
        let ig = UIImageView()
        
        ig.image = #imageLiteral(resourceName: "Vector")
        
        
        
        return ig
        
        
    }()
    
    private let nextImage :UIImageView = {
        
        let ig = UIImageView()
        
        ig.image = #imageLiteral(resourceName: "Vector (1)")
        
        
        
        return ig
        
        
    }()
    
    
    private let titleLabel:UILabel = {
        
        let label = UILabel()
        
        label.text = "알림"
        label.font = UIFont.boldSystemFont(ofSize: 18)
       // label.textColor = .black
       
        return label
        
        
        
    }()
    private lazy var controlSwitch: UISwitch = {
        // Create a Switch.
        let swicth = UISwitch()
        
        
        
        swicth.tintColor = UIColor.orange
        
     
        swicth.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        
        swicth.addTarget(self, action: #selector(onClickSwitch), for: UIControl.Event.valueChanged)
        
        return swicth
    }()
    
    
    private let darkmodeIcon :UIImageView = {
        
        let ig = UIImageView()
        ig.image = #imageLiteral(resourceName: "Vector")
        
        return ig
        
        
        
        
    }()
    
    
   
    private let darkmodeLabel:UILabel = {
        
        let label = UILabel()
        label.text = "다크모드"
        label.font = UIFont.boldSystemFont(ofSize: 18)
    
        return label
        
        
    }()
    
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configUI()
      
    }
    
    //MARK: - Functions
    
    
    func configUI() {
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let theme = isDarkMode ? Theme.dark : Theme.light
        
        view.backgroundColor = theme.backgroundColor
        
        
        
        view.addSubview(settingButton)
        settingButton.anchor(top:view.topAnchor,left: view.leftAnchor,bottom: view.bottomAnchor,right: view.rightAnchor,paddingTop: 105,paddingLeft: 0,paddingBottom: 690,paddingRight: 0)
        
        
        view.addSubview(alertImage)
        alertImage.centerY(inView: settingButton)
        alertImage.anchor(left:settingButton.leftAnchor,paddingLeft: 20,width: 20,height: 20)
        
        view.addSubview(titleLabel)
        titleLabel.centerY(inView: settingButton)
        titleLabel.anchor(left: alertImage.leftAnchor,paddingLeft: 40)
        titleLabel.textColor = theme.textColor
        
        view.addSubview(nextImage)
        nextImage.centerY(inView: settingButton)
        nextImage.anchor(right:settingButton.rightAnchor,paddingRight: 20)
        
        
        view.addSubview(darkmodeIcon)
        darkmodeIcon.anchor(top:alertImage.bottomAnchor,left: view.leftAnchor,paddingTop: 40,paddingLeft: 20,width: 20,height: 20)
        
        view.addSubview(darkmodeLabel)
        darkmodeLabel.anchor(top: alertImage.bottomAnchor,left: darkmodeIcon.rightAnchor,paddingTop: 40,paddingLeft: 20)
        darkmodeLabel.textColor = theme.textColor
        
        
        view.addSubview(controlSwitch)
        controlSwitch.anchor(top:alertImage.bottomAnchor,right: view.rightAnchor,paddingTop: 40,paddingRight: 25)
        self.navigationItem.title = "설정"
        
        
        
    }
    
    //MARK: - Actions
    
    
    @objc func alertButtonTapped() {
        
        let controller = NotificationViewController()
       
        self.navigationController?.pushViewController(controller, animated: true)
    
        
      //  present(controller, animated: true)
        
        
    }
    
    @objc func onClickSwitch(_ toggle: UISwitch) {
        
        let name = Notification.Name("darkModeHasChanged")
        UserDefaults.standard.set(toggle.isOn, forKey: "isDarkMode")
        NotificationCenter.default.post(name: name, object: nil)
        
        
        
        let currentTheme = toggle.isOn ? Theme.dark : Theme.light
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        let theme = isDarkMode ? Theme.dark : Theme.light        //view.backgroundColor = theme.backgroundColor
        
        
        
        view.backgroundColor = theme.backgroundColor
        
        settingButton.backgroundColor = theme.backgroundColor
        titleLabel.textColor = theme.textColor
        darkmodeLabel.textColor = theme.textColor
       
        if true {
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.red]
        }
        
    
        
        
        navigationController?.navigationBar.barTintColor = currentTheme.backgroundColor
        //tabBarController?.tabBar.barTintColor = .red
        
        //currentTheme.backgroundColor
        
    }
    
}

