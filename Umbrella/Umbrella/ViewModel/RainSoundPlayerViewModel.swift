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
    
    // MARK: - Properties
    private let allItems: [SoundItems]  // 전체 리스트
    private let currentIndex: BehaviorRelay<Int>  // 현재 인덱스
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private let disposeBag = DisposeBag()
    
    // MARK: - Inputs (UI에서 ViewModel로)
    let playPauseTrigger = PublishRelay<Void>()
    let previousTrigger = PublishRelay<Void>()
    let nextTrigger = PublishRelay<Void>()
    let seekTo = PublishRelay<Float>() // 0.0 ~ 1.0 (progressView의 비율)
    let repeatTrigger = PublishRelay<Void>()
    let shuffleTrigger = PublishRelay<Void>()
    
    private var shuffledIndices: [Int] = []  // 셔플된 인덱스 배열
    private var currentShufflePosition: Int = 0  // 현재 셔플 위치
    
    // MARK: - Outputs (ViewModel에서 UI로)
    let isPlaying = BehaviorRelay<Bool>(value: false)
    let currentTimeText = BehaviorRelay<String>(value: "0:00")
    let totalTimeText = BehaviorRelay<String>(value: "0:00")
    let progress = BehaviorRelay<Float>(value: 0.0)
    let albumImage = BehaviorRelay<UIImage?>(value: nil)
    let titleText = BehaviorRelay<String>(value: "")
    let isRepeatEnabled = BehaviorRelay<Bool>(value: false)
    let isShuffleEnabled = BehaviorRelay<Bool>(value: false)
    
    // 현재 아이템
    private var currentItem: SoundItems {
        return allItems[currentIndex.value]
    }
    
    // MARK: - Init
    init(allItems: [SoundItems], startIndex: Int) {
        self.allItems = allItems
        self.currentIndex = BehaviorRelay(value: startIndex)
        
        setupInitialValues()
        setupAudioPlayer()
        setupBindings()
    }
    
    deinit {
        stopTimer()
        audioPlayer?.stop()
        print("RainSoundPlayerViewModel deinit")
    }
    
    // MARK: - Setup
    private func setupInitialValues() {
        albumImage.accept(currentItem.backgroundImage)
        titleText.accept(currentItem.title)
    }
    
    private func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: currentItem.fileName,
                                       withExtension: currentItem.fileType) else {
            print("Failed to find sound file: \(currentItem.fileName).\(currentItem.fileType)")
            return
        }
        
        do {
            // 기존 플레이어 정리
            audioPlayer?.stop()
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            
            if let duration = audioPlayer?.duration {
                totalTimeText.accept(formatTime(duration))
            }
            
            // 재생 상태 초기화
            currentTimeText.accept("0:00")
            progress.accept(0.0)
            
            print("Audio player loaded: \(currentItem.fileName)")
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
        
        // Previous 버튼
        previousTrigger
            .subscribe(onNext: { [weak self] in
                self?.moveToPrevious()
            })
            .disposed(by: disposeBag)
        
        // Next 버튼
        nextTrigger
            .subscribe(onNext: { [weak self] in
                self?.moveToNext()
            })
            .disposed(by: disposeBag)
        
        repeatTrigger
            .subscribe(onNext: { [weak self] in
                self?.toggleRepeat()
            })
            .disposed(by: disposeBag)
        
        shuffleTrigger
            .subscribe(onNext: { [weak self] in
                self?.toggleShuffle()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Track Navigation
    private func moveToPrevious() {
        if isShuffleEnabled.value {
            moveToPreviousShuffle()
        } else {
            moveToPreviousNormal()
        }
    }
    private func moveToNext() {
        if isShuffleEnabled.value {
            moveToNextShuffle()
        } else {
            moveToNextNormal()
        }
    }
    
    // 일반 모드 Previous
     private func moveToPreviousNormal() {
         let newIndex = currentIndex.value - 1
         
         if newIndex < 0 {
             currentIndex.accept(allItems.count - 1)
         } else {
             currentIndex.accept(newIndex)
         }
         
         loadNewTrack()
     }
    
    // 일반 모드 Next
        private func moveToNextNormal() {
            let newIndex = currentIndex.value + 1
            
            if newIndex >= allItems.count {
                currentIndex.accept(0)
            } else {
                currentIndex.accept(newIndex)
            }
            
            loadNewTrack()
        }
    
    // Shuffle 모드 Previous
       private func moveToPreviousShuffle() {
           guard !shuffledIndices.isEmpty else {
               createShuffledPlaylist()
               return
           }
           
           currentShufflePosition -= 1
           
           if currentShufflePosition < 0 {
               currentShufflePosition = shuffledIndices.count - 1
           }
           
           let newIndex = shuffledIndices[currentShufflePosition]
           currentIndex.accept(newIndex)
           loadNewTrack()
           
           print("Shuffle Previous: position \(currentShufflePosition), track: \(allItems[newIndex].title)")
       }
       
       // Shuffle 모드 Next
       private func moveToNextShuffle() {
           guard !shuffledIndices.isEmpty else {
               createShuffledPlaylist()
               return
           }
           
           currentShufflePosition += 1
           
           if currentShufflePosition >= shuffledIndices.count {
               // 셔플 리스트 끝나면 새로 섞기
               createShuffledPlaylist()
               currentShufflePosition = 0
           }
           
           let newIndex = shuffledIndices[currentShufflePosition]
           currentIndex.accept(newIndex)
           loadNewTrack()
           
           print("Shuffle Next: position \(currentShufflePosition), track: \(allItems[newIndex].title)")
       }
    
    private func toggleRepeat() {
        let newValue = !isRepeatEnabled.value
        isRepeatEnabled.accept(newValue)
        
        // Repeat ON이면 Shuffle OFF
        if newValue && isShuffleEnabled.value {
            isShuffleEnabled.accept(false)
            shuffledIndices.removeAll()
            print("Shuffle disabled (Repeat enabled)")
        }
        
        print("Repeat mode: \(newValue ? "ON" : "OFF")")
    }
    
    private func toggleShuffle() {
        let newValue = !isShuffleEnabled.value
        isShuffleEnabled.accept(newValue)
        
        // Shuffle ON이면 Repeat OFF
        if newValue && isRepeatEnabled.value {
            isRepeatEnabled.accept(false)
            print("Repeat disabled (Shuffle enabled)")
        }
        
        if newValue {
            // Shuffle ON: 셔플 배열 생성
            createShuffledPlaylist()
            print("Shuffle mode: ON")
        } else {
            // Shuffle OFF: 셔플 배열 초기화
            shuffledIndices.removeAll()
            print("Shuffle mode: OFF")
        }
    }
    
    private func createShuffledPlaylist() {
           // 현재 재생 중인 트랙을 제외한 나머지를 셔플
           var indices = Array(0..<allItems.count)
           let currentIdx = currentIndex.value
           
           // 현재 트랙 제거
           indices.removeAll { $0 == currentIdx }
           
           // 나머지를 섞기
           indices.shuffle()
           
           // 현재 트랙을 맨 앞에 배치
           shuffledIndices = [currentIdx] + indices
           currentShufflePosition = 0
           
           print("Shuffled playlist: \(shuffledIndices)")
       }
    
    private func loadNewTrack() {
        // 재생 중이었는지 확인
        let wasPlaying = isPlaying.value
        
        // 기존 재생 정지
        if wasPlaying {
            stopTimer()
            audioPlayer?.stop()
        }
        
        // UI 업데이트
        albumImage.accept(currentItem.backgroundImage)
        titleText.accept(currentItem.title)
        
        // 새 플레이어 로드
        setupAudioPlayer()
        
        // 이전에 재생 중이었으면 자동 재생
        if wasPlaying {
            audioPlayer?.play()
            startTimer()
            isPlaying.accept(true)
        } else {
            isPlaying.accept(false)
        }
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
        
        // 트랙 끝나면 자동으로 다음
        if current >= total - 0.1 && total > 0 {
            handleTrackEnd()
        }
    }
    
    private func handleTrackEnd() {
          if isRepeatEnabled.value {
              // Repeat 모드: 현재 트랙 처음부터 다시 재생
              audioPlayer?.currentTime = 0
              audioPlayer?.play()
              print("Repeating current track")
          } else {
              // 일반 모드: 다음 트랙으로 이동
              moveToNext()
              print("Moving to next track")
          }
      }
    
    // MARK: - Helpers
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
