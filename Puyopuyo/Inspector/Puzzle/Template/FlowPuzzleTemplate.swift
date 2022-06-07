//
//  LinearPuzzleTemplate.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/29.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation



class FlowBoxPuzzleTemplate: PuzzleTemplate {
    var templateId: String { "template.flowBox" }
    var name: String { "FlowBox" }
    var containerType: PuzzleContainerType { .box }

    var builderHandler: BuildPuzzleHandler { FlowBuildPuzzleHandler(isGroup: false) }
}

class FlowGroupPuzzleTemplate: PuzzleTemplate {
    var templateId: String { "template.flowGroup" }
    var name: String { "FlowGroup" }
    var containerType: PuzzleContainerType { .group }

    var builderHandler: BuildPuzzleHandler { FlowBuildPuzzleHandler(isGroup: true) }
}

struct FlowBuildPuzzleHandler: BuildPuzzleHandler {
    let isGroup: Bool

    func createPuzzle() -> PuzzlePiece {
        isGroup ? FlowGroup() : FlowBox()
    }

    func createState() -> PuzzleStateProvider {
        let provider = FlowPuzzleStateProvider()
        provider.padding.specificValue = .init(top: 8, left: 8, bottom: 8, right: 8)
        return provider
    }

    func initializeCode() -> String {
        isGroup ? "FlowGroup()" : "FlowBox()"
    }
}

class FlowPuzzleStateModel: LinearPuzzleStateModel {
    var runFormat: PuzzleFormat?
    var arrange: Int?
    var itemSpace: CGFloat?
    var runSpace: CGFloat?
}

class FlowPuzzleStateProvider: LinearPuzzleStateProvider {
    lazy var runFormat = PuzzleState(title: "RunFormat", value: (defaultMeasure as! FlowRegulator).runFormat)
    lazy var arrange = PuzzleState(title: "Arrange", value: (defaultMeasure as! FlowRegulator).arrange)
    lazy var itemSpace = PuzzleState(title: "ItemSpace", value: (defaultMeasure as! FlowRegulator).itemSpace)
    lazy var runSpace = PuzzleState(title: "RunSpace", value: (defaultMeasure as! FlowRegulator).runSpace)

    override var states: [IPuzzleState] {
        super.states + [arrange, runFormat, itemSpace, runSpace]
    }

    override func generateCode() -> [String] {
        var codes = super.generateCode()
        if let model = FlowPuzzleStateModel.deserialize(from: serialize()) {
            if let v = model.runFormat?.getFormat() { codes.append(".runFormat(\(v.genCode()))") }
            if let v = model.arrange { codes.append(".arrange(\(v))") }
            if let v = model.itemSpace { codes.append(".itemSpace(\(v))") }
            if let v = model.runSpace { codes.append(".runSpace(\(v))") }
        }
        return codes
    }

    override func bindState(to puzzle: PuzzlePiece) {
        super.bindState(to: puzzle)
        puzzle._bind(runFormat, action: { $0.getFlowReg()?.runFormat = $1 })
        puzzle._bind(arrange, action: { $0.getFlowReg()?.arrange = $1 })
        puzzle._bind(itemSpace, action: { $0.getFlowReg()?.itemSpace = $1 })
        puzzle._bind(runSpace, action: { $0.getFlowReg()?.runSpace = $1 })
    }

    override func stateFromPuzzle(_ puzzle: PuzzlePiece) {
        super.stateFromPuzzle(puzzle)
        if let reg = puzzle.getFlowReg() {
            runFormat.input(value: reg.runFormat)
            arrange.input(value: reg.arrange)
            itemSpace.input(value: reg.itemSpace)
            runSpace.input(value: reg.runSpace)
        }
    }

    override func resume(_ param: [String: Any]?) {
        super.resume(param)
        if let node = FlowPuzzleStateModel.deserialize(from: param) {
            if let v = node.runFormat?.getFormat() { runFormat.state.value = v }
            if let v = node.arrange { arrange.state.value = v }
            if let v = node.itemSpace { itemSpace.state.value = v }
            if let v = node.runSpace { runSpace.state.value = v }
        }
    }

    override func serialize() -> [String: Any]? {
        let node = FlowPuzzleStateModel.deserialize(from: super.serialize()) ?? FlowPuzzleStateModel()
        let defaultMeasure = getDefaultMeasure() as! FlowRegulator

        if runFormat.state.value != defaultMeasure.runFormat {
            node.runFormat = PuzzleFormat.from(runFormat.state.value)
        }
        if arrange.state.value != defaultMeasure.arrange {
            node.arrange = arrange.state.value
        }
        if itemSpace.state.value != defaultMeasure.itemSpace {
            node.itemSpace = itemSpace.state.value
        }
        if runSpace.state.value != defaultMeasure.runSpace {
            node.runSpace = runSpace.state.value
        }

        return node.toJSON()
    }

    override func getDefaultMeasure() -> Measure {
        return FlowRegulator(delegate: nil, sizeDelegate: nil, childrenDelegate: nil)
    }
}
