//
//  State.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import HandyJSON


final class PuzzleState<T>: IPuzzleState, Outputing, Inputing, SpecificValueable, OutputingModifier {
    init(title: String, value: T) {
        self.title = title
        state.value = value
    }

    let title: String
    let state = State<T>.unstable()

    func outputing(_ block: @escaping (T) -> Void) -> Disposer {
        state.outputing(block)
    }

    func input(value: T) {
        state.input(value: value)
    }

    var specificValue: T {
        get { state.value }
        set { state.value = newValue }
    }
}

class BasePuzzleStateModel: HandyJSON {
    required init() {}
    var activated: Bool?
    var flowEnding: Bool?
    var margin: PuzzleInsets?
    var alignment: PuzzleAlignment?
    var visibility: PuzzleVisibility?
    var width: PuzzleSizeDesc?
    var height: PuzzleSizeDesc?
}

class BasePuzzleStateProvider: PuzzleStateProvider {
    lazy var width = PuzzleState(title: "Width", value: defaultMeasure.size.width)
    lazy var height = PuzzleState(title: "Height", value: defaultMeasure.size.height)
    lazy var visibility = PuzzleState(title: "Visibility", value: Visibility.visible)
    lazy var margin = PuzzleState(title: "Margin", value: defaultMeasure.margin)
    lazy var alignment = PuzzleState(title: "Alignment", value: defaultMeasure.alignment)
    lazy var flowEnding = PuzzleState(title: "FlowEnding", value: defaultMeasure.flowEnding)

    var states: [IPuzzleState] {
        [
            width,
            height,
            visibility,
            margin,
            alignment,
            flowEnding,
        ]
    }

    func generateCode() -> [String] {
        var codes = [String]()
        if let model = BasePuzzleStateModel.deserialize(from: serialize()) {
            if let v = model.activated { codes.append(".activated(\(v))") }
            if let v = model.flowEnding { codes.append(".flowEnding(\(v))") }
            if let v = model.visibility { codes.append(".visibility(\(v))") }
            if let v = model.margin { codes.append(".margin(top: \(v.top ?? 0), left: \(v.left ?? 0), bottom: \(v.bottom ?? 0), right: \(v.right ?? 0))") }
            if let v = model.alignment?.getAlignment() { codes.append(".alignment(\(v.genCode()))") }
            if let v = model.width?.getSizeDescription() { codes.append(".width(\(v.genCode()))") }
            if let v = model.height?.getSizeDescription() { codes.append(".height(\(v.genCode()))") }
        }
        return codes
    }

    func stateFromPuzzle(_ puzzle: PuzzlePiece) {
        let m = puzzle.layoutMeasure
        width.input(value: m.size.width)
        height.input(value: m.size.height)
        visibility.input(value: puzzle.layoutVisibility)
        margin.input(value: m.margin)
        alignment.input(value: m.alignment)
        flowEnding.input(value: m.flowEnding)
    }

    func bindState(to puzzle: PuzzlePiece) {
        puzzle._bind(flowEnding, action: { $0.layoutMeasure.flowEnding = $1 })
        puzzle._bind(margin, action: { $0.layoutMeasure.margin = $1 })
        puzzle._bind(alignment, action: { $0.layoutMeasure.alignment = $1 })
        puzzle._bind(visibility, action: { $0.layoutVisibility = $1 })
        puzzle._bind(width, action: { $0.layoutMeasure.size.width = $1 })
        puzzle._bind(height, action: { $0.layoutMeasure.size.height = $1 })
    }

    func resume(_ param: [String: Any]?) {
        if let node = BasePuzzleStateModel.deserialize(from: param) {
//            if let v = node.activated { activated.state.value = v }
            if let v = node.flowEnding { flowEnding.state.value = v }
            if let v = node.margin?.getInsets() { margin.state.value = v }
            if let v = node.alignment?.getAlignment() { alignment.state.value = v }
            if let v = node.visibility?.getVisibility() { visibility.state.value = v }
            if let v = node.width?.getSizeDescription() { width.state.value = v }
            if let v = node.height?.getSizeDescription() { height.state.value = v }
        }
    }

    func serialize() -> [String: Any]? {
        let node = BasePuzzleStateModel()
//        if activated.state.value != defaultMeasure.activated {
//            node.activated = activated.state.value
//        }
        if flowEnding.state.value != defaultMeasure.flowEnding {
            node.flowEnding = flowEnding.state.value
        }
        if margin.state.value != defaultMeasure.margin {
            node.margin = PuzzleInsets.from(margin.state.value)
        }
        if alignment.state.value != defaultMeasure.alignment {
            node.alignment = PuzzleAlignment.from(alignment.state.value)
        }
        if visibility.state.value != .visible {
            node.visibility = PuzzleVisibility.from(visibility.state.value)
        }
        if width.state.value != defaultMeasure.size.width {
            node.width = PuzzleSizeDesc.from(width.state.value)
        }
        if height.state.value != defaultMeasure.size.height {
            node.height = PuzzleSizeDesc.from(height.state.value)
        }
        return node.toJSON()
    }

    lazy var defaultMeasure: Measure = getDefaultMeasure()

    func getDefaultMeasure() -> Measure {
        return Measure(delegate: nil, sizeDelegate: nil, childrenDelegate: nil)
    }
}

class BoxPuzzleStateModel: BasePuzzleStateModel {
    var padding: PuzzleInsets?
    var justifyContent: PuzzleAlignment?
}

class BoxPuzzleStateProvider: BasePuzzleStateProvider {
    lazy var padding = PuzzleState(title: "Padding", value: (defaultMeasure as! Regulator).padding)
    lazy var justifyContent = PuzzleState(title: "JustifyContent", value: (defaultMeasure as! Regulator).justifyContent)
    override var states: [IPuzzleState] {
        super.states + [
            padding, justifyContent,
        ]
    }

    override func generateCode() -> [String] {
        var codes = super.generateCode()
        if let model = BoxPuzzleStateModel.deserialize(from: serialize()) {
            if let v = model.padding { codes.append(".padding(top: \(v.top ?? 0), left: \(v.left ?? 0), bottom: \(v.bottom ?? 0), right: \(v.right ?? 0))") }
            if let v = model.justifyContent?.getAlignment() { codes.append(".justifyContent(\(v.genCode()))") }
        }
        return codes
    }

    override func bindState(to puzzle: PuzzlePiece) {
        super.bindState(to: puzzle)
        puzzle._bind(padding, action: { $0.getReg()?.padding = $1 })
        puzzle._bind(justifyContent, action: { $0.getReg()?.justifyContent = $1 })
    }
    
    override func stateFromPuzzle(_ puzzle: PuzzlePiece) {
        super.stateFromPuzzle(puzzle)
        if let reg = puzzle.getReg() {
            padding.input(value: reg.padding)
            justifyContent.input(value: reg.justifyContent)
        }
    }

    override func resume(_ param: [String: Any]?) {
        super.resume(param)
        if let node = BoxPuzzleStateModel.deserialize(from: param) {
            if let v = node.padding?.getInsets() { padding.state.value = v }
            if let v = node.justifyContent?.getAlignment() { justifyContent.state.value = v }
        }
    }

    override func serialize() -> [String: Any]? {
        let node = BoxPuzzleStateModel.deserialize(from: super.serialize()) ?? BoxPuzzleStateModel()
        let defaultMeasure = getDefaultMeasure() as! Regulator
        if padding.state.value != defaultMeasure.padding {
            node.padding = PuzzleInsets.from(padding.state.value)
        }
        if justifyContent.state.value != defaultMeasure.justifyContent {
            node.justifyContent = PuzzleAlignment.from(justifyContent.state.value)
        }
        return node.toJSON()
    }

    override func getDefaultMeasure() -> Measure {
        return Regulator(delegate: nil, sizeDelegate: nil, childrenDelegate: nil)
    }
}

extension BoxLayoutNode {
    private func asMeasureType<T>() -> T? {
        return layoutMeasure as? T
    }

    func getReg() -> Regulator? { asMeasureType() }
    func getZReg() -> ZRegulator? { asMeasureType() }
    func getFlowReg() -> FlowRegulator? { asMeasureType() }
    func getLinearReg() -> LinearRegulator? { asMeasureType() }
}
