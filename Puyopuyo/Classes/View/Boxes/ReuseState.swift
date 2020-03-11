//
//  StateStation.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/3/7.
//

import Foundation

/// 作为复用view的状态暂存器
public class ReuseState<Data, Event> {
    public init() {}

    public struct Context<Data> {
        public var key: String
        public var event: Event
        public var data: Data
        public var index: Int = 0
    }

    private let _eventing = SimpleIO<Context<Data>>()
    public var eventing: SimpleOutput<Context<Data>> { _eventing.asOutput() }

    public class Node<Data, Event>: Eventable {
        public let state: State<Data>
        public let eventProducer = SimpleIO<Event>()
        public init(data: Data) {
            self.state = State(data)
        }
    }

    private var nodes = [AnyHashable: Node<Data, Event>]()
}

public extension ReuseState {
    
    func generateNode(_ data: Data) -> Node<Data, Event> {
        return .init(data: data)
    }
    
    func set(node: Node<Data, Event>, for key: String) {
        nodes[gen(key: key)] = node
    }
    
    @discardableResult
    func create(by key: String, data: Data) -> Node<Data, Event> {
        let newKey = gen(key: key)
        let node = generateNode(data)
        nodes[newKey] = node
        // 每个事件都绑定到station
        _ = node.eventProducer
            .asOutput()
            .map { [unowned node] in
                Context(key: newKey, event: $0, data: node.state.value)
            }
            .send(to: _eventing)
        return node
    }

    func input(data: Data, for key: String) {
        nodes[gen(key: key)]?.state.input(value: data)
    }

    func emmit(event: Event, for key: String) {
        nodes[gen(key: key)]?.emmit(event)
    }
    
}

public extension ReuseState {
    @discardableResult
    func create(by object: AnyObject, data: Data) -> Node<Data, Event> {
        let key = Unmanaged.passUnretained(object).toOpaque().debugDescription
        return create(by: key, data: data)
    }
    
    func set(node: Node<Data, Event>, for object: AnyObject) {
        let key = Unmanaged.passUnretained(object).toOpaque().debugDescription
        set(node: node, for: key)
    }
    
    func input(data: Data, for object: AnyObject) {
        let key = Unmanaged.passUnretained(object).toOpaque().debugDescription
        input(data: data, for: key)
    }
    
    func emmit(event: Event, for object: AnyObject) {
        let key = Unmanaged.passUnretained(object).toOpaque().debugDescription
        emmit(event: event, for: key)
    }
}

private extension ReuseState {
    func gen(key: String) -> String {
        return "\(key)|\(Data.self)|\(Event.self)"
    }
}
