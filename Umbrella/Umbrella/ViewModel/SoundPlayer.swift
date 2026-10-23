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
    /// 예약 종료 시각과 고른 분. 꺼져 있으면 nil과 0.
    private(set) var sleepEndDate: Date?
    private(set) var sleepMinutes = 0
    /// 잠긴 장면 미리듣기가 끝나는 시각. 미리듣기 중이 아니면 nil.
    private(set) var previewEndDate: Date?

    @ObservationIgnored private var player: AVAudioPlayer?
    @ObservationIgnored private var observers: [NSObjectProtocol] = []
    @ObservationIgnored private var sleepTask: Task<Void, Never>?
    @ObservationIgnored private var previewTask: Task<Void, Never>?
    private static let sleepFadeSeconds: Double = 8
    private static let lastSceneKey = "petrichor.lastSceneID"

    init() {
        let savedID = UserDefaults.standard.string(forKey: Self.lastSceneKey)
        scene = RainScene.all.first { $0.id == savedID } ?? RainScene.all[0]
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        configureRemoteCommands()
        observeAudioSession()
        updateNowPlaying()
    }

    /// 장면을 바꾼다. `play`가 true면 바로 재생한다.
    func select(_ newScene: RainScene, play shouldPlay: Bool = true) {
        endPreview()
        if newScene != scene {
            player?.stop()
            player = nil
            scene = newScene
            UserDefaults.standard.set(newScene.id, forKey: Self.lastSceneKey)
        }
        if shouldPlay {
            play()
        } else {
            isPlaying = false
            updateNowPlaying()
        }
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

    /// 잠긴 장면을 `seconds`초 동안 틀어 준다. 끝나면 소리를 줄여 멈추고 `onEnd`를 부른다.
    func startPreview(_ previewScene: RainScene, seconds: Double = 60, onEnd: @escaping () -> Void) {
        select(previewScene)
        let end = Date().addingTimeInterval(seconds)
        let fade = min(3, seconds / 2)
        previewEndDate = end
        // 소리가 나는 동안은 백그라운드에서도 앱이 깨어 있어서 화면을 꺼도 끝에 멈춘다.
        previewTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(end.timeIntervalSinceNow - fade))
            guard !Task.isCancelled, let self else { return }
            player?.setVolume(0, fadeDuration: fade)
            try? await Task.sleep(for: .seconds(fade))
            guard !Task.isCancelled else { return }
            pause()
            previewEndDate = nil
            onEnd()
        }
    }

    /// 미리듣기를 멈추지 않고 미리듣기 상태만 끝낸다. 구매했거나 장면을 바꿀 때 쓴다.
    func endPreview() {
        previewTask?.cancel()
        previewTask = nil
        previewEndDate = nil
    }

    /// `minutes`분 뒤에 소리를 서서히 줄이고 멈춘다. 0이면 예약을 끈다.
    func setSleepTimer(minutes: Int) {
        startSleepTimer(after: TimeInterval(minutes * 60), minutes: minutes)
    }

    /// 시험에서 짧은 시간으로 부르려고 초 단위로 둔다.
    func startSleepTimer(after seconds: TimeInterval, minutes: Int) {
        sleepTask?.cancel()
        sleepMinutes = minutes
        guard seconds > 0 else {
            sleepEndDate = nil
            return
        }
        let end = Date().addingTimeInterval(seconds)
        let fade = min(Self.sleepFadeSeconds, seconds / 2)
        sleepEndDate = end
        // 소리가 나는 동안은 백그라운드에서도 앱이 깨어 있어서 이 작업이 계속 돈다.
        sleepTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(end.timeIntervalSinceNow - fade))
            guard !Task.isCancelled, let self else { return }
            player?.setVolume(0, fadeDuration: fade)
            try? await Task.sleep(for: .seconds(fade))
            guard !Task.isCancelled else { return }
            pause()
            sleepEndDate = nil
            sleepMinutes = 0
        }
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
        if #available(iOS 26.0, *) {
            addAnimatedArtwork(to: &info)
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    /// 반복 영상 장면이면 잠금 화면에 움직이는 그림을 넘긴다. 정사각형과 세로형을 따로 준다.
    @available(iOS 26.0, *)
    private func addAnimatedArtwork(to info: inout [String: Any]) {
        let supported = MPNowPlayingInfoCenter.supportedAnimatedArtworkKeys
        let variants = [
            (MPNowPlayingInfoProperty1x1AnimatedArtwork, scene.videoURL, UIImage(named: scene.imageName), scene.id),
            (MPNowPlayingInfoProperty3x4AnimatedArtwork, scene.tallVideoURL, UIImage(named: scene.tallImageName), "\(scene.id)-3x4"),
        ]
        #if DEBUG
        if scene.videoName != nil { print("[Petrichor] 잠금 화면 영상 지원 키: \(supported)") }
        #endif
        for (key, url, preview, artworkID) in variants where supported.contains(key) {
            guard let url, let preview else { continue }
            info[key] = MPMediaItemAnimatedArtwork(
                artworkID: artworkID,
                previewImageRequestHandler: { size, completion in
                    #if DEBUG
                    print("[Petrichor] \(artworkID) 미리보기 요청 \(size)")
                    #endif
                    completion(preview)
                },
                videoAssetFileURLRequestHandler: { size, completion in
                    #if DEBUG
                    print("[Petrichor] \(artworkID) 영상 요청 \(size)")
                    #endif
                    completion(url)
                }
            )
        }
    }
}
