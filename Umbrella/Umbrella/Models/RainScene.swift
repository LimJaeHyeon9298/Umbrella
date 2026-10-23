//
//  RainScene.swift
//  Umbrella
//

import Foundation

/// 재생할 장면 하나. 빗소리와 배경(이미지 또는 반복 영상)을 묶는다.
struct RainScene: Identifiable, Hashable {
    /// 장면을 쓰려면 무엇이 필요한지.
    enum Access: Hashable {
        case free
        /// 기본 컬렉션(한 번 결제)으로 열린다.
        case base
        /// 특별 컬렉션. 이 상품을 따로 사야 열린다.
        case special(productID: String)
    }

    let id: String
    let title: String
    let soundName: String
    let soundExtension: String
    let imageName: String
    let access: Access
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

    var isFree: Bool { access == .free }

    var specialProductID: String? {
        if case .special(let productID) = access { productID } else { nil }
    }

    // shortcut: 기존 빗소리 4개와 임시 이미지다, 실제 장면 8개가 정해지면 교체한다
    static let all: [RainScene] = [
        RainScene(id: "window", title: "창가의 비", soundName: "rain", soundExtension: "mp3",
                  imageName: "kevin-wang-bI423DxLEYk-unsplash (1)", access: .free),
        RainScene(id: "forest", title: "새벽 숲의 비", soundName: "birdsoundrain", soundExtension: "wav",
                  imageName: "mike-kotsch-HNx4QLRgy2k-unsplash", access: .free),
        RainScene(id: "thunder", title: "천둥 치는 밤", soundName: "thunder", soundExtension: "mp3",
                  imageName: "storm", access: .base, videoName: "storm"),
        // shortcut: 특별 컬렉션 흐름을 시험하려고 임시로 특별 장면으로 뒀다, 실제 특별 장면이 생기면 교체하고 이 상품은 App Store Connect에 등록하지 않는다
        RainScene(id: "shower", title: "짧은 소나기", soundName: "rainrain", soundExtension: "wav",
                  imageName: "alex-dukhanov-ZxZQk7777R4-unsplash",
                  access: .special(productID: "com.jaehyeonLim9298.petrichor.special.sample")),
    ]
}
