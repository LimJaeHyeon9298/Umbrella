//
//  RainScene.swift
//  Umbrella
//

import Foundation

/// 재생할 장면 하나. 빗소리와 배경 이미지를 묶는다.
struct RainScene: Identifiable, Hashable {
    let id: String
    let title: String
    let soundName: String
    let soundExtension: String
    let imageName: String
    let isFree: Bool

    var soundURL: URL? {
        Bundle.main.url(forResource: soundName, withExtension: soundExtension)
    }

    // shortcut: 기존 빗소리 4개와 임시 이미지다, 실제 장면 8개가 정해지면 교체한다
    static let all: [RainScene] = [
        RainScene(id: "window", title: "창가의 비", soundName: "rain", soundExtension: "mp3",
                  imageName: "kevin-wang-bI423DxLEYk-unsplash (1)", isFree: true),
        RainScene(id: "forest", title: "새벽 숲의 비", soundName: "birdsoundrain", soundExtension: "wav",
                  imageName: "mike-kotsch-HNx4QLRgy2k-unsplash", isFree: true),
        RainScene(id: "thunder", title: "천둥 치는 밤", soundName: "thunder", soundExtension: "mp3",
                  imageName: "joy-stamp-pGQbWXBC1dA-unsplash", isFree: false),
        RainScene(id: "shower", title: "짧은 소나기", soundName: "rainrain", soundExtension: "wav",
                  imageName: "alex-dukhanov-ZxZQk7777R4-unsplash", isFree: false),
    ]
}
