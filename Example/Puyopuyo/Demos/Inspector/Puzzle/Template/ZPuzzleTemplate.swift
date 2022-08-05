//
//  LinearPuzzleTemplate.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/29.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation



class ZBoxPuzzleTemplate: PuzzleTemplate {
    var templateId: String { "template.zbox" }

    var name: String { "ZBox" }

    var containerType: PuzzleContainerType { .box }

    var builderHandler: BuildPuzzleHandler { ZBuildPuzzleHandler(isGroup: false) }
}

class ZGroupPuzzleTemplate: PuzzleTemplate {
    var templateId: String { "template.zgroup" }
    var name: String { "ZGroup" }

    var containerType: PuzzleContainerType { .group }

    var builderHandler: BuildPuzzleHandler { ZBuildPuzzleHandler(isGroup: true) }
}

struct ZBuildPuzzleHandler: BuildPuzzleHandler {
    let isGroup: Bool

    func createPuzzle() -> PuzzlePiece {
        isGroup ? ZGroup() : ZBox()
    }

    func createState() -> PuzzleStateProvider {
        let provider = ZPuzzleStateProvider()
        provider.padding.specificValue = .init(top: 8, left: 8, bottom: 8, right: 8)
        return provider
    }

    func initializeCode() -> String {
        isGroup ? "ZGroup()" : "ZBox()"
    }
}

class ZPuzzleStateProvider: BoxPuzzleStateProvider {
    override func getDefaultMeasure() -> Measure {
        return ZRegulator(delegate: nil, sizeDelegate: nil, childrenDelegate: nil)
    }
}
