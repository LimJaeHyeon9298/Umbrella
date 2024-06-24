//
//  SettingViewModel.swift
//  Umbrella
//
//  Created by 임재현 on 6/23/24.
//

import RxSwift
import RxCocoa

class SettingViewModel {
    let items = Observable.just([
        SettingCellType.darkMode,
        SettingCellType.alarm
    
    ])
    
}
