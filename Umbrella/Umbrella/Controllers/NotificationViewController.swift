//
//  ViewController7.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/21.
//

import UIKit


class NotificationViewController:UIViewController {
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(test(_:)), name: NSNotification.Name("test"), object: nil)
        view.backgroundColor = .white
        //self.navigationController?.navigationBar.backgroundColor = .white
//        self.navigationController?.navigationItem.title = "설정"
//
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
    
    @objc func test(_ notification:NSNotification){
          timeLabel.text = "\(notification.userInfo!["이름"]!)"
    }
    
}
