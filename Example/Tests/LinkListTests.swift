//
//  LinkListTests.swift
//  Puyopuyo_Tests
//
//  Created by J on 2022/3/30.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

@testable import Puyopuyo
import XCTest

class LinkListTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLinkList() throws {
        let list = LinkList<Int>()

        XCTAssert(list.isEmpty)

        let nums = [1, 2, 3, 4]

        nums.forEach { list.append($0) }

        XCTAssert(list.count == nums.count)

        var total = 0
        list.forEach { total += $0 }
        XCTAssert(total == nums.reduce(0) { $1 + $0 })

        XCTAssert(list.first == nums.first)
        XCTAssert(list.last == nums.last)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
