//
//  PlayerView.swift
//  Umbrella
//

import SwiftUI

/// 홈 화면. 장면을 화면 가득 보여주고 빗소리를 재생한다.
struct PlayerView: View {
    @State private var player = SoundPlayer()
    @State private var isPickingScene = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(player.scene.title)
                .font(.title2.weight(.semibold))
            Button {
                player.toggle()
            } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 32))
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .accessibilityLabel(player.isPlaying ? "일시정지" : "재생")
            Button("장면 고르기") {
                isPickingScene = true
            }
            .buttonStyle(.bordered)
        }
        .padding(.bottom, 48)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Group {
                if let url = player.scene.videoURL {
                    LoopingVideoView(url: url)
                } else {
                    Image(player.scene.imageName)
                        .resizable()
                        .scaledToFill()
                }
            }
            .overlay(Color.black.opacity(0.3))
            .id(player.scene.id)
            .transition(.opacity)
            .ignoresSafeArea()
        }
        .animation(.easeInOut(duration: 0.8), value: player.scene)
        .sheet(isPresented: $isPickingScene) {
            ScenePicker(current: player.scene) { scene in
                // shortcut: 결제 전이라 잠긴 장면도 재생된다, 3단계에서 결제 화면으로 막는다
                player.select(scene)
                isPickingScene = false
            }
            .presentationDetents([.height(320)])
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
