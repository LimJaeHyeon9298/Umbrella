//
//  PaywallView.swift
//  Umbrella
//

import SwiftUI

/// 한 번 결제로 기본 컬렉션을 연다. 잠긴 장면을 눌렀을 때는 미리듣기도 함께 고를 수 있다.
struct PaywallView: View {
    let store: Store
    /// 눌렀던 잠긴 장면. 있으면 위에 보여준다.
    var scene: RainScene?
    /// 있으면 "1분 미리듣기"를 가장 크게 보여준다. 미리듣기가 끝난 뒤에는 nil로 연다.
    var onPreview: (() -> Void)?
    let onUnlocked: () -> Void

    @State private var isWorking = false
    @State private var message: String?

    var body: some View {
        VStack(spacing: 20) {
            if let scene {
                Image(scene.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 96, height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityHidden(true)
                VStack(spacing: 4) {
                    Text(scene.title)
                        .font(.title2.bold())
                    Text("기본 컬렉션에 있는 장면이에요")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                Image(systemName: "cloud.rain.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
                Text("기본 컬렉션 열기")
                    .font(.title2.bold())
            }
            VStack(alignment: .leading, spacing: 10) {
                Label("지금 있는 모든 장면", systemImage: "checkmark")
                Label("새 기본 장면 업데이트 포함", systemImage: "checkmark")
                Label("한 번 결제, 구독 아님", systemImage: "checkmark")
            }
            .font(.callout)
            if let onPreview {
                Button(action: onPreview) {
                    Text("1분 미리듣기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                buyButton
                    .buttonStyle(.bordered)
            } else {
                buyButton
                    .buttonStyle(.borderedProminent)
            }
            Button("구매 복원") {
                Task { await restore() }
            }
            .font(.footnote)
            .disabled(isWorking)
            if let message {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
    }

    private var buyButton: some View {
        Button {
            Task { await buy() }
        } label: {
            Text(buttonTitle)
                .frame(maxWidth: .infinity)
        }
        .controlSize(.large)
        .disabled(store.product == nil || isWorking)
    }

    private var buttonTitle: String {
        if let product = store.product {
            return "\(product.displayPrice)에 열기"
        }
        return store.isLoaded ? "지금은 구매할 수 없어요" : "가격을 불러오는 중"
    }

    private func buy() async {
        isWorking = true
        defer { isWorking = false }
        do {
            if try await store.purchase() {
                onUnlocked()
            }
        } catch {
            message = "구매를 완료하지 못했어요. 잠시 후 다시 시도해 주세요."
        }
    }

    private func restore() async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await store.restore()
            if store.isUnlocked {
                onUnlocked()
            } else {
                message = "복원할 구매 내역이 없어요."
            }
        } catch {
            message = "구매 내역을 불러오지 못했어요. 잠시 후 다시 시도해 주세요."
        }
    }
}

extension View {
    /// 시트 높이를 내용에 맞춘다. 화면 절반으로 고정하면 작은 아이폰에서 위가 잘린다.
    func fittedSheetHeight() -> some View {
        modifier(FittedSheetHeight())
    }
}

private struct FittedSheetHeight: ViewModifier {
    @State private var height: CGFloat = 420

    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { height = proxy.size.height }
                        .onChange(of: proxy.size.height) { _, newHeight in height = newHeight }
                }
            }
            .presentationDetents([.height(height)])
    }
}
