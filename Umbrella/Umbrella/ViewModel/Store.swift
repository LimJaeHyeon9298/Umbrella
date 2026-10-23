//
//  Store.swift
//  Umbrella
//

import Observation
import StoreKit

/// 장면을 여는 상품을 판다. 기본 컬렉션은 한 번 결제로 지금 장면과 앞으로 추가되는 기본 장면을 열고,
/// 특별 컬렉션 장면은 각자의 상품으로만 열린다.
@MainActor
@Observable
final class Store {
    nonisolated static let baseCollectionID = "com.jaehyeonLim9298.petrichor.basecollection"

    /// 앱이 파는 모든 상품. 특별 컬렉션 상품은 장면 목록에서 모은다.
    nonisolated static var allProductIDs: [String] {
        [baseCollectionID] + Set(RainScene.all.compactMap(\.specialProductID)).sorted()
    }

    /// 무엇을 샀을 때 이 장면이 열리는지.
    nonisolated static func canPlay(_ access: RainScene.Access, owned: Set<String>) -> Bool {
        switch access {
        case .free:
            return true
        case .base:
            return owned.contains(baseCollectionID)
        case .special(let productID):
            return owned.contains(productID)
        }
    }

    /// 이 장면을 열려면 사야 하는 상품. 무료 장면이면 nil.
    nonisolated static func productID(for scene: RainScene) -> String? {
        switch scene.access {
        case .free:
            return nil
        case .base:
            return baseCollectionID
        case .special(let productID):
            return productID
        }
    }

    private(set) var products: [String: Product] = [:]
    private var ownedProductIDs: Set<String> = []
    /// 구매 기록 확인이 끝났는지. 끝나기 전에는 잠긴 장면을 막지 않는다.
    private(set) var isLoaded = false
    #if DEBUG
    /// 테스트용: 샀어도 안 산 것처럼 보여준다. 디버그 빌드에만 있다.
    var debugShowsLocked = false
    #endif

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

    var ownsBaseCollection: Bool {
        #if DEBUG
        if debugShowsLocked { return false }
        #endif
        return ownedProductIDs.contains(Self.baseCollectionID)
    }

    func canPlay(_ scene: RainScene) -> Bool {
        #if DEBUG
        if debugShowsLocked { return scene.isFree }
        #endif
        return Self.canPlay(scene.access, owned: ownedProductIDs)
    }

    /// 장면을 여는 상품. 장면이 없으면 기본 컬렉션.
    func product(for scene: RainScene?) -> Product? {
        products[scene.flatMap(Self.productID) ?? Self.baseCollectionID]
    }

    func refresh() async {
        let loaded = (try? await Product.products(for: Self.allProductIDs)) ?? []
        products = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
        var owned: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.revocationDate == nil {
                owned.insert(transaction.productID)
            }
        }
        ownedProductIDs = owned
        isLoaded = true
    }

    /// 구매가 끝나면 true. 취소했거나 승인 대기(자녀 보호 등)면 false.
    func purchase(_ product: Product) async throws -> Bool {
        switch try await product.purchase() {
        case .success(let result):
            guard case .verified(let transaction) = result else { return false }
            await transaction.finish()
            ownedProductIDs.insert(transaction.productID)
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
        if transaction.revocationDate == nil {
            ownedProductIDs.insert(transaction.productID)
        } else {
            ownedProductIDs.remove(transaction.productID)
        }
        await transaction.finish()
    }
}
