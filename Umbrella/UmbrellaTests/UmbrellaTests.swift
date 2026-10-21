//
//  UmbrellaTests.swift
//  UmbrellaTests
//
//  Created by 임재현 on 6/21/24.
//

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
