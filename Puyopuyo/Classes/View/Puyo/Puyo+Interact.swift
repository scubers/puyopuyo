//
//  Puyo+Interact.swift
//  Puyopuyo
//
//  Created by J on 2022/5/26.
//

import Foundation

// MARK: - Eventable

/// When `T` is Eventable, call when emitter emit some events
public extension Puyo where T: Eventable {
    @discardableResult
    func onEvent<I: Inputing>(_ input: I) -> Self where I.InputType == T.EmitterType.OutputType {
        let disposer = view.emitter.send(to: input)
        if let v = view as? AutoDisposable {
            disposer.dispose(by: v)
        }
        return self
    }

    @discardableResult
    func onEvent(_ event: @escaping (T.EmitterType.OutputType) -> Void) -> Self {
        onEvent(Inputs(event))
    }

    @discardableResult
    func onEvent<O: AnyObject>(to: O?, _ event: @escaping (O, T.EmitterType.OutputType) -> Void) -> Self {
        onEvent(Inputs { [weak to] v in
            if let to = to {
                event(to, v)
            }
        })
    }
}

public extension Puyo where T: Eventable, T.EmitterType.OutputType: Equatable {
    @discardableResult
    func onEvent(_ eventType: T.EmitterType.OutputType, _ event: @escaping () -> Void) -> Self {
        onEvent(Inputs {
            if eventType == $0 {
                event()
            }
        })
    }
}

// MARK: - Stateful

public extension Puyo where T: Stateful {
    @discardableResult
    func state(value: T.StateType.OutputType) -> Self {
        view.state.input(value: value)
        return self
    }

    @discardableResult
    func setState<V>(_ keyPath: WritableKeyPath<T.StateType.OutputType, V>, _ value: V) -> Self {
        var state = view.state.specificValue
        state[keyPath: keyPath] = value
        view.state.input(value: state)
        return self
    }

    @discardableResult
    func setState<V>(_ keyPath: WritableKeyPath<T.StateType.OutputType, V?>, _ value: V) -> Self {
        var state = view.state.specificValue
        state[keyPath: keyPath] = value
        view.state.input(value: state)
        return self
    }
}

public extension Puyo where T: Stateful & AutoDisposable {
    @discardableResult
    func state<O: Outputing>(_ output: O) -> Self where O.OutputType == T.StateType.OutputType {
        doOn(output) { $0.state.input(value: $1) }
    }

    @discardableResult
    func bindState<O: Outputing, V>(_ keyPath: WritableKeyPath<T.StateType.OutputType, V>, _ output: O) -> Self where O.OutputType == V {
        doOn(output) { this, v in
            var value = this.state.specificValue
            value[keyPath: keyPath] = v
            this.state.input(value: value)
        }
    }

    @discardableResult
    func bindState<O: Outputing, V>(_ keyPath: WritableKeyPath<T.StateType.OutputType, V?>, _ output: O) -> Self where O.OutputType == V {
        doOn(output) { this, v in
            var value = this.state.specificValue
            value[keyPath: keyPath] = v
            this.state.input(value: value)
        }
    }
}
