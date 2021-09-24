//
//  ItemsBox.swift
//  Puyopuyo
//
//  Created by J on 2021/9/7.
//

import Foundation

// MARK: - Base

public struct RecyclerInfo<T> {
    public var data: T
    public var indexPath: IndexPath
    public var layoutableSize: CGSize
}

public class RecyclerTrigger<T> {
    public var isBuilding = true
    
    public init(creator: (() -> RecyclerInfo<T>?)? = nil) {
        self.createor = creator
    }

    var createor: (() -> RecyclerInfo<T>?)?

    public var context: RecyclerInfo<T>? {
        ensureNotBuiling()
        return createor?()
    }

    public func inContext(_ action: (RecyclerInfo<T>) -> Void) {
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

public typealias RecyclerBuilder<T> = (OutputBinder<RecyclerInfo<T>>, RecyclerTrigger<T>) -> UIView

private class Context<T> {
    let id = UUID()

    var view: UIView!

    let state = State<RecyclerInfo<T>>.unstable()
}

private protocol BoxRecycler: Stateful {
    associatedtype Data

    var container: Container<Data> { get }
    var builder: RecyclerBuilder<Data> { get }
}

private class Container<T> {
    var usingMap = [Context<T>]()
    var freeMap = [Context<T>]()
}

extension BoxRecycler where Self: Boxable & UIView, StateType.OutputType == [Data] {
    func getLayoutableSize() -> CGSize {
        var width: CGFloat = bounds.width
        var height: CGFloat = bounds.height
        let size = regulator.size
        if size.width.isWrap {
            width = size.width.max
        }
        if size.height.isWrap {
            height = size.height.max
        }
        return CGSize(width: width - regulator.padding.getHorzTotal(), height: height - regulator.padding.getVertTotal())
    }

    private func getInfo(index: Int) -> RecyclerInfo<Data> {
        RecyclerInfo(
            data: viewState.specificValue[index],
            indexPath: IndexPath(item: index, section: 0),
            layoutableSize: getLayoutableSize()
        )
    }

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
        let diff = Diff(src: container.usingMap.map(\.state.value.data), dest: dataSource, identifier: {
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

        dataSource.enumerated().forEach { idx, _ in
            let context = container.usingMap[idx]
            context.view.removeFromSuperview()
            addSubview(context.view)
            context.state.input(value: getInfo(index: idx))
        }

        if diff.isDifferent() {
            setNeedsLayout()
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
            let trigger = RecyclerTrigger<Data>()
            let view = builder(c.state.asOutput().binder, trigger)

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
            trigger.createor = { [weak self] in
                if let c = finder(), let info = self?.getInfo(index: c.state.value.indexPath.item) {
                    return info
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
        dataSource.enumerated().forEach { idx, _ in
            let info = getInfo(index: idx)
            if idx < container.usingMap.count {
                container.usingMap[idx].state.input(value: info)
            } else {
                let context = getContext()
                context.state.input(value: info)
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
        setNeedsLayout()
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

// MARK: - LinearBoxRecycle

public class LinearBoxRecycle<T>: LinearBox, BoxRecycler {
    typealias Data = T

    fileprivate var container = Container<T>()

    fileprivate var builder: RecyclerBuilder<T>

    public var viewState = State<[T]>([])

    public required init(builder: @escaping RecyclerBuilder<T>) {
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
    public required init(builder: @escaping RecyclerBuilder<T>) {
        super.init(builder: builder)
        attach().direction(.x)
    }
}

public class VBoxRecycle<T>: LinearBoxRecycle<T> {
    public required init(builder: @escaping RecyclerBuilder<T>) {
        super.init(builder: builder)
        attach().direction(.y)
    }
}

// MARK: - FlowBoxRecycle

public class FlowBoxRecycle<T>: FlowBox, BoxRecycler {
    typealias Data = T

    fileprivate var container = Container<T>()

    fileprivate var builder: RecyclerBuilder<T>

    public var viewState = State<[T]>([])

    public required init(count: Int, builder: @escaping RecyclerBuilder<T>) {
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
    public required init(count: Int = 0, builder: @escaping RecyclerBuilder<T>) {
        super.init(count: count, builder: builder)
        attach().direction(.x).arrangeCount(count)
    }
}

public class VFlowRecycle<T>: FlowBoxRecycle<T> {
    public required init(count: Int = 0, builder: @escaping RecyclerBuilder<T>) {
        super.init(count: count, builder: builder)
        attach().direction(.y)
    }
}

// MARK: - ZBoxRecycle

public class ZBoxRecycle<T>: ZBox, BoxRecycler {
    typealias Data = T

    fileprivate var container = Container<T>()

    fileprivate var builder: RecyclerBuilder<T>

    public var viewState = State<[T]>([])

    public required init(builder: @escaping RecyclerBuilder<T>) {
        self.builder = builder
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    public required init?(coder argument: NSCoder) {
        fatalError()
    }
}
