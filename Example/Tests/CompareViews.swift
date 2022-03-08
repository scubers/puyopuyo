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

class PuyoLinearLayoutView: LinearBox {
    override func buildBody() {
        attach {
            for view in createViews() {
                view.attach($0)
            }
        }
        .direction(.x)
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
