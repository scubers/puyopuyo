//
//  CalculatorTests.swift
//  Puyopuyo_Tests
//
//  Created by J on 2022/3/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

@testable import Puyopuyo
import XCTest

class CalculatorTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCalAspectRatioSize() throws {
        var size: CGSize
        // 正方形 -> 扁
        size = _CalculateUtil.fit(CGSize(width: 100, height: 100), aspectRatio: 2 / 1, strategy: .collapse)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 50)
        
        size = _CalculateUtil.fit(CGSize(width: 100, height: 100), aspectRatio: 2 / 1, strategy: .expand)
        XCTAssertTrue(size.width == 200)
        XCTAssertTrue(size.height == 100)
        
        // 正方形 -> 高
        size = _CalculateUtil.fit(CGSize(width: 100, height: 100), aspectRatio: 1 / 2, strategy: .collapse)
        XCTAssertTrue(size.width == 50)
        XCTAssertTrue(size.height == 100)
        
        size = _CalculateUtil.fit(CGSize(width: 100, height: 100), aspectRatio: 1 / 2, strategy: .expand)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 200)
        
        // 扁 -> 更扁
        size = _CalculateUtil.fit(CGSize(width: 400, height: 200), aspectRatio: 4 / 1, strategy: .collapse)
        XCTAssertTrue(size.width == 400)
        XCTAssertTrue(size.height == 100)
        
        size = _CalculateUtil.fit(CGSize(width: 400, height: 200), aspectRatio: 4 / 1, strategy: .expand)
        XCTAssertTrue(size.width == 800)
        XCTAssertTrue(size.height == 200)
        
        // 扁 -> 没那么扁
        size = _CalculateUtil.fit(CGSize(width: 400, height: 100), aspectRatio: 3 / 2, strategy: .collapse)
        XCTAssertTrue(size.width == 150)
        XCTAssertTrue(size.height == 100)
        
        size = _CalculateUtil.fit(CGSize(width: 400, height: 100), aspectRatio: 2 / 1, strategy: .expand)
        XCTAssertTrue(size.width == 400)
        XCTAssertTrue(size.height == 200)
        
        // 扁 -> 长
        size = _CalculateUtil.fit(CGSize(width: 400, height: 100), aspectRatio: 1 / 4, strategy: .collapse)
        XCTAssertTrue(size.width == 25)
        XCTAssertTrue(size.height == 100)
        
        size = _CalculateUtil.fit(CGSize(width: 400, height: 100), aspectRatio: 1 / 4, strategy: .expand)
        XCTAssertTrue(size.width == 400)
        XCTAssertTrue(size.height == 1600)
        
        // 长 -> 更长
        size = _CalculateUtil.fit(CGSize(width: 200, height: 400), aspectRatio: 1 / 4, strategy: .collapse)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 400)
        
        size = _CalculateUtil.fit(CGSize(width: 200, height: 400), aspectRatio: 1 / 4, strategy: .expand)
        XCTAssertTrue(size.width == 200)
        XCTAssertTrue(size.height == 800)
        
        // 长 -> 没那么长
        size = _CalculateUtil.fit(CGSize(width: 100, height: 400), aspectRatio: 2 / 3, strategy: .collapse)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 150)
        
        size = _CalculateUtil.fit(CGSize(width: 100, height: 400), aspectRatio: 1 / 2, strategy: .expand)
        XCTAssertTrue(size.width == 200)
        XCTAssertTrue(size.height == 400)
        
        // 长 -> 扁
        size = _CalculateUtil.fit(CGSize(width: 100, height: 400), aspectRatio: 4 / 1, strategy: .collapse)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 25)
        
        size = _CalculateUtil.fit(CGSize(width: 100, height: 400), aspectRatio: 4 / 1, strategy: .expand)
        XCTAssertTrue(size.width == 1600)
        XCTAssertTrue(size.height == 400)
        
        // inf
        size = _CalculateUtil.fit(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), aspectRatio: 1 / 2, strategy: .collapse)
        XCTAssertTrue(size.width / size.height == 1 / 2)
    }
}
