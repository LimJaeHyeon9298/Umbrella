//
//  LoopingVideoView.swift
//  Umbrella
//

import AVFoundation
import SwiftUI

/// 영상을 소리 없이 끊김 없이 반복한다. 화면을 꽉 채우도록 잘라서 보여준다.
struct LoopingVideoView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PlayerUIView {
        PlayerUIView(url: url)
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {}

    final class PlayerUIView: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }

        private let player = AVQueuePlayer()
        private var looper: AVPlayerLooper?
        private var observer: NSObjectProtocol?

        init(url: URL) {
            super.init(frame: .zero)
            looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
            player.isMuted = true
            // 화면 꺼짐 방지는 설정에서 따로 정한다.
            player.preventsDisplaySleepDuringVideoPlayback = false
            let playerLayer = layer as! AVPlayerLayer
            playerLayer.player = player
            playerLayer.videoGravity = .resizeAspectFill
            player.play()
            // 백그라운드로 가면 시스템이 영상을 멈춘다. 돌아오면 다시 튼다.
            observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
                self?.player.play()
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        deinit {
            if let observer { NotificationCenter.default.removeObserver(observer) }
        }
    }
}
