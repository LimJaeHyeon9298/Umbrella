//
//  UmbrellaTests.swift
//  UmbrellaTests
//
//  Created by 임재현 on 6/21/24.
//

import StoreKit
import StoreKitTest
import XCTest
@testable import Umbrella

final class UmbrellaTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEveryRainSceneHasItsSoundAndImage() {
        XCTAssertEqual(Set(RainScene.all.map(\.id)).count, RainScene.all.count, "장면 id가 겹친다")
        XCTAssertTrue(RainScene.all.contains(where: \.isFree), "무료 장면이 하나는 있어야 한다")
        for scene in RainScene.all {
            XCTAssertNotNil(scene.soundURL, "\(scene.id): 소리 파일이 번들에 없다")
            XCTAssertNotNil(UIImage(named: scene.imageName), "\(scene.id): 이미지가 없다")
            if scene.videoName != nil {
                XCTAssertNotNil(scene.videoURL, "\(scene.id): 영상이 없다")
                XCTAssertNotNil(scene.tallVideoURL, "\(scene.id): 세로 영상이 없다")
                XCTAssertNotNil(UIImage(named: scene.tallImageName), "\(scene.id): 세로 미리보기 이미지가 없다")
            }
        }
    }

    func testFocusTimerAlternatesFocusAndRest() {
        let start = Date(timeIntervalSince1970: 0)
        let minute: TimeInterval = 60
        let atStart = FocusTimer.phase(at: start, since: start)
        XCTAssertEqual(atStart.phase, .focus)
        XCTAssertEqual(atStart.endsAt, start.addingTimeInterval(25 * minute))

        let atRest = FocusTimer.phase(at: start.addingTimeInterval(25 * minute), since: start)
        XCTAssertEqual(atRest.phase, .rest)
        XCTAssertEqual(atRest.endsAt, start.addingTimeInterval(30 * minute))

        let secondCycle = FocusTimer.phase(at: start.addingTimeInterval(31 * minute), since: start)
        XCTAssertEqual(secondCycle.phase, .focus)
        XCTAssertEqual(secondCycle.endsAt, start.addingTimeInterval(55 * minute))
    }

    @MainActor
    func testPurchaseUnlocksBaseCollection() async throws {
        let session = try SKTestSession(configurationFileNamed: "Petrichor")
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true

        let store = Store()
        await store.refresh()
        // shortcut: 명령줄(xcodebuild) 시뮬레이터에서는 시험용 상품이 0개로 와서 건너뛴다, 원인을 찾으면 건너뛰기를 없앤다
        try XCTSkipIf(store.products.isEmpty, "시험용 상품을 불러오지 못했다 (Petrichor.storekit)")
        let product = try XCTUnwrap(store.products[Store.baseCollectionID])
        XCTAssertFalse(store.ownsBaseCollection)

        let purchased = try await store.purchase(product)
        XCTAssertTrue(purchased)
        XCTAssertTrue(store.ownsBaseCollection)

        await store.refresh()
        XCTAssertTrue(store.ownsBaseCollection, "다시 확인해도 구매 기록이 남아 있어야 한다")
    }

    func testPreviewStopsLockedSceneAndCallsBack() async {
        let player = SoundPlayer()
        let locked = RainScene.all.first { !$0.isFree }!
        let ended = expectation(description: "미리듣기 끝")
        player.startPreview(locked, seconds: 0.4) { ended.fulfill() }
        XCTAssertNotNil(player.previewEndDate)
        await fulfillment(of: [ended], timeout: 3)
        XCTAssertNil(player.previewEndDate)
        XCTAssertFalse(player.isPlaying)
    }

    func testBaseCollectionDoesNotUnlockSpecialScenes() {
        let base = Store.baseCollectionID
        let special = RainScene.Access.special(productID: "special.a")
        XCTAssertTrue(Store.canPlay(.free, owned: []))
        XCTAssertFalse(Store.canPlay(.base, owned: []))
        XCTAssertTrue(Store.canPlay(.base, owned: [base]))
        XCTAssertFalse(Store.canPlay(special, owned: [base]), "기본 컬렉션으로 특별 장면이 열리면 안 된다")
        XCTAssertTrue(Store.canPlay(special, owned: ["special.a"]))
        XCTAssertFalse(Store.canPlay(.base, owned: ["special.a"]), "특별 상품으로 기본 장면이 열리면 안 된다")
    }

    func testEveryProductIsInStoreKitConfiguration() throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "Petrichor", withExtension: "storekit"))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        let configured = Set((json["products"] as? [[String: Any]] ?? []).compactMap { $0["productID"] as? String })
        for productID in Store.allProductIDs {
            XCTAssertTrue(configured.contains(productID), "\(productID)가 Petrichor.storekit에 없다")
        }
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
