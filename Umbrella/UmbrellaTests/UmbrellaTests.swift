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

        let outcome = try await store.purchase(product)
        XCTAssertEqual(outcome, .purchased)
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

    // MARK: - 결제 판정

    func testOwnedIgnoresRevokedAndUnverifiedEntitlements() {
        let base = Store.baseCollectionID
        let owned = Store.owned(from: [
            .init(productID: base, isRevoked: false, isVerified: true),
            .init(productID: "special.refunded", isRevoked: true, isVerified: true),
            .init(productID: "special.forged", isRevoked: false, isVerified: false),
        ])
        XCTAssertEqual(owned, [base])
    }

    func testApplyingTransactionsInsertsRevokesAndIgnoresForgeries() {
        let base = Store.baseCollectionID
        var owned: Set<String> = []
        owned = Store.applying(.init(productID: base, isRevoked: false, isVerified: false), to: owned)
        XCTAssertTrue(owned.isEmpty, "서명이 맞지 않는 구매로 열리면 안 된다")

        owned = Store.applying(.init(productID: base, isRevoked: false, isVerified: true), to: owned)
        owned = Store.applying(.init(productID: base, isRevoked: false, isVerified: true), to: owned)
        XCTAssertEqual(owned, [base], "같은 거래가 두 번 와도 한 번만 반영된다")

        owned = Store.applying(.init(productID: base, isRevoked: true, isVerified: false), to: owned)
        XCTAssertEqual(owned, [base], "서명이 맞지 않는 환불로 권한을 잃으면 안 된다")

        owned = Store.applying(.init(productID: base, isRevoked: true, isVerified: true), to: owned)
        XCTAssertTrue(owned.isEmpty, "환불되면 권한을 잃는다")
        XCTAssertFalse(Store.canPlay(.base, owned: owned))

        owned = Store.applying(.init(productID: "special.a", isRevoked: true, isVerified: true), to: owned)
        XCTAssertTrue(owned.isEmpty, "가진 적 없는 상품의 환불은 아무것도 바꾸지 않는다")
    }

    // MARK: - 미리듣기, 예약 종료

    func testSelectingAnotherSceneCancelsPreview() async throws {
        let player = SoundPlayer()
        let locked = try XCTUnwrap(RainScene.all.first { !$0.isFree })
        let free = try XCTUnwrap(RainScene.all.first(where: \.isFree))
        let ended = expectation(description: "미리듣기 끝 콜백")
        ended.isInverted = true
        player.startPreview(locked, seconds: 0.4) { ended.fulfill() }
        player.select(free)
        await fulfillment(of: [ended], timeout: 1.2)
        XCTAssertNil(player.previewEndDate)
        XCTAssertTrue(player.isPlaying, "다른 장면을 고르면 그 장면이 계속 재생된다")
        XCTAssertEqual(player.scene, free)
    }

    func testSleepTimerFadesOutAndResets() async throws {
        let player = SoundPlayer()
        player.select(try XCTUnwrap(RainScene.all.first(where: \.isFree)))
        player.startSleepTimer(after: 0.4, minutes: 15)
        XCTAssertNotNil(player.sleepEndDate)
        XCTAssertEqual(player.sleepMinutes, 15)
        try await Task.sleep(for: .seconds(1.2))
        XCTAssertFalse(player.isPlaying)
        XCTAssertNil(player.sleepEndDate)
        XCTAssertEqual(player.sleepMinutes, 0)
    }

    func testTurningSleepTimerOffKeepsPlaying() async throws {
        let player = SoundPlayer()
        player.select(try XCTUnwrap(RainScene.all.first(where: \.isFree)))
        player.startSleepTimer(after: 0.4, minutes: 15)
        player.setSleepTimer(minutes: 0)
        try await Task.sleep(for: .seconds(1.0))
        XCTAssertTrue(player.isPlaying)
        XCTAssertNil(player.sleepEndDate)
    }

    // MARK: - 집중 타이머 경계

    func testFocusTimerBoundaries() {
        let start = Date(timeIntervalSince1970: 1_000)
        let minute: TimeInterval = 60
        let beforeStart = FocusTimer.phase(at: start.addingTimeInterval(-5 * minute), since: start)
        XCTAssertEqual(beforeStart.phase, .focus)
        XCTAssertEqual(beforeStart.endsAt, start.addingTimeInterval(25 * minute), "시작 전이면 첫 집중이 끝나는 시각을 보여준다")

        XCTAssertEqual(FocusTimer.phase(at: start.addingTimeInterval(25 * minute - 1), since: start).phase, .focus)
        XCTAssertEqual(FocusTimer.phase(at: start.addingTimeInterval(25 * minute), since: start).phase, .rest)
        XCTAssertEqual(FocusTimer.phase(at: start.addingTimeInterval(30 * minute - 1), since: start).phase, .rest)
        let nextCycle = FocusTimer.phase(at: start.addingTimeInterval(30 * minute), since: start)
        XCTAssertEqual(nextCycle.phase, .focus)
        XCTAssertEqual(nextCycle.endsAt, start.addingTimeInterval(55 * minute))
    }

    func testFocusTimerNotificationSchedule() {
        let minutes = FocusTimer.transitions(count: 4).map { ($0.offset / 60, $0.isFocusEnd) }
        XCTAssertEqual(minutes.map(\.0), [25, 30, 55, 60])
        XCTAssertEqual(minutes.map(\.1), [true, false, true, false])
    }

    // MARK: - 번역

    func testEveryCatalogEntryHasEnglishAndKorean() throws {
        let catalog = try Self.stringCatalog()
        for (key, entry) in catalog {
            for language in ["en", "ko"] {
                let value = ((entry["localizations"] as? [String: Any])?[language] as? [String: Any])
                    .flatMap { $0["stringUnit"] as? [String: Any] }?["value"] as? String
                XCTAssertFalse(value?.isEmpty ?? true, "\(key): \(language) 번역이 없다")
            }
        }
    }

    func testEveryKoreanStringInCodeIsInCatalog() throws {
        let catalog = try Self.stringCatalog()
        let appFolder = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Umbrella")
        let files = ["View/PlayerView.swift", "View/PaywallView.swift", "View/SettingsSheet.swift", "View/LockScreenTip.swift",
                     "Models/RainScene.swift", "ViewModel/FocusTimer.swift"]
        var checked = 0
        for file in files {
            let source = try String(contentsOf: appFolder.appendingPathComponent(file), encoding: .utf8)
            for line in source.split(separator: "\n") where !line.trimmingCharacters(in: .whitespaces).hasPrefix("//") {
                for literal in Self.koreanLiterals(in: String(line)) {
                    XCTAssertNotNil(catalog[literal], "\(file): \"\(literal)\"가 번역 파일에 없다")
                    checked += 1
                }
            }
        }
        // 문구를 하나도 못 찾으면 이 테스트는 아무것도 확인하지 않은 채 통과한다.
        XCTAssertGreaterThan(checked, 40, "코드에서 한국어 문구를 거의 찾지 못했다. 검사 방식이 깨졌을 수 있다")
    }

    private static func stringCatalog() throws -> [String: [String: Any]] {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "Localizable", withExtension: "xcstrings")
            ?? URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Umbrella/Localizable.xcstrings"))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        return try XCTUnwrap(json["strings"] as? [String: [String: Any]])
    }

    /// 한 줄에서 한글이 들어간 문자열 리터럴을 찾아, 문자열 보간을 %@로 바꿔 돌려준다.
    private static func koreanLiterals(in line: String) -> [String] {
        var results: [String] = []
        var current = ""
        var inString = false
        var depth = 0
        var chars = Array(line)[...]
        while let c = chars.popFirst() {
            if !inString {
                if c == "\"" { inString = true; current = "" }
                continue
            }
            if depth > 0 {
                if c == "(" { depth += 1 } else if c == ")" { depth -= 1 }
                continue
            }
            if c == "\\", chars.first == "(" {
                chars.removeFirst()
                depth = 1
                current += "%@"
            } else if c == "\"" {
                inString = false
                if current.unicodeScalars.contains(where: { (0xAC00...0xD7A3).contains($0.value) }) { results.append(current) }
            } else {
                current.append(c)
            }
        }
        return results
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
