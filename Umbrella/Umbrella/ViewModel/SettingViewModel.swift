//
//  SettingViewModel.swift
//  Umbrella
//
//  Created by 임재현 on 6/23/24.
//

import RxSwift
import RxCocoa
import Foundation

class SettingViewModel {
    
    private let disposeBag = DisposeBag()
    
    let items = Observable.just([
        SettingCellType.darkMode,
        SettingCellType.alarm,
        SettingCellType.location
    
    ])
 
    var isDarkModeEnabled = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: "isDarkMode"))
        let theme = BehaviorSubject<Theme>(value: UserDefaults.standard.bool(forKey: "isDarkMode") ? Theme.dark : Theme.light)
        
        func toggleDarkMode(enabled: Bool) {
            UserDefaults.standard.set(enabled, forKey: "isDarkMode")
            NotificationCenter.default.post(name: Notification.Name("darkModeHasChanged"), object: nil)
            theme.onNext(enabled ? Theme.dark : Theme.light)
        }
   
    
    init() {
           // UserDefaults에서 isDarkMode 값을 불러와 설정
           isDarkModeEnabled.accept(UserDefaults.standard.bool(forKey: "isDarkMode"))
           
           isDarkModeEnabled
               .subscribe(onNext: { isDarkMode in
                   UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
                   UserDefaults.standard.synchronize()  // 변경사항을 즉시 저장
                   let newTheme = isDarkMode ? Theme.dark : Theme.light
                   self.theme.onNext(newTheme)
                   NotificationCenter.default.post(name: Notification.Name("darkModeHasChanged"), object: nil)
               })
               .disposed(by: disposeBag)
       }
    
    
}
