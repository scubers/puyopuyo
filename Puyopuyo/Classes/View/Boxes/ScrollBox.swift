//
//  ScrollBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/15.
//

import UIKit

@available(*, deprecated, message: "use ScrollingBox")
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

public class ScrollingBox<Flat: Boxable & UIView>: UIScrollView, Delegatable, Stateful where Flat.RegulatorType: FlatRegulator {
    
    public enum ScrollDirection {
        case x, y, both
    }
    
    public struct ViewState {
        public var direction: ScrollDirection = .y
    }
    
    public var viewState = State(ViewState())
    
    public typealias DelegateType = UIScrollViewDelegate

    public var scrollDelegate: RetainWrapper<UIScrollViewDelegate>? {
        didSet {
            delegate = scrollDelegate?.value
        }
    }

    public func setDelegate(_ delegate: UIScrollViewDelegate, retained: Bool) {
        scrollDelegate = RetainWrapper(value: delegate, retained: retained)
    }

    public private(set) var flat: Flat

    public init(flat: @escaping BoxGenerator<Flat> = { Flat() },
                direction: ScrollDirection = .y,
                builder: @escaping BoxBuilder<Flat>) {
        self.flat = flat()
        super.init(frame: .zero)

        attach {
            self.flat.attach($0) {
                guard let v = $0 as? Flat else { return }
                builder(v)
            }
            .autoJudgeScroll(true)
        }
        // 绑定方向
        _ = viewState.safeBind(to: self) { $0.setDirection($1.direction) }
        
        viewState.value.direction = direction
    }

    func setDirection(_ d: ScrollDirection) {
        switch d {
        case .x:
            flat.attach().size(.wrap, .fill)
        case .y:
            flat.attach().size(.fill, .wrap)
        case .both:
            flat.attach().size(.wrap, .wrap)
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
