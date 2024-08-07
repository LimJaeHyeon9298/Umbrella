//
//  ViewController8.swift
//  Umbrella
//
//  Created by 임재현 on 2023/03/26.
//

import UIKit


class TimeSettingViewController:UIViewController {
    
    
    
    
    
    //MARK: - Properties
    let userNotiCenter = UNUserNotificationCenter.current() // 추가
    var currentTime = ""
    var selectedTime = ""
    var alarm: Bool = true
    
//    var currentTime = UILabel()
    
//    var selectedTime = UILabel()
   
    private let datePicker:UIDatePicker = {
        
        let picker = UIDatePicker()
        picker.addTarget(self, action: #selector(pickerChanged), for: .valueChanged)
        
        return picker
    }()
    
    private let testLabel:UIButton = {
        
        let button = UIButton()
        button.setTitle("선택", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
        
    }()
    
    
    
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        view.backgroundColor = .white
        if #available(iOS 15.0, *) {
            if let sheetPresentationController = sheetPresentationController {
                sheetPresentationController.detents = [.medium()]
            }
        }
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
        
    }
    
    
    
    
    
    func configUI() {
        
        view.addSubview(datePicker)
        datePicker.anchor(top: view.topAnchor,left: view.leftAnchor,bottom: view.bottomAnchor,right: view.rightAnchor,paddingTop: 80,paddingLeft: 0,paddingBottom: 20,paddingRight: 0,width: 100, height: 100)
        
     datePicker.preferredDatePickerStyle = .wheels
     datePicker.datePickerMode = .time
     datePicker.backgroundColor = .red
     datePicker.locale = Locale(identifier: "ko-KR")
     datePicker.timeZone = .autoupdatingCurrent
        datePicker.backgroundColor = .lightGray
        
        view.addSubview(testLabel)
        testLabel.anchor(top: view.topAnchor,left: view.leftAnchor,paddingTop: 20,paddingLeft: 20)
        
        
        
        
        
    }
    
    
    // 사용자에게 알림 권한 요청
     func requestAuthNoti() {
         let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
         userNotiCenter.requestAuthorization(options: notiAuthOptions) { (success, error) in
             if let error = error {
                 print(#function, error)
             }
         }
     }

    
    func requestSendNoti(seconds: Double) {
          let notiContent = UNMutableNotificationContent()
          notiContent.title = "Umbrella"
          notiContent.body = "비가올지 확인해보세요!"
          notiContent.userInfo = ["targetScene": "splash"] // 푸시 받을때 오는 데이터

          // 알림이 trigger되는 시간 설정
          let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)

          let request = UNNotificationRequest(
              identifier: UUID().uuidString,
              content: notiContent,
              trigger: trigger
          )

          userNotiCenter.add(request) { (error) in
              print(#function, error)
          }

      }
    
    @objc func buttonTapped() {
        
        
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name("test"), object: nil, userInfo: ["이름":selectedTime])
      
    }
    
    @objc func pickerChanged() {
        
        
            let dateformatter = DateFormatter()

               dateformatter.dateStyle = .none

               dateformatter.timeStyle = .short

               let date = dateformatter.string(from: datePicker.date)

                 selectedTime = date
//        print("hi\(selectedTime)")
//
        
        
    }
    
    @objc func updateTime(){

            let date = NSDate()

            let dateformatter = DateFormatter()

           dateformatter.dateStyle = .none

             dateformatter.timeStyle = .short


             currentTime = dateformatter.string(from: date as Date)

            

             if currentTime == selectedTime {

                

                if alarm {

                    callAlert()
                    
                   alarm = false

                }

            }

        }
    
    
    func callAlert(){

        requestSendNoti(seconds: 1)
        requestAuthNoti()

        }
    
    
}


