//
//  UIViewPuzzleTemplate.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/29.
//  Copyright © 2022 CocoaPods. All rights reserved.
//



class UIViewPuzzleTemplate: PuzzleTemplate {
    var templateId: String { "template.uiview" }

    var name: String { "UIView" }

    var containerType: PuzzleContainerType { .none }

    var builderHandler: BuildPuzzleHandler { UIViewBuildPuzzleHandler() }
}

struct UIViewBuildPuzzleHandler: BuildPuzzleHandler {
    func createPuzzle() -> PuzzlePiece {
        UIView()
    }

    func createState() -> PuzzleStateProvider {
        UIViewPuzzleStateProvider()
    }
    
    func initializeCode() -> String {
        "UIView()"
    }
}

class UIViewPuzzleStateProvider: BasePuzzleStateProvider {}
