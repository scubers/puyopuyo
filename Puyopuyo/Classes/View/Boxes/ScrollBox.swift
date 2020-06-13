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
                flat: @escaping BoxGenerator<T> = { T() },
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

public enum ScrollDirection {
    case x, y, both
}

public protocol ScrollDirectionable {
    func setScrollDirection(_ direction: ScrollDirection)
}

public class ScrollingBox<Flat: Boxable & UIView>:
    UIScrollView,
    ScrollDirectionable,
    Delegatable,
    Stateful where Flat.RegulatorType: FlatRegulator {
    public struct ViewState {
        public var direction: ScrollDirection = .y
        public init(direction: ScrollDirection = .y) {
            self.direction = direction
        }
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

    public init(flat: BoxGenerator<Flat> = { Flat() },
                direction: ScrollDirection = .y,
                builder: BoxBuilder<Flat>) {
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
        _ = viewState.safeBind(to: self) { $0.handleDirection($1.direction) }

//        viewState.value.direction = direction
        setScrollDirection(direction)
    }

    public func setScrollDirection(_ direction: ScrollDirection) {
        viewState.value.direction = direction
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
    
    public required init?(coder _: NSCoder) {
        fatalError()
    }
}

public extension Puyo where T: ScrollDirectionable & UnbinderBag {
    func scrollDirection(_ d: ScrollDirection) -> Self {
        view.setScrollDirection(d)
        return self
    }

    func scrollDirection<O: Outputing>(_ d: O) -> Self where O.OutputType == ScrollDirection {
        d.safeBind(to: view, id: #function) { v, d in
            v.setScrollDirection(d)
        }
        return self
    }
}
