//
//  BuilderPuzzleItem.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/6/4.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

class BuilderPuzzleItem {
    var id = UUID().description
    var title: String = ""
    var template: PuzzleTemplate
    var children: [BuilderPuzzleItem] = []
    lazy var provider: PuzzleStateProvider = template.builderHandler.createState()
    weak var parent: BuilderPuzzleItem?
    weak var puzzlePiece: PuzzlePiece? {
        didSet {
            if let puzzlePiece = puzzlePiece {
                title = "\(type(of: puzzlePiece))"
            } else {
                title = "Empty"
            }
        }
    }

    init(template: PuzzleTemplate) {
        self.template = template
    }
}

// MARK: - Action

extension BuilderPuzzleItem {
    func append(child: BuilderPuzzleItem) {
        child.removeFromParent()
        children.append(child)
        child.parent = self
    }

    func removeFromParent() {
        parent?.children.removeAll(where: { $0 === self })
        parent = nil
    }
}

// MARK: - Code

extension BuilderPuzzleItem {
    func generateCode(_ depth: Int) -> [String] {
        var codes = [String]()
        var startCodes = template.builderHandler.initializeCode()
        startCodes += ".attach\(depth == 0 ? "" : "($0)")"
        if !children.isEmpty {
            startCodes += " {"
        }

        codes.append(startCodes)

        children.forEach { child in
            codes.append(contentsOf: child.generateCode(depth + 1).tab(1))
        }

        if !children.isEmpty {
            codes.append("}")
        }

        codes.append(contentsOf: provider.generateCode().tab(children.isEmpty ? 1 : 0))
        codes.append("")
        return codes
    }
}

extension Array where Element == String {
    func tab(_ depth: Int) -> [String] {
        let tabString = (0 ..< depth).reduce("") { r, _ in r + "    " }
        return map { "\(tabString)\($0)" }
    }
}

// MARK: - Serialization

extension BuilderPuzzleItem {
    func serialize() -> [String: Any] {
        var dict = [String: Any]()
        dict["templateId"] = template.templateId
        if !children.isEmpty {
            dict["children"] = children.map { $0.serialize() }
        }
        dict.merge(provider.serialize() ?? [:], uniquingKeysWith: { $1 })
        return dict
    }

    static func deserialize(_ param: [String: Any]) -> BuilderPuzzleItem? {
        guard let id = param["templateId"] as? String,
              let template = PuzzleManager.shared.templates.filter({ $0.templateId == id }).first
        else {
            return nil
        }
        let item = BuilderPuzzleItem(template: template)
        if let children = param["children"] as? [[String: Any]] {
            children.forEach {
                if let child = BuilderPuzzleItem.deserialize($0) {
                    item.append(child: child)
                }
            }
        }
        item.provider.resume(param)
        return item
    }
}
