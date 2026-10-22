//
//  Store.swift
//  Umbrella
//

import Observation
import StoreKit

/// 한 번 결제로 기본 컬렉션(지금 장면과 앞으로 추가되는 기본 장면)을 연다. 특별 컬렉션은 나중에 별도 상품으로 판다.
@MainActor
@Observable
final class Store {
    static let unlockID = "com.jaehyeonLim9298.petrichor.basecollection"

    private(set) var product: Product?
    private var ownsBaseCollection = false
    #if DEBUG
    /// 테스트용: 샀어도 안 산 것처럼 보여준다. 디버그 빌드에만 있다.
    var debugShowsLocked = false
    #endif

    var isUnlocked: Bool {
        #if DEBUG
        if debugShowsLocked { return false }
        #endif
        return ownsBaseCollection
    }
    /// 구매 기록 확인이 끝났는지. 끝나기 전에는 잠긴 장면을 막지 않는다.
    private(set) var isLoaded = false

    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    init() {
        // 다른 기기에서 산 것, 환불, 승인 대기 후 완료된 구매가 여기로 온다.
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handle(update)
            }
        }
        Task { await refresh() }
    }

    func refresh() async {
        product = try? await Product.products(for: [Self.unlockID]).first
        var unlocked = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.unlockID, transaction.revocationDate == nil {
                unlocked = true
            }
        }
        ownsBaseCollection = unlocked
        isLoaded = true
    }

    /// 구매가 끝나면 true. 취소했거나 승인 대기(자녀 보호 등)면 false.
    func purchase() async throws -> Bool {
        guard let product else { return false }
        switch try await product.purchase() {
        case .success(let result):
            guard case .verified(let transaction) = result else { return false }
            await transaction.finish()
            ownsBaseCollection = true
            #if DEBUG
            debugShowsLocked = false
            #endif
            return true
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    /// App Store와 구매 기록을 맞춘다. 앱을 다시 깔았거나 기기를 바꾼 사람이 쓴다.
    func restore() async throws {
        try await AppStore.sync()
        await refresh()
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        if transaction.productID == Self.unlockID {
            ownsBaseCollection = transaction.revocationDate == nil
        }
        await transaction.finish()
    }
}
