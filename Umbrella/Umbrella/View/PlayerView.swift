//
//  PlayerView.swift
//  Umbrella
//

import SwiftUI
import TipKit

/// 홈 화면. 장면을 화면 가득 보여주고 빗소리를 재생한다.
struct PlayerView: View {
    private enum Sheet: String, Identifiable {
        case scenes, timer
        var id: String { rawValue }
    }

    @State private var player = SoundPlayer()
    @State private var focus = FocusTimer()
    @State private var sheet: Sheet?
    @State private var controlsVisible = true
    @State private var interactions = 0
    @State private var lockTipShowing = false
    @State private var isShowingLockHelp = false
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let lockScreenTip = LockScreenTip()

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            if let start = focus.startDate {
                FocusCountdown(start: start)
            }
            controls
                .opacity(controlsVisible ? 1 : 0)
                .allowsHitTesting(controlsVisible)
        }
        .padding(.bottom, 48)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: showControls)
        .overlay(alignment: .topTrailing) {
            if #available(iOS 26.0, *), player.scene.videoName != nil {
                lockScreenHelpButton
                    .opacity(controlsVisible ? 1 : 0)
                    .allowsHitTesting(controlsVisible)
            }
        }
        .background {
            Group {
                if let url = player.scene.videoURL {
                    LoopingVideoView(url: url)
                } else {
                    Image(player.scene.imageName)
                        .resizable()
                        .scaledToFill()
                        .overlay {
                            if !reduceMotion { RainOverlay() }
                        }
                }
            }
            .overlay(Color.black.opacity(0.3))
            .id(player.scene.id)
            .transition(.opacity)
            .ignoresSafeArea()
        }
        .statusBarHidden(!controlsVisible)
        .animation(.easeInOut(duration: 0.8), value: player.scene)
        .animation(.easeInOut(duration: 0.6), value: controlsVisible)
        .onChange(of: player.isPlaying && player.scene.videoName != nil, initial: true) { _, playingVideo in
            LockScreenTip.isPlayingVideo = playingVideo
        }
        .task {
            for await showing in lockScreenTip.shouldDisplayUpdates {
                lockTipShowing = showing
            }
        }
        // 안내 말풍선은 6초 뒤 버튼으로 접힌다. 그 뒤로는 버튼을 눌러 다시 본다.
        .task(id: lockTipShowing) {
            guard lockTipShowing else { return }
            try? await Task.sleep(for: .seconds(6))
            guard !Task.isCancelled else { return }
            lockScreenTip.invalidate(reason: .tipClosed)
        }
        // 재생 중에 4초 동안 손대지 않으면 버튼을 숨긴다. 화면을 누르면 다시 보인다.
        .task(id: "\(interactions)-\(player.isPlaying)-\(sheet == nil)-\(lockTipShowing)") {
            guard player.isPlaying, sheet == nil, !voiceOverEnabled, !lockTipShowing else { return }
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            controlsVisible = false
        }
        .sheet(item: $sheet, onDismiss: showControls) { sheet in
            switch sheet {
            case .scenes:
                ScenePicker(current: player.scene) { scene in
                    // shortcut: 결제 전이라 잠긴 장면도 재생된다, 3단계에서 결제 화면으로 막는다
                    player.select(scene)
                    self.sheet = nil
                }
                .presentationDetents([.height(320)])
            case .timer:
                TimerSheet(player: player, focus: focus)
                    .presentationDetents([.medium])
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 24) {
            Text(player.scene.title)
                .font(.title2.weight(.semibold))
            Button {
                player.toggle()
                interactions += 1
            } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 32))
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel(player.isPlaying ? "일시정지" : "재생")
            HStack(spacing: 12) {
                Button("장면 고르기") { sheet = .scenes }
                Button {
                    sheet = .timer
                } label: {
                    Label("타이머", systemImage: player.sleepEndDate == nil && focus.startDate == nil ? "timer" : "timer.circle.fill")
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private var lockScreenHelpButton: some View {
        Button {
            isShowingLockHelp = true
            interactions += 1
        } label: {
            Image(systemName: "lock.iphone")
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
        }
        .accessibilityLabel("잠금 화면 안내")
        .popoverTip(lockScreenTip, arrowEdge: .top)
        .popover(isPresented: $isShowingLockHelp) {
            VStack(alignment: .leading, spacing: 8) {
                Text(LockScreenTip.titleText)
                    .font(.headline)
                Text(LockScreenTip.messageText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(width: 280)
            .presentationCompactAdaptation(.popover)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func showControls() {
        controlsVisible = true
        interactions += 1
    }
}

/// 집중 타이머가 켜져 있을 때 지금 단계와 남은 시간을 보여준다. 버튼을 숨겨도 남는다.
private struct FocusCountdown: View {
    let start: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let (phase, endsAt) = FocusTimer.phase(at: context.date, since: start)
            let remaining = Duration.seconds(max(0, endsAt.timeIntervalSince(context.date)))
            Text("\(phase == .focus ? "집중" : "휴식") · \(remaining.formatted(.time(pattern: .minuteSecond)))")
                .font(.title3.monospacedDigit().weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

/// 집중 타이머와 예약 종료를 고른다.
private struct TimerSheet: View {
    let player: SoundPlayer
    let focus: FocusTimer

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("집중 타이머", isOn: Binding(
                        get: { focus.startDate != nil },
                        set: { $0 ? focus.start() : focus.stop() }
                    ))
                } footer: {
                    Text("25분 집중하고 5분 쉬는 것을 반복해요. 켜 두는 동안 화면이 꺼지지 않아요.")
                }
                Section {
                    Picker("예약 종료", selection: Binding(
                        get: { player.sleepMinutes },
                        set: { player.setSleepTimer(minutes: $0) }
                    )) {
                        Text("끄기").tag(0)
                        Text("15분").tag(15)
                        Text("30분").tag(30)
                        Text("60분").tag(60)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("예약 종료")
                } footer: {
                    if let end = player.sleepEndDate {
                        Text("\(end.formatted(date: .omitted, time: .shortened))에 소리가 서서히 꺼져요.")
                    }
                }
            }
            .navigationTitle("타이머")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// 장면을 한 장씩 넘겨 고른다.
private struct ScenePicker: View {
    let current: RainScene
    let onSelect: (RainScene) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(RainScene.all) { scene in
                    Button {
                        onSelect(scene)
                    } label: {
                        card(scene)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(scene.isFree ? scene.title : "\(scene.title), 잠김")
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 24, for: .scrollContent)
    }

    private func card(_ scene: RainScene) -> some View {
        Image(scene.imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 180, height: 240)
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: 6) {
                    if !scene.isFree {
                        Image(systemName: "lock.fill")
                    }
                    Text(scene.title)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .shadow(radius: 4)
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.white, lineWidth: scene == current ? 3 : 0)
            }
    }
}
