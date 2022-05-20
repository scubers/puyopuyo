//
//  CompareViews.swift
//  Puyopuyo_Tests
//
//  Created by J on 2022/3/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo
import TangramKit
import YogaKit

class WrapSizeView: UIView {
    var contentSize: CGSize = .zero
    init(_ width: CGFloat = 0, _ height: CGFloat = 0) {
        contentSize = .init(width: width, height: height)
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return contentSize
    }
}

protocol CountedTestView {
    var count: Int { get }
    init(count: Int)
}

func profileTime(label: String? = nil, times: Int = 1, _ block: (Int) -> Void) -> TimeInterval {
    let start = Date().timeIntervalSince1970
    for i in 0 ..< times {
        block(i)
    }
    let time = TimeInterval(Int((Date().timeIntervalSince1970 - start) * 1000 * 10000)) / 10000
    print("Profile \(label ?? "") times: \(times): cost: \(time) ms, \(time / Double(times)) ms/time")
    return time
}

func createViews(count: Int = 1000) -> [UIView] {
    (0 ..< count).map { UILabel().attach().text("\($0) test label").view }
}

class CocoaStackView: UIStackView, CountedTestView {
    let count: Int
    required init(count: Int = 50) {
        self.count = count
        super.init(frame: .zero)
        createViews(count: count).forEach { v in
            addArrangedSubview(v)
        }
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return systemLayoutSizeFitting(size)
    }
}

class YogaLinearView: UIView {
    let count: Int
    init(count: Int = 50) {
        self.count = count
        super.init(frame: .zero)
        yoga.flexDirection = .row
        yoga.isEnabled = true
        createViews(count: count).forEach { v in
            addSubview(v)
            v.yoga.isEnabled = true
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var s = size
        if s.width == 0 { s.width = .nan }
        if s.height == 0 { s.height = .nan }
        return yoga.calculateLayout(with: s)
    }
}

class PuyoLinearLayoutView: LinearBox {
    let count: Int
    init(count: Int = 50) {
        self.count = count
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder argument: NSCoder) {
        fatalError()
    }

    override func buildBody() {
        attach {
            for view in createViews(count: count) {
                view.attach($0)
            }
        }
        .direction(.x)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return super.sizeThatFits(size)
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return super.systemLayoutSizeFitting(targetSize)
    }
}

class TKLinearLayoutView: TGLinearLayout, CountedTestView {
    let count: Int
    required init(count: Int = 50) {
        self.count = count
        super.init(frame: .zero, orientation: .horz)
        createViews(count: count).forEach { view in
            addSubview(view)
            view.tg_size(width: .wrap, height: .wrap)
        }
        tg_size(width: .wrap, height: .wrap)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class PuyoFlowLayoutView: FlowBox, CountedTestView {
    let count: Int
    required init(count: Int = 50) {
        self.count = count
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder argument: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func buildBody() {
        attach {
            for v in createViews(count: count) {
                v.attach($0)
                    .size(.wrap, .wrap)
            }
        }
        .size(500, .wrap)
        .direction(.y)
        .arrangeCount(0)
    }
}

class TKFlowLayoutView: TGFlowLayout {
    let count: Int
    required init(count: Int = 50) {
        self.count = count
        super.init(frame: .zero, orientation: .vert, arrangedCount: 0)
        createViews(count: count).forEach { v in
            addSubview(v)
            v.tg_size(width: .wrap, height: .wrap)
        }
        tg_size(width: 500, height: .wrap)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class YogaFlowView: UIView, CountedTestView {
    let count: Int
    required init(count: Int = 50) {
        self.count = count
        super.init(frame: .zero)
        yoga.isEnabled = true
        yoga.flexWrap = .wrap
        yoga.width = 500
        yoga.flexDirection = .row
        createViews(count: count).forEach { v in
            addSubview(v)
            v.yoga.isEnabled = true
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

func createPuyopuyoRecursiveView(times: Int = 3) -> UIView {
    func generate(view: UIView, times: Int) -> UIView {
        if times == 0 { return view }

        view.attach {
            for _ in 0 ..< 5 {
                UILabel().attach($0).text("Label")
            }

            generate(view: HBox(), times: times - 1).attach($0)
        }
        return view
    }

    return generate(view: HBox(), times: times)
}

func createTGRecursiveView(times: Int = 3) -> UIView {
    func generate(view: TGLinearLayout, times: Int) -> UIView {
        if times == 0 { return view }

        view.attach {
            $0.tg_size(width: .wrap, height: .wrap)
            for _ in 0 ..< 5 {
                UILabel().attach($0) {
                    $0.tg_size(width: .wrap, height: .wrap)
                }
                .text("Label")
            }

            generate(view: TGLinearLayout(frame: .zero, orientation: .horz), times: times - 1).attach($0)
        }
        return view
    }

    return generate(view: TGLinearLayout(frame: .zero, orientation: .horz), times: times)
}

func createYogaRecursiveView(times: Int = 3) -> UIView {
    func generate(view: UIView, times: Int) -> UIView {
        view.yoga.isEnabled = true
        if times == 0 { return view }

        view.attach {
            $0.configureLayout { l in
                l.isEnabled = true
                l.flexDirection = .row
            }
            for _ in 0 ..< 5 {
                UILabel().attach($0).text("Label")
                    .set(\.yoga.isEnabled, true)
            }

            generate(view: UIView(), times: times - 1).attach($0)
        }
        return view
    }

    return generate(view: UIView(), times: times)
}

func createPuyopuyoCompress(times: Int = 10) -> UIView {
    let width: CGFloat = 100
    let count = CGFloat(times)
    return HBox().attach {
        for _ in 0 ..< Int(count) {
            WrapSizeView(width, width).attach($0)
                .width(.wrap(shrink: 1))
        }
    }
    .width(count * (width - 10)) // 每个view需要压缩10
    .justifyContent(.center)
    .view
}

func createYogaCompress(times: Int = 10) -> UIView {
    let width: CGFloat = 100
    let count = CGFloat(times)
    return UIView().attach {
        $0.yoga.isEnabled = true
        $0.yoga.width = YGValue(count * (width - 10))
        $0.yoga.flexDirection = .row
        $0.yoga.alignItems = .center
        
        for _ in 0 ..< Int(count) {
            WrapSizeView(width, width).attach($0) {
                $0.yoga.isEnabled = true
                $0.yoga.flexShrink = 1
                $0.yoga.height = YGValue(width)
                $0.yoga.width = YGValue(width)
                
            }
        }
    }
    .view
}
