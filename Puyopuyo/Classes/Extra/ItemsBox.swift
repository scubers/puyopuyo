//
//  ItemsBox.swift
//  Puyopuyo
//
//  Created by J on 2021/9/7.
//

import Foundation

public class Trigger<T> {
    public var isBuilding = true
    var dataFinder: (() -> T?)?
    var indexFinder: (() -> Int?)?

    public var data: T? {
        ensureNotBuiling()
        return dataFinder?()
    }

    public var index: Int? {
        ensureNotBuiling()
        return indexFinder?()
    }

    private func ensureNotBuiling() {
        if isBuilding {
            fatalError("can not call trigger when building")
        }
    }
}

// MARK: - FlatBoxRecycle

public class FlatBoxRecycle<T>: FlatBox, Recycler {
    typealias Data = T

    fileprivate var container = Container<T>()

    fileprivate var builder: (Outputs<T>, Trigger<T>) -> UIView

    public var viewState = State<[T]>([])

    public required init(builder: @escaping (Outputs<T>, Trigger<T>) -> UIView) {
        self.builder = builder
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder argument: NSCoder) {
        fatalError()
    }
}

public class HBoxRecycle<T>: FlatBoxRecycle<T> {
    public required init(builder: @escaping (Outputs<T>, Trigger<T>) -> UIView) {
        super.init(builder: builder)
        attach().direction(.x)
    }
}

public class VBoxRecycle<T>: FlatBoxRecycle<T> {
    public required init(builder: @escaping (Outputs<T>, Trigger<T>) -> UIView) {
        super.init(builder: builder)
        attach().direction(.y)
    }
}

// MARK: - FlowBoxRecycle

public class FlowBoxRecycle<T>: FlowBox, Recycler {
    typealias Data = T

    fileprivate var container = Container<T>()

    fileprivate var builder: (Outputs<T>, Trigger<T>) -> UIView

    public var viewState = State<[T]>([])

    public required init(count: Int, builder: @escaping (Outputs<T>, Trigger<T>) -> UIView) {
        self.builder = builder
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    public required init?(coder argument: NSCoder) {
        fatalError()
    }
}

public class HFlowRecycle<T>: FlowBoxRecycle<T> {
    public required init(count: Int = 0, builder: @escaping (Outputs<T>, Trigger<T>) -> UIView) {
        super.init(count: count, builder: builder)
        attach().direction(.x).arrangeCount(count)
    }
}

public class VFlowRecycle<T>: FlowBoxRecycle<T> {
    public required init(count: Int = 0, builder: @escaping (Outputs<T>, Trigger<T>) -> UIView) {
        super.init(count: count, builder: builder)
        attach().direction(.y)
    }
}

// MARK: - ZBoxRecycle

public class ZBoxRecycle<T>: ZBox, Recycler {
    typealias Data = T

    fileprivate var container = Container<T>()

    fileprivate var builder: (Outputs<T>, Trigger<T>) -> UIView

    public var viewState = State<[T]>([])

    public required init(builder: @escaping (Outputs<T>, Trigger<T>) -> UIView) {
        self.builder = builder
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    public required init?(coder argument: NSCoder) {
        fatalError()
    }
}

// MARK: - Private

private class Context<T>: Hashable {
    static func == (lhs: Context<T>, rhs: Context<T>) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id = UUID()

    var view: UIView!

    let state = State<T>.unstable()

    var index: Int = 0
}

private protocol Recycler: Stateful {
    associatedtype Data

    var container: Container<Data> { get }
    var builder: (Outputs<Data>, Trigger<Data>) -> UIView { get }
}

private class Container<T> {
//    var usingMap = Set<Context<T>>()
//    var freeMap = Set<Context<T>>()

    var usingMap = [Context<T>]()
    var freeMap = [Context<T>]()
}

extension Recycler where Self: Boxable & UIView, StateType == [Data] {
    func setup() {
        viewState.safeBind(to: self) { this, dataSource in
            this.reload(dataSource: dataSource)
        }
    }

    private func reload(dataSource: [Data]) {
        dataSource.enumerated().forEach { idx, element in
            if idx < container.usingMap.count {
                container.usingMap[idx].state.input(value: element)
            } else {
                if !container.freeMap.isEmpty {
                    let last = container.freeMap.removeLast()
                    last.state.input(value: element)
                    container.usingMap.append(last)
                    addSubview(last.view)
                } else {
                    let c = Context<Data>()
                    c.state.input(value: element)
                    let trigger = Trigger<Data>()
                    let view = builder(c.state.asOutput(), trigger)

                    let finder = { [weak view, weak self] () -> Context<Data>? in
                        guard let view = view, let self = self else {
                            return nil
                        }
                        for context in self.container.usingMap {
                            if context.view == view {
                                return context
                            }
                        }
                        return nil
                    }
                    trigger.indexFinder = { finder()?.index }
                    trigger.dataFinder = { finder()?.state.value }
                    trigger.isBuilding = false
                    c.view = view
                    container.usingMap.append(c)
                    addSubview(view)
                }
            }
        }

        let total = container.usingMap.count
        let delta = total - dataSource.count

        if delta > 0 {
            for idx in (total - delta ..< total).reversed() {
                let c = container.usingMap.remove(at: idx)
                c.view.removeFromSuperview()
                container.freeMap.append(c)
            }
        }
    }
}
