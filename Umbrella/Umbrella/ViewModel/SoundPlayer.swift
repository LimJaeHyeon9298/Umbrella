//
//  SoundPlayer.swift
//  Umbrella
//

import AVFoundation
import MediaPlayer
import Observation
import UIKit

/// 장면의 빗소리를 반복 재생한다. 화면이 꺼져도 계속 재생되고 잠금 화면에서 조작할 수 있다.
@Observable
final class SoundPlayer {
    private(set) var scene: RainScene
    private(set) var isPlaying = false

    @ObservationIgnored private var player: AVAudioPlayer?
    @ObservationIgnored private var observers: [NSObjectProtocol] = []
    private static let lastSceneKey = "petrichor.lastSceneID"

    init() {
        let savedID = UserDefaults.standard.string(forKey: Self.lastSceneKey)
        scene = RainScene.all.first { $0.id == savedID } ?? RainScene.all[0]
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        configureRemoteCommands()
        observeAudioSession()
        updateNowPlaying()
    }

    /// 장면을 바꾸고 바로 재생한다.
    func select(_ newScene: RainScene) {
        if newScene != scene {
            player?.stop()
            player = nil
            scene = newScene
            UserDefaults.standard.set(newScene.id, forKey: Self.lastSceneKey)
        }
        play()
    }

    func play() {
        if player == nil { player = makePlayer() }
        guard let player else { return }
        try? AVAudioSession.sharedInstance().setActive(true)
        player.volume = 0
        player.play()
        player.setVolume(1, fadeDuration: 1.5)
        isPlaying = true
        updateNowPlaying()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlaying()
    }

    func toggle() {
        isPlaying ? pause() : play()
    }

    private func makePlayer() -> AVAudioPlayer? {
        guard let url = scene.soundURL, let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        // shortcut: mp3는 반복 이음매에 짧은 공백이 생길 수 있다, 실제 소리는 wav나 caf로 받고 그래도 들리면 AVAudioEngine으로 바꾼다
        player.numberOfLoops = -1
        player.prepareToPlay()
        return player
    }

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.toggle()
            return .success
        }
    }

    private func observeAudioSession() {
        let center = NotificationCenter.default
        // 전화가 오면 시스템이 재생을 멈춘다. 끝난 뒤 재개해도 된다고 하면 다시 튼다.
        observers.append(center.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] note in
            guard let self, let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
            switch type {
            case .began:
                isPlaying = false
                updateNowPlaying()
            case .ended:
                let options = (note.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt).map(AVAudioSession.InterruptionOptions.init) ?? []
                if options.contains(.shouldResume) { play() }
            @unknown default:
                break
            }
        })
        // 이어폰을 빼면 스피커로 갑자기 소리가 나지 않게 멈춘다.
        observers.append(center.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main) { [weak self] note in
            guard let raw = note.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  AVAudioSession.RouteChangeReason(rawValue: raw) == .oldDeviceUnavailable else { return }
            self?.pause()
        })
    }

    private func updateNowPlaying() {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: scene.title,
            MPMediaItemPropertyArtist: "Petrichor",
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
        ]
        if let image = UIImage(named: scene.imageName) {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
