//
//  ComplexSceenTests.swift
//  Puyopuyo_Tests
//
//  Created by J on 2022/5/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Puyopuyo
import XCTest

class ComplexSceenTests: XCTestCase {
    var box = ZBox()
    override func setUpWithError() throws {
        box = ZBox()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCase1() throws {
        var v1: UIView!
        var v2: UIView!
        let v = ZBox().attach {
            v1 = ZBox().attach($0) {
                v2 = UIView().attach($0)
                    .size(.fill, .fill)
                    .view
            }
            .size(.fill, .aspectRatio(1))
            .view
        }
        .size(100, 100)

        v.view.layoutIfNeeded()

        XCTAssertTrue(v1.calSize == v2.calSize)
    }

    func testCase2() throws {
        var v1: UIView!
        var v2: UIView!
        v1 = ZBox().attach(box) {
            v2 = UIView().attach($0)
                .size(.fill, .aspectRatio(1))
                .view
            UILabel().attach($0)
                .text("abcabc")
        }
        .view

        box.layoutIfNeeded()

        XCTAssertTrue(v1.calSize == v2.calSize)
    }
}
