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

    func testRemove() throws {
        let list = LinkList<Int>()

        XCTAssert(list.isEmpty)

        let nums = [0, 1, 2, 3, 4]

        nums.forEach { list.append($0) }

        list.removeAll(where: { $0 == 0 })

        XCTAssert(list.first == 1)
        XCTAssert(list.last == 4)
        XCTAssert(list.count == nums.count - 1)

        list.removeAll(where: { $0 == 4 })

        XCTAssert(list.first == 1)
        XCTAssert(list.last == 3)
        XCTAssert(list.count == nums.count - 2)

        list.removeAll(where: { $0 == 2 })

        XCTAssert(list.first == 1)
        XCTAssert(list.last == 3)
        XCTAssert(list.count == nums.count - 3)

        list.removeAll()

        XCTAssert(list.first == nil)
        XCTAssert(list.last == nil)
        XCTAssert(list.count == 0)
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

    func testCompareArray() throws {
        var array = [Int]()
        let list = LinkList<Int>()

        let lt = profileTime(label: "List", times: times) { c in
            list.append(c)
        }
        let at = profileTime(label: "Array", times: times) { c in
            array.append(c)
        }

        print("list / array = \(lt / at)")
    }

    private let times = 10000

    func testListPerformance() throws {
        self.measure {
//            var list = [Int]()
            let list = LinkList<Int>()

            for i in 0 ..< times {
                list.append(i)
            }
        }
    }

    func testArrayPerformance() throws {
        self.measure {
            var list = [Int]()

            for i in 0 ..< times {
                list.append(i)
            }
        }
    }
}
