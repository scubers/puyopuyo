//
//  PuzzleTemplate.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/29.
//  Copyright © 2022 CocoaPods. All rights reserved.
//



class PuzzleManager {
    private init() {}

    static let shared = PuzzleManager()

    private(set) var templates: [PuzzleTemplate] = [
        UIViewPuzzleTemplate(),
        UILabelPuzzleTemplate(),
        UIImagePuzzleTemplate(),
        LinearBoxPuzzleTemplate(),
        FlowBoxPuzzleTemplate(),
        ZBoxPuzzleTemplate(),
        LinearGroupPuzzleTemplate(),
        FlowGroupPuzzleTemplate(),
        ZGroupPuzzleTemplate(),
    ]

    func addTemplate(_ template: PuzzleTemplate) {
        templates.append(template)
    }

    func template(for piece: PuzzlePiece) -> PuzzleTemplate {
        switch piece {
        case is ZGroup: return ZGroupPuzzleTemplate()
        case is FlowGroup: return FlowGroupPuzzleTemplate()
        case is LinearGroup: return LinearGroupPuzzleTemplate()

        case is ZBox: return ZBoxPuzzleTemplate()
        case is FlowBox: return FlowBoxPuzzleTemplate()
        case is LinearBox: return LinearBoxPuzzleTemplate()

        case is UILabel: return UILabelPuzzleTemplate()
        case is UIImageView: return UIImagePuzzleTemplate()
        case is UIView: return UIViewPuzzleTemplate()

        default: fatalError()
        }
    }
}
