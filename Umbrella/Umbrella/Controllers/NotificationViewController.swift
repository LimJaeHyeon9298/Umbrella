//
//  ViewController7.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/21.
//

import UIKit
import Then
import SnapKit


class NotificationViewController:UIViewController {
    
    private let backButton = UIButton().then {
            let image = UIImage(systemName: "chevron.left")
            $0.setImage(image, for: .normal)
            $0.tintColor = .blue
        }
    
    
    
    private let alertLabel:UILabel = {
        let label = UILabel()
        label.text = "알림"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let alertLabel2:UILabel = {
        let label = UILabel()
        label.text = "원하는 시간에 알람을 받을수 있어요."
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    private let alertButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    private let datePicker:UIDatePicker = {
        let picker = UIDatePicker()
        return picker
    }()
    
    
    private let timeSettingLabel:UILabel = {
        let label = UILabel()
        label.text = "시간 선택"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    private let timeLabel:UILabel = {
        let label = UILabel()
        label.text = "시간설정"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    private let nextImage :UIImageView = {
        let ig = UIImageView()
        ig.image = #imageLiteral(resourceName: "Vector (1)")
        return ig
    }()
    
    
    
    
   // let userNotiCenter = UNUserNotificationCenter.current() // 추가
 
    override func viewDidLoad() {
        
        let navigationBar = UIView()
                navigationBar.backgroundColor = .clear
                view.addSubview(navigationBar)
                navigationBar.snp.makeConstraints {
                    $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
                    $0.height.equalTo(50)
                }
                
                // 뒤로가기 버튼 설정
                navigationBar.addSubview(backButton)
                backButton.snp.makeConstraints {
                    $0.centerY.equalToSuperview()
                    $0.leading.equalToSuperview().offset(16)
                }
               backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(test(_:)), name: NSNotification.Name("test"), object: nil)
        view.backgroundColor = .white
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationItem.title = "설정"
     self.navigationController?.setNavigationBarHidden(false, animated: true)
        view.addSubview(alertLabel)
        alertLabel.anchor(top:view.topAnchor,left: view.leftAnchor,paddingTop:105,paddingLeft: 20)
        
        view.addSubview(alertLabel2)
        alertLabel2.anchor(top: alertLabel.bottomAnchor,left: view.leftAnchor,paddingTop: 10,paddingLeft: 20)
        
        view.addSubview(alertButton)
        alertButton.anchor(top: alertLabel2.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor,paddingTop: 20,paddingLeft: 20,paddingRight: 20,height: 60)
        alertButton.layer.cornerRadius = 16
        
        view.addSubview(timeSettingLabel)
        timeSettingLabel.centerY(inView: alertButton)
        timeSettingLabel.anchor(left: alertButton.leftAnchor,paddingLeft: 10)
        
        view.addSubview(timeLabel)
        timeLabel.centerY(inView: alertButton)
        timeLabel.anchor(left: timeSettingLabel.rightAnchor,paddingLeft: 180)
        
        view.addSubview(nextImage)
        nextImage.centerY(inView: alertButton)
        nextImage.anchor(right: alertButton.rightAnchor,paddingRight: 10)
        
    }
    
    
    func configUI() {
//        timeLabel.text = aaa
    }
    
    @objc func buttonTapped() {
        
        let controller = TimeSettingViewController()
        present(controller, animated: true)
    }
    
    
    
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func test(_ notification:NSNotification){
          timeLabel.text = "\(notification.userInfo!["이름"]!)"
    }
    
}
