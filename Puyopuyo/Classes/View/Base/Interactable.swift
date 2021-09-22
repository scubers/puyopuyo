//
//  Interactable.swift
//  Puyopuyo
//
//  Created by J on 2021/9/14.
//

import Foundation

// MARK: - Stateful

public protocol Stateful {
    associatedtype StateType
    var viewState: State<StateType> { get }
}

public extension Stateful {
    var output: Outputs<StateType> { viewState.asOutput() }

    func bind<R>(_ keyPath: KeyPath<StateType, R>) -> Outputs<R> {
        output.map(keyPath)
    }

    var _state: Outputs<StateType> { output }
}

// MARK: - Eventable

public protocol Eventable {
    associatedtype EventType
    var eventProducer: SimpleIO<EventType> { get }
}

public extension Eventable {
    func emmit(_ event: EventType) {
        eventProducer.input(value: event)
    }
}
