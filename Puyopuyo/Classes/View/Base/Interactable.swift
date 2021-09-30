//
//  Interactable.swift
//  Puyopuyo
//
//  Created by J on 2021/9/14.
//

import Foundation

// MARK: - Stateful

public protocol Stateful {
    associatedtype StateType where StateType: Inputing & Outputing & SpecificValueable,
        StateType.OutputType == StateType.InputType,
        StateType.OutputType == StateType.SpecificValue

    /// `State` is a choice
    /// ```
    /// protocol MyView: UIView, Stateful {
    ///     var state = State<String>("")
    /// }
    /// ```
    ///
    var state: StateType { get }
}

public extension Stateful {
    var binder: OutputBinder<StateType.OutputType> { state.asOutput().binder }

    @available(*, deprecated, message: "Use [state]")
    var viewState: StateType { state }
}

// MARK: - Eventable

public protocol Eventable {
    associatedtype EmitterType where EmitterType: Inputing & Outputing, EmitterType.InputType == EmitterType.OutputType

    /// `SimpleIO` is a choice
    /// ```
    /// protocol MyView: UIView, Eventable {
    ///     var emitter = SimpleIO<String>()
    /// }
    /// ```
    ///
    var emitter: EmitterType { get }
}

public extension Eventable {
    func emit(_ event: EmitterType.OutputType) {
        emitter.input(value: event)
    }
}
