//
//  ScrollBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/15.
//

import UIKit

public class ScrollBox: ZBox {
    public private(set) var scrollView = UIScrollView()

    public var delegate: RetainWrapper<UIScrollViewDelegate>? {
        didSet {
            scrollView.delegate = delegate?.value
        }
    }
    
    public init(flat: BoxGenerator<FlatBox>? = nil,
                flow: BoxGenerator<FlowBox>? = nil,
                direction: Direction = .y,
                builder: @escaping BoxBuilder<UIView>) {
        super.init(frame: .zero)

        assert(flat != nil || flow != nil, "")
        
        
        scrollView.attach(self) {
            flat?().attach($0) {
                builder($0)
            }
            .size(direction == .y ? .fill : .wrap, direction == .y ? .wrap : .fill)
            .autoJudgeScroll(true)

            flow?().attach($0) {
                builder($0)
            }
            .size(direction == .y ? .fill : .wrap, direction == .y ? .wrap : .fill)
            .autoJudgeScroll(true)
        }
        .size(.fill, .fill)
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }
}

// MARK: - ScrollBox

extension Puyo where T: ScrollBox {
    @discardableResult
    public func scrollDelegate(_ delegate: UIScrollViewDelegate, retained: Bool = false) -> Self {
        view.delegate = RetainWrapper(value: delegate, retained: retained)
        return self
    }
}
