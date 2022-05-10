//
//  ZBoxTests.swift
//  Puyopuyo_Tests
//
//  Created by J on 2022/4/15.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Puyopuyo
import XCTest

class ZTests: XCTestCase {
    var box = ZBox()
    override func setUpWithError() throws {
        box = ZBox()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWrapSize() throws {
        var v1: UIView!
        ZBag().attach(box) {
            v1 = WrapSizeView(100, 200).attach($0)
                .view
        }
        box.layoutIfNeeded()

        XCTAssertTrue(v1.calFrame.size == box.calFrame.size)
    }

    func testFillSize() throws {
        var v1: UIView!
        ZBag().attach(box) {
            v1 = WrapSizeView(100, 200).attach($0)
                .size(.fill, .fill)
                .view
        }
        .size(100, 100)
        box.layoutIfNeeded()

        XCTAssertTrue(v1.calFrame.size == box.calFrame.size)
    }

    func testFillSize2() throws {
        var v1: UIView!
        ZBag().attach(box) {
            v1 = WrapSizeView(100, 200).attach($0)
                .size(.ratio(2), .ratio(2))
                .view
        }
        .size(100, 100)
        box.layoutIfNeeded()

        XCTAssertTrue(v1.calSize.width == box.calSize.width * 2)
        XCTAssertTrue(v1.calSize.height == box.calSize.height * 2)
    }

    func testFixedSize() throws {
        var v1: UIView!
        ZBag().attach(box) {
            v1 = WrapSizeView(100, 200).attach($0)
                .size(50, 50)
                .view
        }

        box.layoutIfNeeded()

        XCTAssertTrue(v1.calSize == CGSize(width: 50, height: 50))
        XCTAssertTrue(v1.calSize == box.calSize)
    }

    func testPadding() throws {
        var v1: UIView!
        ZBag().attach(box) {
            v1 = WrapSizeView(100, 200).attach($0)
                .view
        }
        .padding(all: 10)

        box.layoutIfNeeded()

        XCTAssertTrue(v1.calSize.width == box.calSize.width - 20)
        XCTAssertTrue(v1.calSize.height == box.calSize.height - 20)
    }

    func testMargin() throws {
        var v1: UIView!
        ZBag().attach(box) {
            v1 = WrapSizeView(100, 200).attach($0)
                .margin(all: 10)
                .view
        }

        box.layoutIfNeeded()

        XCTAssertTrue(v1.calSize.width == box.calSize.width - 20)
        XCTAssertTrue(v1.calSize.height == box.calSize.height - 20)
    }

    func testAlignment() throws {
        let alignment = State(Alignment.center)
        var v1: UIView!
        ZBag().attach(box) {
            v1 = WrapSizeView(100, 100).attach($0)
                .alignment(alignment)
                .view
        }
        .size(200, 200)

        box.layoutIfNeeded()
        XCTAssertTrue(v1.celCenter == CGPoint(x: box.fw / 2, y: box.fh / 2))

        alignment.value = [.left, .top]
        box.layoutIfNeeded()
        XCTAssertTrue(v1.fx == 0 && v1.fy == 0)

        alignment.value = [.bottom, .right]
        box.layoutIfNeeded()
        XCTAssertTrue(v1.maxX == box.calSize.width && v1.maxY == box.calSize.height)
    }

    func testJustifyContent() throws {
        let justifyContent = State(Alignment.center)
        var v1: UIView!
        ZBag().attach(box) {
            v1 = WrapSizeView(100, 100).attach($0)
                .view
        }
        .justifyContent(justifyContent)
        .size(200, 200)

        box.layoutIfNeeded()
        XCTAssertTrue(v1.celCenter == CGPoint(x: box.fw / 2, y: box.fh / 2))

        justifyContent.value = [.left, .top]
        box.layoutIfNeeded()
        XCTAssertTrue(v1.fx == 0 && v1.fy == 0)

        justifyContent.value = [.bottom, .right]
        box.layoutIfNeeded()
        XCTAssertTrue(v1.maxX == box.calSize.width && v1.maxY == box.calSize.height)
    }
}
