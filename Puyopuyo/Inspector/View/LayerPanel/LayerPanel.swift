//
//  LayerPanel.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation


class LayerPanel: ZBox {
    let store: BuilderStore
    init(store: BuilderStore) {
        self.store = store
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder argument: NSCoder) {
        fatalError()
    }

    override func buildBody() {
        let empty = store.root.map { $0 == nil }.debounce(interval: 0.1)

        let this = WeakableObject<LayerPanel>(value: self)

        let selected = store.selected
        attach {
            VBox().attach($0) {
                SettingPanel(store: store).attach($0)
                    .width(.fill)
                    .margin(top: $0.py_safeArea().binder.top)
                
                RecycleBox(
                    sections: [
                        ListRecycleSection(items: items.asOutput(), cell: { o, i in
                            HBox().attach {
                                UILabel().attach($0)
                                    .text(o.data.node.title)
                                    .width(.fill)

                                UIButton(type: .contactAdd).attach($0)
                                    .onControlEvent(.touchUpInside, Inputs { _ in
                                        i.inContext { info in
                                            this.value?.addChild(for: info.data.node)
                                        }
                                    })
                                    .visibility(o.data.node.template.containerType.map { ($0 != .none).py_visibleOrGone() })

                                UIButton().attach($0)
                                    .image(UIImage(systemName: "trash"))
                                    .userInteractionEnabled(true)
                                    .onTap {
                                        i.inContext { info in
                                            this.value?.removeItem(info.data.node)
                                        }
                                    }
                            }
                            .backgroundColor(Outputs.combine(selected, o.data.node).map { v1, v2 -> UIColor in
                                if v1 === v2 {
                                    return UIColor.systemBlue.withAlphaComponent(0.2)
                                }
                                return UIColor.clear
                            })
                            .padding(all: 4)
                            .padding(left: o.data.depth.map { CGFloat($0) * 8 + 4 })
                            .margin(bottom: 1)
                            .justifyContent(.center)
                            .space(4)
                            .width(o.contentSize.width)
                        }, didSelect: { info in
                            this.value?.store.toggleSelect(info.data.node)
                        })
                    ].asOutput()
                )
                .attach($0)
                .size(.fill, .fill)
                .visibility(empty.map { (!$0).py_visibleOrNot() })

                HGroup().attach($0) {
                    SelectorButton().attach($0)
                        .state(.init(selected: false, title: "Undo"))
                        .width(.fill)
                        .onTap(to: self) { this, _ in
                            this.store.undo()
                        }
                    SelectorButton().attach($0)
                        .width(.fill)
                        .state(.init(selected: false, title: "Redo"))
                        .onTap(to: self) { this, _ in
                            this.store.redo()
                        }
                }
                .space(8)
                .padding(all: 8)
                .width(.fill)
            }
            .size(.fill, .fill)
            .space(1)

            SelectorButton().attach($0)
                .state(.init(selected: false, title: "Click to add"))
                .alignment(.center)
                .visibility(empty.map { $0.py_visibleOrGone() })
                .onTap(to: self) { this, _ in
                    this.chooseRootBox()
                }
        }
        .backgroundColor(.secondarySystemGroupedBackground)
    }

    var items: Outputs<[LayerPanelItem]> {
        store.root.map { root in
            guard let root = root else {
                return []
            }
            var items = [LayerPanelItem]()
            func deep(node: BuilderPuzzleItem, depth: Int) {
                items.append(.init(depth: depth, node: node))
                node.children.forEach { child in
                    deep(node: child, depth: depth + 1)
                }
            }
            deep(node: root, depth: 0)
            return items
        }
    }

    func chooseRootBox() {
        let vc = NodeSelectVC(isRoot: true) {
            self.store.replaceRoot(BuilderPuzzleItem(template: $0))
        }
        findTopViewController(for: self)?.present(UINavigationController(rootViewController: vc), animated: true)
    }

    func addChild(for parent: BuilderPuzzleItem) {
        let vc = NodeSelectVC(isRoot: false) {
            self.store.append(item: BuilderPuzzleItem(template: $0), for: parent)
        }
        findTopViewController(for: self)?.present(UINavigationController(rootViewController: vc), animated: true)
    }

    func removeItem(_ item: BuilderPuzzleItem) {
        let controller = UIAlertController(title: "Remove?", message: nil, preferredStyle: .alert)
        controller.addAction(.init(title: "No", style: .default))
        controller.addAction(.init(title: "Yes", style: .destructive, handler: { _ in
            self.store.removeItem(item)
        }))
        findTopViewController(for: self)?.present(controller, animated: true)
    }
}

struct LayerPanelItem {
    var depth: Int
    var node: BuilderPuzzleItem
}
