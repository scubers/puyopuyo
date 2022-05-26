//
//  Puyo+UIScrollView.swift
//  Puyopuyo
//
//  Created by Junren Wong on 2019/8/2.
//

import Foundation

@available(*, deprecated)
public extension Puyo where T: UIScrollView {
    @discardableResult
    func flatBox(_ direction: Direction) -> Puyo<LinearBox> {
        if direction == .y {
            view.attach().bind(\T.alwaysBounceVertical, true)
            return
                LinearBox().attach(view)
                    .direction(direction)
                    .autoJudgeScroll(true)
                    .size(.fill, .wrap)
        } else {
            view.attach().bind(\T.alwaysBounceHorizontal, true)
            return
                LinearBox().attach(view)
                    .direction(direction)
                    .autoJudgeScroll(true)
                    .size(.wrap, .fill)
        }
    }
}
