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
        _ = PuyoFlowLayoutView().sizeThatFits(.zero)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCompareLinearLayout() throws {
        let pv = PuyoLinearLayoutView()
        let tv = TKLinearLayoutView()
        let sv = CocoaStackView()
        let yv = YogaLinearView()

        let times = 1

        let pi = profileTime(label: "puyo", times: times) { _ in
            _ = pv.sizeThatFits(.zero)
        }
        let ti = profileTime(label: "tk", times: times) { _ in
            _ = tv.sizeThatFits(.zero)
        }
        let si = profileTime(label: "stackview", times: times) { _ in
            _ = sv.sizeThatFits(.zero)
        }

        let yi = profileTime(label: "yoga", times: times) { _ in
            if yv.yoga.flexDirection == .row {
                yv.yoga.flexDirection = .rowReverse
            } else {
                yv.yoga.flexDirection = .row
            }
            yv.yoga.calculateLayout(with: CGSize(width: CGFloat.nan, height: .nan))
        }

        print("=======LinearLayout profiles======")
        print("p / tg = \(pi / ti)")
        print("p / stackview = \(pi / si)")
        print("p / yoga = \(pi / yi)")
    }

    func testLinearRecusiveLayout() throws {
        let count = 50
        let times = 1

        let pv = createPuyopuyoRecursiveView(times: count)
        let tv = createTGRecursiveView(times: count)
        let yv = createYogaRecursiveView(times: count)

        let pi = profileTime(label: "puyo", times: times) { _ in
            _ = pv.sizeThatFits(.zero)
        }
        let ti = profileTime(label: "tk", times: times) { _ in
            _ = tv.sizeThatFits(.zero)
        }

        let yi = profileTime(label: "yoga", times: times) { _ in
            yv.yoga.calculateLayout(with: CGSize(width: CGFloat.nan, height: .nan))
        }

        print("=======Linear recursive layout profiles======")
        print("p / tg = \(pi / ti)")
        print("p / yoga = \(pi / yi)")
    }

    func testCompareFlowLayout() throws {
        let count = 50
        let arrange = 0
        let times = 1
        let width: CGFloat = 500

        let pv = PuyoFlowLayoutView(count: count).attach()
            .arrangeCount(arrange)
            .direction(.y)
            .view
        let tv = TKFlowLayoutView(count: count).attach().attach {
            $0.tg_arrangedCount = 0
            $0.tg_orientation = .vert
        }
        .view

        let yv = YogaFlowView(count: count).attach().attach {
            $0.yoga.flexDirection = .row
            $0.yoga.flexWrap = .wrap
        }
        .view

        let pi = profileTime(label: "puyo", times: times) { _ in
            _ = pv.sizeThatFits(CGSize(width: 0, height: 0))
        }
        let ti = profileTime(label: "tk", times: times) { _ in
            _ = tv.sizeThatFits(CGSize(width: 0, height: 0))
        }
        let yi = profileTime(label: "yoga", times: times) { i in
            if yv.yoga.flexDirection == .row {
                yv.yoga.flexDirection = .rowReverse
            } else {
                yv.yoga.flexDirection = .row
            }
            yv.yoga.calculateLayout(with: CGSize(width: width + CGFloat(i), height: .nan))
        }

        print("=======FlowLayout profiles======")
        print("p / tg = \(pi / ti)")
        print("p / yoga = \(pi / yi)")
    }
}
