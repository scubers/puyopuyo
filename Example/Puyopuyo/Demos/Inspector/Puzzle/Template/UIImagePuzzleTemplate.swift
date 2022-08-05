//
//  UIImagePuzzleTemplate.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/6/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//



class UIImagePuzzleTemplate: PuzzleTemplate {
    var templateId: String { "template.uiimageview" }

    var name: String { "UIImageView" }

    var containerType: PuzzleContainerType { .none }

    var builderHandler: BuildPuzzleHandler { UIImageBuildPuzzleHandler() }
}

struct UIImageBuildPuzzleHandler: BuildPuzzleHandler {
    func createPuzzle() -> PuzzlePiece {
        UIImageView()
    }

    func createState() -> PuzzleStateProvider {
        UIImagePuzzleStateProvider()
    }

    func initializeCode() -> String {
        "UIImageView()"
    }
}

class UIImagePuzzleStateModel: BasePuzzleStateModel {
    var url: String?
    var image: UIImage?
}

class UIImagePuzzleStateProvider: BasePuzzleStateProvider {
    let url = PuzzleState(title: "ImageUrl", value: "")
    let image = PuzzleState<UIImage?>(title: "Image", value: nil)

    override var states: [IPuzzleState] {
        [url] + super.states
    }

    override func bindState(to puzzle: PuzzlePiece) {
        super.bindState(to: puzzle)
        if let puzzle = puzzle as? UIImageView {
            puzzle.attach()
                .viewUpdate(on: url.distinct().then(downloadImage(url:)).filter { $0 != nil }) { $0.image = $1 }
                .viewUpdate(on: image) { $0.image = $1 }
        }
    }

    override func stateFromPuzzle(_ puzzle: PuzzlePiece) {
        super.stateFromPuzzle(puzzle)
        if let puzzle = puzzle as? UIImageView {
            image.input(value: puzzle.image)
        }
    }

    override func resume(_ param: [String: Any]?) {
        super.resume(param)

        if let node = UIImagePuzzleStateModel.deserialize(from: param) {
            url.state.value = node.url ?? ""
        }
    }

    override func serialize() -> [String: Any]? {
        let node = UIImagePuzzleStateModel.deserialize(from: super.serialize()) ?? UIImagePuzzleStateModel()
        node.url = url.specificValue
        return node.toJSON()
    }
}
