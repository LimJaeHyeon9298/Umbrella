//
//  LockScreenTip.swift
//  Umbrella
//

import SwiftUI
import TipKit

/// 잠금 화면 영상은 사용자가 그림을 눌러야 펼쳐져서 한 번 알려준다.
struct LockScreenTip: Tip {
    /// 영상 장면을 재생하는 동안에만 띄운다.
    @Parameter static var isPlayingVideo: Bool = false

    static let titleText = "잠금 화면에서도 비가 내려요"
    static let messageText = "재생 중에 잠금 화면의 그림을 누르면 화면 가득 펼쳐져요."

    var title: Text {
        Text(Self.titleText)
    }

    var message: Text? {
        Text(Self.messageText)
    }

    var image: Image? {
        Image(systemName: "lock.iphone")
    }

    var rules: [Rule] {
        #Rule(Self.$isPlayingVideo) { $0 == true }
    }
}
