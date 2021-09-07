//
//  ItemsBox.swift
//  Puyopuyo
//
//  Created by J on 2021/9/7.
//

import Foundation

public class ItemsBox<T, E>: FlatBox, Stateful, Eventable {
    public struct Event {
        public var event: E
        public var index: Int
        public var data: T
    }

    public var viewState = State<[T]>([])

    public var eventProducer = SimpleIO<Event>()

    public typealias Builder = (Outputs<T>, Inputs<E>) -> UIView

    var builder: Builder

    private var usingMap = Set<Context<T, E>>()
    private var freeMap = Set<Context<T, E>>()

    public init(builder: @escaping Builder) {
        self.builder = builder
        super.init(frame: .zero)

        viewState.safeBind(to: self) { this, dataSource in
            this.usingMap.forEach { c in
                c.view.removeFromSuperview()
                this.freeMap.insert(c)
            }

            dataSource.enumerated().forEach { data in
                if let c = this.freeMap.popFirst() {
                    this.addSubview(c.view)
                    c.state.input(value: data.element)
                    this.usingMap.insert(c)
                } else {
                    let c = Context<T, E>()
                    c.state.input(value: data.element)
                    c.event
                        .map { Event(event: $0, index: data.offset, data: data.element) }
                        .send(to: this.eventProducer)
                        .dispose(by: this)
                    let view = this.builder(c.state.asOutput(), c.event.asInput())
                    c.view = view
                    this.addSubview(view)
                    this.usingMap.insert(c)
                }
            }
        }
    }

    @available(*, unavailable)
    public required init?(coder argument: NSCoder) {
        fatalError()
    }
}

private class Context<T, E>: Hashable {
    static func == (lhs: Context<T, E>, rhs: Context<T, E>) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var view: UIView!
    let state = State<T>.unstable()
    let event = SimpleIO<E>()
    let id = UUID()
}
