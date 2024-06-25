//
//  RainSoundViewModel.swift
//  Umbrella
//
//  Created by 임재현 on 6/25/24.
//

import UIKit
import RxSwift
import RxCocoa


class RainSoundViewModel {
    let items: Observable<[SoundItems]> = Observable.just([
        SoundItems(title: "빗소리", fileName: "rain", fileType: "mp3", backgroundImage: #imageLiteral(resourceName: "kevin-wang-bI423DxLEYk-unsplash (1)")),
        SoundItems(title: "천둥소리", fileName: "thunder", fileType: "mp3", backgroundImage: #imageLiteral(resourceName: "joy-stamp-pGQbWXBC1dA-unsplash")),
        SoundItems(title: "가벼운빗소리", fileName: "birdsoundrain", fileType: "wav", backgroundImage: #imageLiteral(resourceName: "mike-kotsch-HNx4QLRgy2k-unsplash")),
        SoundItems(title: "소나기", fileName: "rainrain", fileType: "wav", backgroundImage: #imageLiteral(resourceName: "alex-dukhanov-ZxZQk7777R4-unsplash"))
    ])
}
