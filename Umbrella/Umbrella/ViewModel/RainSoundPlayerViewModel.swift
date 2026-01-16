//
//  RainSoundPlayerViewModel.swift
//  Umbrella
//
//  Created by 임재현 on 1/16/26.
//

import UIKit
import RxSwift
import RxRelay
import AVFoundation

class RainSoundPlayerViewModel {
    
    let soundItem: SoundItems
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private let disposeBag = DisposeBag()
    
    let playPauseTrigger = PublishRelay<Void>()
    let previousTrigger = PublishRelay<Void>()
    let nextTrigger = PublishRelay<Void>()
    let seekTo = PublishRelay<Float>()
    
    let isPlaying = BehaviorRelay<Bool>(value: false)
    let currentTimeText = BehaviorRelay<String>(value: "0:00")
    let totalTimeText = BehaviorRelay<String>(value: "0:00")
    let progress = BehaviorRelay<Float>(value: 0.0)
    let albumImage = BehaviorRelay<UIImage?>(value: nil)
    let titleText = BehaviorRelay<String>(value: "")
    
    init(soundItems: SoundItems) {
        self.soundItem = soundItems
        
        setupInitialValues()
        setupAudioPlayer()
        setupBindings()
        
    }
    
    deinit {
        stopTimer()
        audioPlayer?.stop()
        print("RainSoundPlayerViewModel deinit")
    }
    
    private func setupInitialValues() {
        albumImage.accept(soundItem.backgroundImage)
        titleText.accept(soundItem.fileName)
    }
    
    
    
    private func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: soundItem.fileName,
                                        withExtension: soundItem.fileType) else {
            print("Failed to find sound file: \(soundItem.fileName).\(soundItem.fileType)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            
            if let duration = audioPlayer?.duration {
                totalTimeText.accept(formatTime(duration))
                
            }
            
            print("Audio player loaded: \(soundItem.fileName)")
        } catch {
            print("Failed to load audio player: \(error.localizedDescription)")
        }
    }
    
    private func setupBindings() {
        // Play/Pause 버튼
        playPauseTrigger
            .subscribe(onNext: { [weak self] in
                self?.togglePlayPause()
            })
            .disposed(by: disposeBag)
        
        // Seek (슬라이더)
        seekTo
            .subscribe(onNext: { [weak self] progress in
                self?.seek(to: progress)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Player Controls
    private func togglePlayPause() {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            stopTimer()
            isPlaying.accept(false)
        } else {
            player.play()
            startTimer()
            isPlaying.accept(true)
        }
    }
    
    private func seek(to progress: Float) {
        guard let player = audioPlayer else { return }
        let newTime = TimeInterval(progress) * player.duration
        player.currentTime = newTime
        updateProgress()
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateProgress() {
        guard let player = audioPlayer else { return }
        let current = player.currentTime
        let total = player.duration
        
        currentTimeText.accept(formatTime(current))
        progress.accept(Float(current / total))
    }
    
    // MARK: - Helpers
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
