//
//  InspectorViewFactory.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/29.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


import UIKit

class MultiInputs<T>: Inputing {
    typealias InputType = T
    private let inputs: [Inputs<T>]
    init(_ inputs: [Inputs<T>]) {
        self.inputs = inputs
    }

    func input(value: T) {
        inputs.forEach { $0.input(value: value) }
    }
}

struct InspectorViewFactory {
    func createInspect(_ state: IPuzzleState, onChanged: SimpleIO<Void>) -> ViewDisplayable? {
        if let state = state as? PuzzleState<Bool> {
            return BoolInspector().attach()
                .setState(\.title, state.title)
                .setState(\.value, state.state)
                .onEvent(MultiInputs([state.state.asInput(), onChanged.asInput { _ in }]))

        } else if let state = state as? PuzzleState<UIEdgeInsets> {
            return InsetsInspector()
                .attach()
                .state(.init(title: state.title, insets: state.state.value))
                .onEvent(MultiInputs([state.state.asInput(), onChanged.asInput { _ in }]))
        } else if let state = state as? PuzzleState<Alignment> {
            return AlignmentInspector().attach()
                .setState(\.title, state.title)
                .setState(\.alignment, state.state)
                .onEvent(MultiInputs([state.state.asInput(), onChanged.asInput { _ in }]))
        } else if let state = state as? PuzzleState<Visibility> {
            let selection = [
                Selection(title: "Visible", value: Visibility.visible),
                .init(title: "Gone", value: Visibility.gone),
                .init(title: "Invisible", value: Visibility.invisible),
                .init(title: "Free", value: Visibility.free),
            ]
            let selected = state.state.map { v in
                selection.firstIndex(where: { $0.value == v }) ?? 0
            }
            return SelectionInspector(title: state.title, selection: selection).attach()
                .state(selected)
                .onEvent(MultiInputs([state.state.asInput(), onChanged.asInput { _ in }]))
        } else if let state = state as? PuzzleState<Direction> {
            let selection = [
                Selection(title: "Horz", value: Direction.horizontal),
                Selection(title: "Vert", value: .vertical),
            ]
            let selected = state.state.map { v in
                selection.firstIndex(where: { $0.value == v }) ?? 0
            }
            return SelectionInspector(title: state.title, selection: selection).attach()
                .state(selected)
                .onEvent(MultiInputs([state.state.asInput(), onChanged.asInput { _ in }]))
        } else if let state = state as? PuzzleState<SizeDescription> {
            let title = state.title
            return SizeDescriptionInspector()
                .attach()
                .state(state.state.map {
                    .init(title: title, sizeType: $0.sizeType, fixedValue: $0.fixedValue, ratio: $0.ratio, add: $0.add, min: $0.min, max: $0.max, priority: $0.priority, shrink: $0.shrink, grow: $0.grow, aspectRatio: $0.aspectRatio)
                })
                .onEvent(MultiInputs([state.state.asInput(), onChanged.asInput { _ in }]))
        } else if let state = state as? PuzzleState<Format> {
            let selection = [
                Selection(title: "Leading", value: Format.leading),
                Selection(title: "Center", value: .center),
                Selection(title: "Between", value: .between),
                Selection(title: "Round", value: .round),
                Selection(title: "Trailing", value: .trailing),
            ]
            let selected = state.state.map { v in
                selection.firstIndex(where: { $0.value == v }) ?? 0
            }
            return SelectionInspector(title: state.title, selection: selection).attach()
                .state(selected)
                .onEvent(MultiInputs([state.state.asInput(), onChanged.asInput { _ in }]))
        } else if let state = state as? PuzzleState<CGFloat> {
            return CGFloatInspector().attach()
                .setState(\.title, state.title)
                .setState(\.value, state.state)
                .onEvent(MultiInputs([state.state.asInput(), onChanged.asInput { _ in }]))
        } else if let state = state as? PuzzleState<Int> {
            return CGFloatInspector().attach()
                .setState(\.title, state.title)
                .setState(\.value, state.state.map { CGFloat($0) })
                .onEvent(MultiInputs([state.state.asInput { Int($0) }, onChanged.asInput { _ in }]))
        } else if let state = state as? PuzzleState<String> {
            return StringInspector().attach()
                .setState(\.title, state.title)
                .setState(\.value, state.state)
                .onEvent(MultiInputs([state.state.asInput(), onChanged.asInput { _ in }]))
        } else {
//            fatalError()
            print("Unsupported inspect type: \(type(of: state))")
            return nil
        }
    }
}
