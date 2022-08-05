//
//  LinearPuzzleTemplate.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/29.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation



class LinearBoxPuzzleTemplate: PuzzleTemplate {
    var templateId: String { "template.linearBox" }

    var name: String { "LinearBox" }

    var containerType: PuzzleContainerType { .box }

    var builderHandler: BuildPuzzleHandler { LinearBuildPuzzleHandler(isGroup: false) }
}

class LinearGroupPuzzleTemplate: PuzzleTemplate {
    var templateId: String { "template.linearGroup" }

    var name: String { "LinearGroup" }

    var containerType: PuzzleContainerType { .group }

    var builderHandler: BuildPuzzleHandler { LinearBuildPuzzleHandler(isGroup: true) }
}

struct LinearBuildPuzzleHandler: BuildPuzzleHandler {
    let isGroup: Bool

    func createPuzzle() -> PuzzlePiece {
        isGroup ? LinearGroup() : LinearBox()
    }

    func createState() -> PuzzleStateProvider {
        let provider = LinearPuzzleStateProvider()
        provider.padding.specificValue = .init(top: 8, left: 8, bottom: 8, right: 8)
        return provider
    }
    
    func initializeCode() -> String {
        isGroup ? "LinearGroup()" : "LinearBox()"
    }
}

class LinearPuzzleStateModel: BoxPuzzleStateModel {
    var direction: PuzzleDirection?
    var format: PuzzleFormat?
    var reverse: Bool?
    var space: CGFloat?
}

class LinearPuzzleStateProvider: BoxPuzzleStateProvider {
    lazy var direction = PuzzleState(title: "Direction", value: (defaultMeasure as! LinearRegulator).direction)
    lazy var format = PuzzleState(title: "Format", value: (defaultMeasure as! LinearRegulator).format)
    lazy var reverse = PuzzleState(title: "Reverse", value: (defaultMeasure as! LinearRegulator).reverse)
    lazy var space = PuzzleState(title: "Space", value: (defaultMeasure as! LinearRegulator).space)

    override var states: [IPuzzleState] {
        super.states + [direction, format, reverse, space]
    }

    override func generateCode() -> [String] {
        var codes = super.generateCode()
        if let model = LinearPuzzleStateModel.deserialize(from: serialize()) {
            if let v = model.direction?.getDirection() { codes.append(".direction(\(v.genCode()))") }
            if let v = model.format?.getFormat() { codes.append(".format(\(v.genCode()))") }
            if let v = model.reverse { codes.append(".reverse(\(v))") }
            if let v = model.space { codes.append(".space(\(v))") }
        }
        return codes
    }

    override func bindState(to puzzle: PuzzlePiece) {
        super.bindState(to: puzzle)
        puzzle._bind(direction, action: { $0.getLinearReg()?.direction = $1 })
        puzzle._bind(format, action: { $0.getLinearReg()?.format = $1 })
        puzzle._bind(reverse, action: { $0.getLinearReg()?.reverse = $1 })
        puzzle._bind(space, action: { $0.getLinearReg()?.space = $1 })
    }

    override func stateFromPuzzle(_ puzzle: PuzzlePiece) {
        super.stateFromPuzzle(puzzle)
        if let reg = puzzle.getLinearReg() {
            direction.input(value: reg.direction)
            format.input(value: reg.format)
            reverse.input(value: reg.reverse)
            space.input(value: reg.space)
        }
    }
    
    override func resume(_ param: [String: Any]?) {
        super.resume(param)
        if let node = LinearPuzzleStateModel.deserialize(from: param) {
            if let v = node.direction?.getDirection() { direction.state.value = v }
            if let v = node.format?.getFormat() { format.state.value = v }
            if let v = node.reverse { reverse.state.value = v }
            if let v = node.space { space.state.value = v }
        }
    }

    override func serialize() -> [String: Any]? {
        let node = LinearPuzzleStateModel.deserialize(from: super.serialize()) ?? LinearPuzzleStateModel()
        let defaultMeasure = getDefaultMeasure() as! LinearRegulator

        if direction.state.value != defaultMeasure.direction {
            node.direction = PuzzleDirection.from(direction.state.value)
        }

        if format.state.value != defaultMeasure.format {
            node.format = PuzzleFormat.from(format.state.value)
        }
        if reverse.state.value != defaultMeasure.reverse {
            node.reverse = reverse.state.value
        }
        if space.state.value != defaultMeasure.space {
            node.space = space.state.value
        }

        return node.toJSON()
    }

    override func getDefaultMeasure() -> Measure {
        return LinearRegulator(delegate: nil, sizeDelegate: nil, childrenDelegate: nil)
    }
}
