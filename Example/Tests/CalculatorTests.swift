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
        size = CGSize(width: 100, height: 100).collapse(to: 2 / 1)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 50)
        
        size = CGSize(width: 100, height: 100).expand(to: 2 / 1)
        XCTAssertTrue(size.width == 200)
        XCTAssertTrue(size.height == 100)
        
        // 正方形 -> 高
        size = CGSize(width: 100, height: 100).collapse(to:  1 / 2)
        XCTAssertTrue(size.width == 50)
        XCTAssertTrue(size.height == 100)
        
        size = CGSize(width: 100, height: 100).expand(to: 1 / 2)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 200)
        
        // 扁 -> 更扁
        size = CGSize(width: 400, height: 200).collapse(to: 4 / 1)
        XCTAssertTrue(size.width == 400)
        XCTAssertTrue(size.height == 100)
        
        size = CGSize(width: 400, height: 200).expand(to: 4 / 1)
        XCTAssertTrue(size.width == 800)
        XCTAssertTrue(size.height == 200)
        
        // 扁 -> 没那么扁
        size = CGSize(width: 400, height: 100).collapse(to: 3 / 2)
        XCTAssertTrue(size.width == 150)
        XCTAssertTrue(size.height == 100)
        
        size = CGSize(width: 400, height: 100).expand(to: 2 / 1)
        XCTAssertTrue(size.width == 400)
        XCTAssertTrue(size.height == 200)
        
        // 扁 -> 长
        size = CGSize(width: 400, height: 100).collapse(to: 1 / 4)
        XCTAssertTrue(size.width == 25)
        XCTAssertTrue(size.height == 100)
        
        size = CGSize(width: 400, height: 100).expand(to: 1 / 4)
        XCTAssertTrue(size.width == 400)
        XCTAssertTrue(size.height == 1600)
        
        // 长 -> 更长
        size = CGSize(width: 200, height: 400).collapse(to: 1 / 4)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 400)
        
        size = CGSize(width: 200, height: 400).expand(to: 1 / 4)
        XCTAssertTrue(size.width == 200)
        XCTAssertTrue(size.height == 800)
        
        // 长 -> 没那么长
        size = CGSize(width: 100, height: 400).collapse(to: 2 / 3)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 150)
        
        size = CGSize(width: 100, height: 400).expand(to: 1 / 2)
        XCTAssertTrue(size.width == 200)
        XCTAssertTrue(size.height == 400)
        
        // 长 -> 扁
        size = CGSize(width: 100, height: 400).collapse(to: 4 / 1)
        XCTAssertTrue(size.width == 100)
        XCTAssertTrue(size.height == 25)
        
        size = CGSize(width: 100, height: 400).expand(to: 4 / 1)
        XCTAssertTrue(size.width == 1600)
        XCTAssertTrue(size.height == 400)
        
        // inf
        size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude).collapse(to: 1 / 2)
        XCTAssertTrue(size.width / size.height == 1 / 2)
        
        // for zero collapse
        size = CGSize(width: 0, height: 0).collapse(to: 2 / 1)
        XCTAssertTrue(size == .zero)
        
        size = CGSize(width: 100, height: 0).collapse(to: 2 / 1)
        XCTAssertTrue(size == .zero)
        
        size = CGSize(width: 0, height: 100).collapse(to: 2 / 1)
        XCTAssertTrue(size == .zero)
        
        // for zero expand
        
        size = CGSize(width: 0, height: 0).expand(to: 2 / 1)
        XCTAssertTrue(size == .zero)
        
        size = CGSize(width: 100, height: 0).expand(to: 2 / 1)
        XCTAssertTrue(size == CGSize(width: 100, height: 50))
        
        size = CGSize(width: 0, height: 100).expand(to: 2 / 1)
        XCTAssertTrue(size == CGSize(width: 200, height: 100))
        
        
        
    }
}
