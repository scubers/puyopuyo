//
//  BuildPuzzleHandler.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/29.
//  Copyright © 2022 CocoaPods. All rights reserved.
//



enum PuzzleContainerType {
    case none
    case box
    case group
}

protocol PuzzleTemplate {
    var name: String { get }
    var templateId: String { get }
    var containerType: PuzzleContainerType { get }
    var builderHandler: BuildPuzzleHandler { get }
}

protocol BuildPuzzleHandler {
    func createPuzzle() -> PuzzlePiece
    func createState() -> PuzzleStateProvider
    func initializeCode() -> String
}

public typealias PuzzlePiece = BoxLayoutNode & AutoDisposable

protocol IPuzzleState {}

protocol PuzzleStateProvider {
    var states: [IPuzzleState] { get }

    func bindState(to puzzle: PuzzlePiece)

    func stateFromPuzzle(_ puzzle: PuzzlePiece)

    func resume(_ param: [String: Any]?)

    func serialize() -> [String: Any]?

    func generateCode() -> [String]
}

extension BoxLayoutNode where Self: AutoDisposable {
    func _bind<O: Outputing, V>(_ output: O, action: @escaping (BoxLayoutNode & AutoDisposable, V) -> Void) where O.OutputType == V {
        addDisposer(output.outputing { [weak self] v in
            if let self = self {
                action(self, v)
            }
        }, for: nil)
    }

    func _bind<O: Outputing, V>(_ output: O, keyPath: ReferenceWritableKeyPath<Self, V>) where O.OutputType == V {
        addDisposer(output.outputing { [weak self] v in
            if let self = self {
                self[keyPath: keyPath] = v
            }
        }, for: nil)
    }
}
