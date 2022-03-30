//
//  CompareTests.swift
//  Puyopuyo_Tests
//
//  Created by J on 2022/3/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Puyopuyo
import TangramKit
import XCTest

class CompareTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCompareLinearLayout() throws {
        let pv = PuyoLinearLayoutView()
        let tv = TKLinearLayoutView(frame: .zero, orientation: .horz)

        let times = 50

        let pi = profileTime(label: "puyo", times: times) {
            _ = pv.sizeThatFits(.zero)
        }
        let ti = profileTime(label: "tk", times: times) {
            _ = tv.sizeThatFits(.zero)
        }

        print("p / t = \(pi / ti)")
    }

    func testCompareFlowLayout() throws {
        let arrange = 0

        let pv = PuyoFlowLayoutView().attach()
            .arrangeCount(arrange)
            .view
        let tv = TKFlowLayoutView(frame: .zero, orientation: .vert)
        tv.tg_arrangedCount = arrange

        let times = 50

        let pi = profileTime(label: "puyo", times: times) {
            _ = pv.sizeThatFits(.zero)
        }
        let ti = profileTime(label: "tk", times: times) {
            _ = tv.sizeThatFits(.zero)
        }

        print("p / t = \(pi / ti)")
    }
}
