//
//  ItemsBox.swift
//  Puyopuyo
//
//  Created by J on 2021/9/7.
//

import Foundation

public class Trigger<T> {
    public var isBuilding = true

    public struct Context<T> {
        public var data: T
        public var index: Int
    }

    var createor: (() -> Context<T>?)?

    public var context: Context<T>? {
        ensureNotBuiling()
        return createor?()
    }

    public func inContext(_ action: (Context<T>) -> Void) {
        if let context = context {
            action(context)
        }
    }

    private func ensureNotBuiling() {
        if isBuilding {
            fatalError("can not call trigger when building")
        }
    }
}

// MARK: - LinearBoxRecycle

public class LinearBoxRecycle<T>: LinearBox, BoxRecycler {
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

public class HBoxRecycle<T>: LinearBoxRecycle<T> {
    public required init(builder: @escaping (Outputs<T>, Trigger<T>) -> UIView) {
        super.init(builder: builder)
        attach().direction(.x)
    }
}

public class VBoxRecycle<T>: LinearBoxRecycle<T> {
    public required init(builder: @escaping (Outputs<T>, Trigger<T>) -> UIView) {
        super.init(builder: builder)
        attach().direction(.y)
    }
}

// MARK: - FlowBoxRecycle

public class FlowBoxRecycle<T>: FlowBox, BoxRecycler {
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

public class ZBoxRecycle<T>: ZBox, BoxRecycler {
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

    let state = State<(Int, T)>.unstable()
}

private protocol BoxRecycler: Stateful {
    associatedtype Data

    var container: Container<Data> { get }
    var builder: (Outputs<Data>, Trigger<Data>) -> UIView { get }
}

private class Container<T> {
    var usingMap = [Context<T>]()
    var freeMap = [Context<T>]()
}

extension BoxRecycler where Self: Boxable & UIView, StateType == [Data] {
    func setup() {
        viewState.safeBind(to: self) { this, dataSource in
            if Data.self is RecycleIdentifiable.Type {
                this.reloadWithDiff(dataSource: dataSource)
            } else {
                this.reload(dataSource: dataSource)
            }
        }
    }

    private func reloadWithDiff(dataSource: [Data]) {
        let diff = Diff(src: container.usingMap.map(\.state.value).map { $1 }, dest: dataSource, identifier: {
            ($0 as! RecycleIdentifiable).recycleIdentifier
        })
        diff.check()

        var list = [Context<Data>?](repeating: nil, count: dataSource.count)

        diff.delete.forEach { delete in
            // recycle the old context to free map
            let context = container.usingMap[delete.from]
            recycleContext(context)
        }

        diff.insert.forEach { insert in
            // get context from free map or create a new one
            list[insert.to] = getContext()
        }

        diff.stay.forEach { stay in
            list[stay.to] = container.usingMap[stay.from]
        }

        diff.move.forEach { move in
            list[move.to] = container.usingMap[move.from]
        }
        container.usingMap = list.map { $0! }

        dataSource.enumerated().forEach { idx, element in
            let context = container.usingMap[idx]
            context.view.removeFromSuperview()
            addSubview(context.view)
            context.state.input(value: (idx, element))
        }
    }

    private func recycleContext(_ context: Context<Data>) {
        context.view.removeFromSuperview()
        context.view.frame = .zero
        container.freeMap.append(context)
    }

    private func getContext() -> Context<Data> {
        if container.freeMap.isEmpty {
            let c = Context<Data>()
            let trigger = Trigger<Data>()
            let view = builder(c.state.asOutput().map { $0.1 }, trigger)

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
            trigger.createor = {
                if let c = finder() {
                    return .init(data: c.state.value.1, index: c.state.value.0)
                }
                return nil
            }
            trigger.isBuilding = false
            c.view = view
            return c
        } else {
            return container.freeMap.removeLast()
        }
    }

    private func reload(dataSource: [Data]) {
        dataSource.enumerated().forEach { idx, element in
            if idx < container.usingMap.count {
                container.usingMap[idx].state.input(value: (idx, element))
            } else {
                let context = getContext()
                context.state.input(value: (idx, element))
                container.usingMap.append(context)
                addSubview(context.view)
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

public protocol RecycleIdentifiable {
    var recycleIdentifier: String { get }
}

public extension RecycleIdentifiable where Self: CustomStringConvertible {
    var recycleIdentifier: String { description }
}

extension String: RecycleIdentifiable {}
extension Int: RecycleIdentifiable {}
