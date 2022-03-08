//
//  CompareTests.swift
//  Puyopuyo_Tests
//
//  Created by J on 2022/3/2.
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

    func testCompareLinearBox() throws {
        let pv = PuyoTestHBox()
        let tv = TKTestLinearLayout()
        let total = 200
        let pi = measureTimes("puyo") {
            for _ in 0 ..< total {
                _ = pv.sizeThatFits(.zero)
            }
        }

        let ti = measureTimes("tk") {
            for _ in 0 ..< total {
                _ = tv.sizeThatFits(.zero)
            }
        }

        print("puyo / tangramkit = \(pi / ti)")
    }

    func testCompareFlowBox() throws {
        let pv = PuyoTestFlowBox()
        let tv = TKTestFlow()
        let total = 1
        let pi = measureTimes("puyo") {
            for _ in 0 ..< total {
                _ = pv.sizeThatFits(.zero)
            }
        }

        let ti = measureTimes("tk") {
            for _ in 0 ..< total {
                _ = tv.sizeThatFits(.zero)
            }
        }

        print("puyo / tangramkit = \(pi / ti)")
    }

    private func measureTimes(_ label: String?, _ block: () -> Void) -> TimeInterval {
        let start = Date().timeIntervalSince1970
        block()
        let interval = Date().timeIntervalSince1970 - start
        print("\(label == nil ? "" : "\(label!) ")总耗时: \(interval) s")
        return interval
    }
}

private func createViews() -> [UIView] {
    var list = [UIView]()
    for idx in 0 ..< 100 {
        let label = UILabel().attach().text("test label: \(idx)").view
        list.append(label)
    }
    return list
}

class PuyoTestHBox: HBox {
    override func buildBody() {
        attach {
            for v in createViews() {
                v.attach($0)
            }
        }
    }
}

class TKTestLinearLayout: TGLinearLayout {
    init() {
        super.init(frame: .zero, orientation: .horz)

        createViews().forEach { v in
            addSubview(v)
            v.tg_size(width: .wrap, height: .wrap)
        }

        tg_size(width: .wrap, height: .wrap)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PuyoTestFlowBox: VFlow {
    override func buildBody() {
        attach {
            for v in createViews() {
                v.attach($0)
            }
        }
        .width(300)
        .arrangeCount(0)
    }
}

class TKTestFlow: TGFlowLayout {
    init() {
        super.init(frame: .zero, orientation: .vert, arrangedCount: 0)
        for v in createViews() {
            addSubview(v)
        }
        tg_size(width: 300, height: .wrap)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
