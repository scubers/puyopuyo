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
        let sv = CocoaStackView()
        let yv = YogaLinearView()

        let times = 50

        let pi = profileTime(label: "puyo", times: times) {
            _ = pv.sizeThatFits(.zero)
        }
        let ti = profileTime(label: "tk", times: times) {
            _ = tv.sizeThatFits(.zero)
        }
        let si = profileTime(label: "stackview", times: times) {
            _ = sv.sizeThatFits(.zero)
        }

        let yi = profileTime(label: "yoga", times: times) {
            if yv.yoga.flexDirection == .column {
                yv.yoga.flexDirection = .row
            } else {
                yv.yoga.flexDirection = .column
            }
            yv.yoga.applyLayout(preservingOrigin: false, dimensionFlexibility: .flexibleHeight.union(.flexibleWidth))
        }

        print("=======LinearLayout profiles======")
        print("p / tg = \(pi / ti)")
        print("p / stackview = \(pi / si)")
        print("p / yoga = \(pi / yi)")
    }

    func testLinearRecusiveLayout() throws {
        let count = 50
        let pv = createPuyopuyoRecursiveView(times: count)
        let tv = createTGRecursiveView(times: count)
        let yv = createYogaRecursiveView(times: count)
        
        let times = 50

        let pi = profileTime(label: "puyo", times: times) {
            _ = pv.sizeThatFits(.zero)
        }
        let ti = profileTime(label: "tk", times: times) {
            _ = tv.sizeThatFits(.zero)
        }

        let yi = profileTime(label: "yoga", times: times) {
            if yv.yoga.flexDirection == .column {
                yv.yoga.flexDirection = .row
            } else {
                yv.yoga.flexDirection = .column
            }
            yv.yoga.applyLayout(preservingOrigin: false, dimensionFlexibility: .flexibleHeight.union(.flexibleWidth))
        }

        print("=======Linear recursive layout profiles======")
        print("p / tg = \(pi / ti)")
        print("p / yoga = \(pi / yi)")
    }

    func testCompareFlowLayout() throws {
        let arrange = 0

        let pv = PuyoFlowLayoutView().attach()
            .arrangeCount(arrange)
            .view
        let tv = TKFlowLayoutView(frame: .zero, orientation: .vert)
        tv.tg_arrangedCount = arrange
        
        let yv = YogaFlowView()

        let times = 50

        let pi = profileTime(label: "puyo", times: times) {
            _ = pv.sizeThatFits(.zero)
        }
        let ti = profileTime(label: "tk", times: times) {
            _ = tv.sizeThatFits(.zero)
        }
        let yi = profileTime(label: "yoga", times: times) {
            if yv.yoga.flexDirection == .column {
                yv.yoga.flexDirection = .row
            } else {
                yv.yoga.flexDirection = .column
            }
            yv.yoga.isDirty
            yv.yoga.applyLayout(preservingOrigin: false, dimensionFlexibility: .flexibleHeight.union(.flexibleHeight))
        }

        print("=======FlowLayout profiles======")
        print("p / tg = \(pi / ti)")
        print("p / yoga = \(pi / yi)")
    }
}
