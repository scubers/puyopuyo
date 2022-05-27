//
//  GroupTests.swift
//  Puyopuyo_Tests
//
//  Created by J on 2022/5/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Puyopuyo
import XCTest

class BoxLayoutNodeTests: XCTestCase {
    var box = ZBox()
    
    override func setUpWithError() throws {
        box = ZBox()
    }

    override func tearDownWithError() throws {}
    
    func testActivated() throws {
        var v: UIView!
        let group = HGroup().attach(box) {
            v = UIView().attach($0)
                .size(50, 50)
                .view
        }
        .activated(false)
        .view
        
        box.layoutIfNeeded()
        
        XCTAssert(group.regulator.calculatedCenter == .zero)
        XCTAssert(group.regulator.calculatedSize == .zero)
        XCTAssert(v.layoutMeasure.calculatedCenter == .zero)
        XCTAssert(v.layoutMeasure.calculatedSize == .zero)
        
        group.regulator.activated = true
        
        box.layoutIfNeeded()
        
        XCTAssert(group.regulator.calculatedSize == CGSize(width: 50, height: 50))
        XCTAssert(v.layoutMeasure.calculatedSize == CGSize(width: 50, height: 50))
    }
    
    func testParasite() throws {
        var v: UIView!
        let group = HGroup().attach(box) {
            v = UIView().attach($0)
                .size(50, 50)
                .view
        }
        .view
        
        XCTAssert(v.superview == box)
        
        group.layoutVisibility = .gone
        XCTAssert(v.superview == nil)
        
        group.layoutVisibility = .free
        XCTAssert(v.superview == box)
        
        group.layoutVisibility = .gone
        XCTAssert(v.superview == nil)
    }
    
    func testSuperBox() throws {
        var v: UIView!
        let group = HGroup().attach(box) {
            v = UIView().attach($0)
                .size(50, 50)
                .view
        }
        .view
        
        XCTAssert(v.superBox === group)
        XCTAssert(group.superBox === box)
    }
    
    func testRemoveFromSuperBox() throws {
        var v: UIView!
        var v1: UIView!
        let g = HGroup().attach(box) {
            v = UIView().attach($0)
                .size(50, 50)
                .view
            
            v1 = UIView().attach($0)
                .size(50, 50)
                .view
        }
        .activated(false)
        
        v.removeFromSuperBox()
        
        XCTAssert(v.superview == nil)
        XCTAssert(v.superBox == nil)
        XCTAssert(g.layoutChildren.count == 1)
        
        v1.removeFromSuperview()
        
        XCTAssert(v1.superview == nil)
        XCTAssert(v1.superBox == nil)
        XCTAssert(g.layoutChildren.count == 0)
    }
    
    func testParasitizingHostForChildren() throws {
        var v: UIView!
        let group = HGroup().attach(box) {
            v = UIView().attach($0)
                .size(50, 50)
                .view
        }
        .view
        
        XCTAssert(group.superBox === box)
        
        v.removeFromSuperBox()
        
        XCTAssert(v.superBox == nil)
    }
    
    func testLayoutChildren() throws {
        var v: UIView!
        let group = HGroup().attach(box) {
            v = UIView().attach($0)
                .size(50, 50)
                .view
        }
        .activated(false)
        .view
        
        XCTAssert(group.layoutChildren.count == 1)
        XCTAssert(group.layoutChildren.first! === v)
    }
}
