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
    var binder: OutputBinder<StateType> { viewState.binder }
}

// MARK: - Eventable

public protocol Eventable {
    associatedtype EmitterType where EmitterType: Inputing & Outputing, EmitterType.InputType == EmitterType.OutputType
    var emmiter: EmitterType { get }
}

public extension Eventable {
    func emmit(_ event: EmitterType.OutputType) {
        emmiter.input(value: event)
    }
}
