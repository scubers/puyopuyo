//
//  ScrollBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/15.
//

import UIKit

@available(*, deprecated, message: "use ScrollingBox")
public class ScrollBox<T: Boxable & UIView>: ZBox, Delegatable where T.RegulatorType: LinearRegulator {
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
                flat: @escaping BoxGenerator<T> = { T() },
                direction: Direction = .y,
                builder: @escaping BoxBuilder<UIView>)
    {
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

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }
}

public enum ScrollDirection {
    case x, y, both
}

public protocol ScrollDirectionable {
    func setScrollDirection(_ direction: ScrollDirection)
}

public class ScrollingBox<Linear: Boxable & UIView>:
    UIScrollView,
    ScrollDirectionable,
    Delegatable,
    Stateful where Linear.RegulatorType: LinearRegulator
{
    public struct ViewState {
        public var direction: ScrollDirection = .y
        public init(direction: ScrollDirection = .y) {
            self.direction = direction
        }
    }

    public var state = State(ViewState())

    public typealias DelegateType = UIScrollViewDelegate

    public var scrollDelegate: RetainWrapper<UIScrollViewDelegate>? {
        didSet {
            delegate = scrollDelegate?.value
        }
    }

    public func setDelegate(_ delegate: UIScrollViewDelegate, retained: Bool) {
        scrollDelegate = RetainWrapper(value: delegate, retained: retained)
    }

    public private(set) var flat: Linear

    public init(flat: BoxGenerator<Linear> = { Linear() },
                direction: ScrollDirection = .y,
                builder: BoxBuilder<Linear>)
    {
        self.flat = flat()
        super.init(frame: .zero)

        attach {
            self.flat.attach($0) {
                guard let v = $0 as? Linear else { return }
                builder(v)
            }
            .autoJudgeScroll(true)
        }
        // 绑定方向
        _ = state.safeBind(to: self) { $0.handleDirection($1.direction) }

//        viewState.value.direction = direction
        setScrollDirection(direction)
    }

    public func setScrollDirection(_ direction: ScrollDirection) {
        state.value.direction = direction
    }

    func handleDirection(_ direction: ScrollDirection) {
        switch direction {
        case .x:
            flat.attach().size(.wrap, .fill)
        case .y:
            flat.attach().size(.fill, .wrap)
        case .both:
            flat.attach().size(.wrap, .wrap)
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }
}

public extension Puyo where T: ScrollDirectionable & AutoDisposable {
    func scrollDirection(_ d: ScrollDirection) -> Self {
        view.setScrollDirection(d)
        return self
    }

    func scrollDirection<O: Outputing>(_ d: O) -> Self where O.OutputType == ScrollDirection {
        d.safeBind(to: view) { v, d in
            v.setScrollDirection(d)
        }
        return self
    }
}
