//
//  Puyo+UIScrollView.swift
//  Puyopuyo
//
//  Created by Junren Wong on 2019/8/2.
//

import Foundation

public extension Puyo where T: UIScrollView {
    @discardableResult
    func bounces<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.bounces = a
        }
        return self
    }

    @discardableResult
    func alwaysVertBounds<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.alwaysBounceVertical = a
        }
        return self
    }

    @discardableResult
    func alwaysHorzBounds<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.alwaysBounceHorizontal = a
        }
        return self
    }
    
    @discardableResult
    func scrollEnabled<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.isScrollEnabled = a
        }
        return self
    }
    
    @discardableResult
    func showHorzIndicator<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.showsHorizontalScrollIndicator = a
        }
        return self
    }
    
    @discardableResult
    func showVertIndicator<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.showsVerticalScrollIndicator = a
        }
        return self
    }

    @discardableResult
    func flatBox(_ direction: Direction) -> Puyo<FlatBox> {
        if direction == .y {
            view.attach().alwaysVertBounds(true)
            return
                FlatBox().attach(view)
                .direction(direction)
                .autoJudgeScroll(true)
                .size(.fill, .wrap)
        } else {
            view.attach().alwaysHorzBounds(true)
            return
                FlatBox().attach(view)
                .direction(direction)
                .autoJudgeScroll(true)
                .size(.wrap, .fill)
        }
    }
}
