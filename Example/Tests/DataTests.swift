//
//  DataTests.swift
//  Puyopuyo_Tests
//
//  Created by J on 2022/4/15.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest

class DataTests: XCTestCase {
    override func setUpWithError() throws {
        let v = PuyoLinearLayoutView(count: 1)
        let v1 = YogaLinearView(count: 1)
        let v2 = TKLinearLayoutView(count: 1)
        _ = v.sizeThatFits(.zero)
        _ = v1.sizeThatFits(.zero)
        _ = v2.sizeThatFits(.zero)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetLinearData() throws {
        var puyoTime = [(Int, TimeInterval)]()
        var tgTime = [(Int, TimeInterval)]()
        var yogaTime = [(Int, TimeInterval)]()
        var stackTime = [(Int, TimeInterval)]()

        [3, 5, 10, 50, 80, 100, 120, 150, 180, 200].forEach { count in
            var v: UIView = PuyoLinearLayoutView(count: count)
            puyoTime.append((count, profileTime { _ in
                _ = v.sizeThatFits(.zero)
            }))

            v = YogaLinearView(count: count)
            yogaTime.append((count, profileTime { _ in
                _ = v.sizeThatFits(.zero)
            }))

            v = TKLinearLayoutView(count: count)
            tgTime.append((count, profileTime { _ in
                _ = v.sizeThatFits(.zero)
            }))

            v = CocoaStackView(count: count)
            stackTime.append((count, profileTime { _ in
                _ = v.sizeThatFits(.zero)
            }))
        }

        print("\n>>>>>>> LinearLayout data <<<<<<<\n")
        print(puyoTime.map { c, _ in c }.map(\.description).joined(separator: "\t"))
        print("Puyopuyo\t\(puyoTime.map { $1 }.map(\.description).joined(separator: "\t"))")
        print("Yoga\t\(yogaTime.map { $1 }.map(\.description).joined(separator: "\t"))")
        print("TangramKit\t\(tgTime.map { $1 }.map(\.description).joined(separator: "\t"))")
        print("UIStackView\t\(stackTime.map { $1 }.map(\.description).joined(separator: "\t"))")
        print("\n>>>>>>> LinearLayout data <<<<<<<\n")
    }

    func testRecursiveLinearData() throws {
        var puyoTime = [(Int, TimeInterval)]()
        var tgTime = [(Int, TimeInterval)]()
        var yogaTime = [(Int, TimeInterval)]()

        [2, 4, 6, 8, 10, 12, 14, 16, 18].forEach { count in
            var v: UIView = createPuyopuyoRecursiveView(times: count)
            puyoTime.append((count, profileTime { _ in
                _ = v.sizeThatFits(.zero)
            }))

            v = createYogaRecursiveView(times: count)
            yogaTime.append((count, profileTime { _ in
                v.yoga.calculateLayout(with: CGSize(width: CGFloat.nan, height: CGFloat.nan))
            }))

            v = createTGRecursiveView(times: count)
            tgTime.append((count, profileTime { _ in
                _ = v.sizeThatFits(.zero)
            }))
        }

        print("\n>>>>>>> Recursive data <<<<<<<\n")
        print(puyoTime.map { c, _ in c }.map(\.description).joined(separator: "\t"))
        print("Puyopuyo\t\(puyoTime.map { $1 }.map(\.description).joined(separator: "\t"))")
        print("Yoga\t\(yogaTime.map { $1 }.map(\.description).joined(separator: "\t"))")
        print("TangramKit\t\(tgTime.map { $1 }.map(\.description).joined(separator: "\t"))")
        print("\n>>>>>>> Recursive data <<<<<<<\n")
    }

    func testFlowLayoutData() throws {
        var puyoTime = [(Int, TimeInterval)]()
        var tgTime = [(Int, TimeInterval)]()
        var yogaTime = [(Int, TimeInterval)]()

        let width: CGFloat = 500
        [3, 5, 10, 50, 80, 100, 120, 150, 180, 200].forEach { count in
            var v: UIView = PuyoFlowLayoutView(count: count).attach()
                .direction(.y)
                .view
            puyoTime.append((count, profileTime { _ in
                _ = v.sizeThatFits(CGSize(width: width, height: 0))
            }))

            v = YogaFlowView(count: count).attach().attach {
                $0.yoga.flexDirection = .row
                $0.yoga.flexWrap = .wrap
            }
            .view
            yogaTime.append((count, profileTime { _ in
                v.yoga.calculateLayout(with: CGSize(width: width, height: CGFloat.nan))
            }))

            v = TKFlowLayoutView(count: count).attach().attach {
                $0.tg_orientation = .vert
                $0.tg_arrangedCount = 0
            }
            .view
            tgTime.append((count, profileTime { _ in
                _ = v.sizeThatFits(CGSize(width: width, height: 0))
            }))
        }

        print("\n>>>>>>> FlowLayout data <<<<<<<\n")
        print(puyoTime.map { c, _ in c }.map(\.description).joined(separator: "\t"))
        print("Puyopuyo\t\(puyoTime.map { $1 }.map(\.description).joined(separator: "\t"))")
        print("Yoga\t\(yogaTime.map { $1 }.map(\.description).joined(separator: "\t"))")
        print("TangramKit\t\(tgTime.map { $1 }.map(\.description).joined(separator: "\t"))")
        print("\n>>>>>>> FlowLayout data <<<<<<<\n")
    }
}
