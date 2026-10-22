//
//  PaywallView.swift
//  Umbrella
//

import SwiftUI

/// 잠긴 장면을 눌렀을 때 뜬다. 한 번 결제로 기본 컬렉션을 연다.
struct PaywallView: View {
    let store: Store
    let onUnlocked: () -> Void

    @State private var isWorking = false
    @State private var message: String?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cloud.rain.fill")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            Text("기본 컬렉션 열기")
                .font(.title2.bold())
            VStack(alignment: .leading, spacing: 10) {
                Label("지금 있는 모든 장면", systemImage: "checkmark")
                Label("새 기본 장면 업데이트 포함", systemImage: "checkmark")
                Label("한 번 결제, 구독 아님", systemImage: "checkmark")
            }
            .font(.callout)
            Button {
                Task { await buy() }
            } label: {
                Text(buttonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(store.product == nil || isWorking)
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
