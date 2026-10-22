//
//  UmbrellaUITests.swift
//  UmbrellaUITests
//
//  Created by 임재현 on 6/21/24.
//

import XCTest

final class UmbrellaUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    /// 잠긴 장면을 누르면 미리듣기와 결제를 고르는 화면이 뜬다.
    func testLockedSceneOffersPreviewAndPurchase() throws {
        let app = XCUIApplication()
        app.launch()
        attachScreenshot(of: app, named: "1-player")

        app.buttons["장면 고르기"].tap()
        let locked = app.buttons["천둥 치는 밤, 잠김, 1분 미리듣기 가능"]
        XCTAssertTrue(locked.waitForExistence(timeout: 5))
        attachScreenshot(of: app, named: "2-scenes")
        locked.tap()

        XCTAssertTrue(app.buttons["1분 미리듣기"].waitForExistence(timeout: 5))
        attachScreenshot(of: app, named: "3-paywall")
    }

    private func attachScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
