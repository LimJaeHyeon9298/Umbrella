//
//  RainScene.swift
//  Umbrella
//

import Foundation

/// 재생할 장면 하나. 빗소리와 배경(이미지 또는 반복 영상)을 묶는다.
struct RainScene: Identifiable, Hashable {
    let id: String
    let title: String
    let soundName: String
    let soundExtension: String
    let imageName: String
    let isFree: Bool
    /// 반복 영상 이름. 있으면 이미지 대신 배경으로 쓰고, `<이름>-3x4` 영상과 `<이미지>-3x4` 이미지를 잠금 화면용으로 함께 둔다.
    var videoName: String? = nil

    var soundURL: URL? {
        Bundle.main.url(forResource: soundName, withExtension: soundExtension)
    }

    var videoURL: URL? {
        videoName.flatMap { Bundle.main.url(forResource: $0, withExtension: "mp4") }
    }

    var tallVideoURL: URL? {
        videoName.flatMap { Bundle.main.url(forResource: "\($0)-3x4", withExtension: "mp4") }
    }

    var tallImageName: String { "\(imageName)-3x4" }

    // shortcut: 기존 빗소리 4개와 임시 이미지다, 실제 장면 8개가 정해지면 교체한다
    static let all: [RainScene] = [
        RainScene(id: "window", title: "창가의 비", soundName: "rain", soundExtension: "mp3",
                  imageName: "kevin-wang-bI423DxLEYk-unsplash (1)", isFree: true),
        RainScene(id: "forest", title: "새벽 숲의 비", soundName: "birdsoundrain", soundExtension: "wav",
                  imageName: "mike-kotsch-HNx4QLRgy2k-unsplash", isFree: true),
        RainScene(id: "thunder", title: "천둥 치는 밤", soundName: "thunder", soundExtension: "mp3",
                  imageName: "storm", isFree: false, videoName: "storm"),
        RainScene(id: "shower", title: "짧은 소나기", soundName: "rainrain", soundExtension: "wav",
                  imageName: "alex-dukhanov-ZxZQk7777R4-unsplash", isFree: false),
    ]
}
