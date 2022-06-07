//
//  UIViewPuzzleTemplate.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/29.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

class UILabelPuzzleTemplate: PuzzleTemplate {
    var templateId: String { "template.uilabel" }

    var name: String { "UILabel" }

    var containerType: PuzzleContainerType { .none }

    var builderHandler: BuildPuzzleHandler { UILabelBuildPuzzleHandler() }
}

struct UILabelBuildPuzzleHandler: BuildPuzzleHandler {
    func createPuzzle() -> PuzzlePiece {
        UILabel()
    }

    func createState() -> PuzzleStateProvider {
        UILabelPuzzleStateProvider()
    }

    func initializeCode() -> String {
        "UILabel()"
    }
}

class UILabelPuzzleStateModel: BasePuzzleStateModel {
    var text: String?
    var age: Int?
}

class UILabelPuzzleStateProvider: BasePuzzleStateProvider {
    let text = PuzzleState(title: "Text", value: "Demo")

    override var states: [IPuzzleState] {
        [text] + super.states
    }

    override func generateCode() -> [String] {
        var codes = super.generateCode()
        if let model = UILabelPuzzleStateModel.deserialize(from: serialize()) {
            if let v = model.text { codes.append(".text(\"\(v)\")") }
        }
        return codes
    }

    override func bindState(to puzzle: PuzzlePiece) {
        super.bindState(to: puzzle)
        if let puzzle = puzzle as? UILabel {
            puzzle.attach()
                .text(text)
        }
    }

    override func stateFromPuzzle(_ puzzle: PuzzlePiece) {
        super.stateFromPuzzle(puzzle)
        if let puzzle = puzzle as? UILabel {
            text.input(value: puzzle.text ?? "")
        }
    }

    override func resume(_ param: [String: Any]?) {
        super.resume(param)

        if let node = UILabelPuzzleStateModel.deserialize(from: param) {
            text.state.value = node.text ?? ""
        }
    }

    override func serialize() -> [String: Any]? {
        let node = UILabelPuzzleStateModel.deserialize(from: super.serialize()) ?? UILabelPuzzleStateModel()
        node.text = text.specificValue
        return node.toJSON()
    }
}
