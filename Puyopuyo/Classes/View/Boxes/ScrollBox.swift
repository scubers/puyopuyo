//
//  ScrollBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/15.
//

import UIKit

public class ScrollBox<T: Boxable & UIView>: ZBox, Delegatable where T.RegulatorType: FlatRegulator {
    public typealias DelegateType = UIScrollViewDelegate

    public private(set) var scrollView: UIScrollView!

    public var delegate: RetainWrapper<UIScrollViewDelegate>? {
        didSet {
            scrollView.delegate = delegate?.value
        }
    }

    public func setDelegate(_ delegate: UIScrollViewDelegate, retained: Bool) {
        self.delegate = RetainWrapper(value: delegate, retained: retained)
    }

    public init(scrollView: BoxGenerator<UIScrollView> = { UIScrollView() },
                flat: @escaping BoxGenerator<T> = { return T() },
                direction: Direction = .y,
                builder: @escaping BoxBuilder<UIView>) {
        super.init(frame: .zero)
        self.scrollView = scrollView()
        self.scrollView.attach(self) {
            flat().attach($0) {
                builder($0)
            }
            .width(direction == .y ? .fill : .wrap)
            .height(direction == .y ? .wrap : .fill)
            .autoJudgeScroll(true)
        }
        .size(.fill, .fill)
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
