//
//  BuilderStore.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

class BuilderStore {
    static func store(with puzzle: PuzzlePiece? = nil) -> BuilderStore {
        let store = BuilderStore()
        if let puzzle = puzzle {
            store.analyze(puzzle: puzzle)
        }
        return store
    }

    private let bag = Disposers.createBag()

    private let history = BuilderHistory<String?>(count: 100, first: nil)

    let root = State<BuilderPuzzleItem?>(nil)

    let selected = State<BuilderPuzzleItem?>(nil)

    let canvasSize = State(CGSize(width: 200, height: 200))

    let colorizeSetting = State(value: true)

    func toggleSelect(_ item: BuilderPuzzleItem) {
        if item === selected.value {
            selected.input(value: nil)
        } else {
            selected.input(value: item)
        }
    }
}

// MARK: - Structure change

extension BuilderStore {
    private func resetRoot(_ node: BuilderPuzzleItem?) {
        root.value = node
        selected.value = nil
    }

    func replaceRoot(_ node: BuilderPuzzleItem?) {
        defer { record() }
        resetRoot(node)
    }

    func removeItem(_ item: BuilderPuzzleItem) {
        defer { record() }
        item.removeFromParent()
        if item === selected.value {
            selected.value = nil
        }
        if root.value === item {
            root.value = nil
        } else {
            root.resend()
        }
    }

    func append(item: BuilderPuzzleItem, for parent: BuilderPuzzleItem) {
        defer { record() }
        parent.append(child: item)
        root.resend()
    }

    func setCanvasSize(width: CGFloat? = nil, height: CGFloat? = nil) {
        let size = CGSize(width: width ?? canvasSize.value.width, height: height ?? canvasSize.value.height)
        canvasSize.value = size
        record()
    }
}

// MARK: - History

extension BuilderStore {
    func record() {
        history.push(exportJson(prettyPrinted: false))
    }

    var canUndo: Bool { history.canUndo }

    var canRedo: Bool { history.canRedo }

    func undo() {
        guard canUndo else { return }
        history.undo()
        resetRoot(buildWithJson(history.currentState))
    }

    func redo() {
        guard canRedo else { return }
        history.redo()
        resetRoot(buildWithJson(history.currentState))
    }
}

// MARK: - Builder generator

extension BuilderStore {
    func buildRoot() -> PuzzlePiece? {
        if let root = root.value {
            return buildBoxLayoutNode(root)
        }
        return nil
    }

    func buildBoxLayoutNode(_ node: BuilderPuzzleItem) -> PuzzlePiece? {
        let puzzle = node.template.builderHandler.createPuzzle()
        node.provider.bindState(to: puzzle)
        node.puzzlePiece = puzzle

        if let puzzle = puzzle as? UIView {
            puzzle.attach()
                .userInteractionEnabled(true)
                .borderWidth(1)
                .borderColor(selected.map { $0 === node }.map {
                    $0 ? UIColor.systemPink : .clear
                })
                .onTap(to: self) { [weak node] this, _ in
                    if let node = node {
                        this.toggleSelect(node)
                    }
                }
                .attach {
                    let longPress = UILongPressGestureRecognizer()

                    longPress.py_addAction { [weak self] g in
                        if g.state == .began {
                            self?.analyze(puzzle: g.view!)
                        }
                    }

                    $0.view.addGestureRecognizer(longPress)
                }
        }

        // children
        if let container = puzzle as? BoxLayoutContainer {
            node.children.forEach { child in
                if let childNode = buildBoxLayoutNode(child) {
                    container.addLayoutNode(childNode)
                }
            }
        }

        if let view = puzzle.layoutNodeView, colorizeSetting.value {
            view.backgroundColor = Helper.randomColor()
        }

        return puzzle
    }
}

// MARK: - Export json

extension BuilderStore {
    func exportJson(prettyPrinted: Bool) -> String? {
        var dict = [String: Any]()
        dict["width"] = canvasSize.value.width
        dict["height"] = canvasSize.value.height
        if let root = root.value?.serialize() {
            dict["root"] = root
        }
        return Helper.toJson(dict, prettyPrinted: prettyPrinted)
    }

    func buildWithJson(_ json: String?) -> BuilderPuzzleItem? {
        guard let value = Helper.fromJson(json) else {
            return nil
        }
        let width = (value["width"] as? CGFloat) ?? 200
        let height = (value["height"] as? CGFloat) ?? 200
        canvasSize.value = .init(width: width, height: height)

        if let root = value["root"] as? [String: Any], let item = BuilderPuzzleItem.deserialize(root) {
            return item
        }

        return nil
    }

    func exportCode() -> String {
        if let codes = root.value?.generateCode(0) {
            return codes.map { "\($0)\n" }.joined(separator: "")
        }
        return ""
    }
}

// MARK: - Analyzer

extension BuilderStore {
    private func scan(_ puzzle: PuzzlePiece) -> BuilderPuzzleItem {
        let template = PuzzleManager.shared.template(for: puzzle)
        let item = BuilderPuzzleItem(template: template)
        item.provider.stateFromPuzzle(puzzle)

        if let piece = puzzle as? BoxLayoutContainer {
            piece.layoutChildren.forEach { node in
                if let node = node as? PuzzlePiece {
                    item.append(child: scan(node))
                }
            }
        }
        return item
    }

    func analyze(puzzle: PuzzlePiece) {
        let item = scan(puzzle)
        replaceRoot(item)
    }
}
