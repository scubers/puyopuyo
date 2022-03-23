//
//  CalculatorTests.swift
//  Puyopuyo_Tests
//
//  Created by J on 2022/3/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import Puyopuyo

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
        size = Calculator.getAspectRatioSize(CGSize(width: 100, height: 100), aspectRatio: 2 / 1, transform: .collapse)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 50)
        
        size = Calculator.getAspectRatioSize(CGSize(width: 100, height: 100), aspectRatio: 2 / 1, transform: .expand)
        XCTAssertTrue(size.width == 200)
        XCTAssertTrue(size.height == 100)
        
        // 正方形 -> 高
        size = Calculator.getAspectRatioSize(CGSize(width: 100, height: 100), aspectRatio: 1 / 2, transform: .collapse)
        XCTAssertTrue(size.width == 50)
        XCTAssertTrue(size.height == 100)
        
        size = Calculator.getAspectRatioSize(CGSize(width: 100, height: 100), aspectRatio: 1 / 2, transform: .expand)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 200)
        
        // 扁 -> 更扁
        size = Calculator.getAspectRatioSize(CGSize(width: 400, height: 200), aspectRatio: 4 / 1, transform: .collapse)
        XCTAssertTrue(size.width == 400)
        XCTAssertTrue(size.height == 100)
        
        size = Calculator.getAspectRatioSize(CGSize(width: 400, height: 200), aspectRatio: 4 / 1, transform: .expand)
        XCTAssertTrue(size.width == 800)
        XCTAssertTrue(size.height == 200)
        
        // 扁 -> 没那么扁
        size = Calculator.getAspectRatioSize(CGSize(width: 400, height: 100), aspectRatio: 3 / 2, transform: .collapse)
        XCTAssertTrue(size.width == 150)
        XCTAssertTrue(size.height == 100)
        
        size = Calculator.getAspectRatioSize(CGSize(width: 400, height: 100), aspectRatio: 2 / 1, transform: .expand)
        XCTAssertTrue(size.width == 400)
        XCTAssertTrue(size.height == 200)
        
        // 扁 -> 长
        size = Calculator.getAspectRatioSize(CGSize(width: 400, height: 100), aspectRatio: 1 / 4, transform: .collapse)
        XCTAssertTrue(size.width == 25)
        XCTAssertTrue(size.height == 100)
        
        size = Calculator.getAspectRatioSize(CGSize(width: 400, height: 100), aspectRatio: 1 / 4, transform: .expand)
        XCTAssertTrue(size.width == 400)
        XCTAssertTrue(size.height == 1600)
        
        // 长 -> 更长
        size = Calculator.getAspectRatioSize(CGSize(width: 200, height: 400), aspectRatio: 1 / 4, transform: .collapse)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 400)
        
        size = Calculator.getAspectRatioSize(CGSize(width: 200, height: 400), aspectRatio: 1 / 4, transform: .expand)
        XCTAssertTrue(size.width == 200)
        XCTAssertTrue(size.height == 800)
        
        // 长 -> 没那么长
        size = Calculator.getAspectRatioSize(CGSize(width: 100, height: 400), aspectRatio: 2 / 3, transform: .collapse)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 150)
        
        size = Calculator.getAspectRatioSize(CGSize(width: 100, height: 400), aspectRatio: 1 / 2, transform: .expand)
        XCTAssertTrue(size.width == 200)
        XCTAssertTrue(size.height == 400)
        
        // 长 -> 扁
        size = Calculator.getAspectRatioSize(CGSize(width: 100, height: 400), aspectRatio: 4 / 1, transform: .collapse)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 25)
        
        size = Calculator.getAspectRatioSize(CGSize(width: 100, height: 400), aspectRatio: 4 / 1, transform: .expand)
        XCTAssertTrue(size.width == 1600)
        XCTAssertTrue(size.height == 400)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
