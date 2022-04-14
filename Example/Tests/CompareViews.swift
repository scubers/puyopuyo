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

func profileTime(label: String? = nil, times: Int = 1, _ block: () -> Void) -> TimeInterval {
    let start = Date().timeIntervalSince1970
    for _ in 0 ..< times {
        block()
    }
    let time = Date().timeIntervalSince1970 - start
    print("Profile \(label ?? "") times: \(times): cost: \(time)s, \(time / Double(times)) s/time")
    return time
}

func createViews(count: Int = 1000) -> [UIView] {
    (0 ..< count).map { UILabel().attach().text("\($0) test label").view }
}

class CocoaStackView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: .zero)

        createViews().forEach { v in
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
    override init(frame: CGRect) {
        super.init(frame: .zero)

        yoga.flexDirection = .row
        yoga.isEnabled = true
        createViews().forEach { v in
            addSubview(v)
            v.yoga.isEnabled = true
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

class PuyoLinearLayoutView: LinearBox {
    override func buildBody() {
        attach {
            for view in createViews() {
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

class TKLinearLayoutView: TGLinearLayout {
    override init(frame: CGRect, orientation: TGOrientation) {
        super.init(frame: frame, orientation: orientation)
        createViews().forEach { view in
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

class PuyoFlowLayoutView: FlowBox {
    override func buildBody() {
        attach {
            for v in createViews() {
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
    override init(frame: CGRect, orientation: TGOrientation = TGOrientation.vert, arrangedCount: Int = 0) {
        super.init(frame: frame, orientation: orientation, arrangedCount: arrangedCount)
        createViews().forEach { v in
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

class YogaFlowView: UIView {
    override init(frame: CGRect) {
        super.init(frame: .zero)

        yoga.isEnabled = true
        yoga.flexWrap = .wrap
        yoga.width = 500
        yoga.flexDirection = .row
        createViews().forEach { v in
            addSubview(v)
            v.yoga.isEnabled = true
        }
        
//        yoga.applyLayout(preservingOrigin: false, dimensionFlexibility: .flexibleHeight)
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
            for _ in 0 ..< times {
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
            for _ in 0 ..< times {
                UILabel().attach($0).text("Label").attach { $0.tg_size(width: .wrap, height: .wrap) }
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
            for _ in 0 ..< times {
                UILabel().attach($0).text("Label")
                    .set(\.yoga.isEnabled, true)
            }

            generate(view: UIView(), times: times - 1).attach($0)
        }
        return view
    }

    return generate(view: UIView(), times: times)
}
