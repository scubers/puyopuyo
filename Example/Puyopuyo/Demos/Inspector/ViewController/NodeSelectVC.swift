//
//  NodeSelectVC.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


import UIKit

class NodeSelectVC: UIViewController {
    private let isRoot: Bool

    private let onResult: (PuzzleTemplate) -> Void

    init(isRoot: Bool, onResult: @escaping (PuzzleTemplate) -> Void = { _ in }) {
        self.isRoot = isRoot
        self.onResult = onResult
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    let state = State(PuzzleManager.shared.templates)
    
    @objc private func back() {
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Puzzle"

        let this = WeakableObject(value: self)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(back))

        if isRoot {
            state.value = state.value.filter { $0.containerType == .box }
        }

        ZBox().attach(view) {
            RecycleBox(
                sections: [
                    ListRecycleSection(
                        insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                        lineSpacing: 16,
                        items: state.asOutput(), cell: { o, _ in
                            ZBox().attach {
                                UILabel().attach($0)
                                    .fontSize(20, weight: .bold)
                                    .text(o.data.name)
                            }
                            .backgroundColor(.secondarySystemGroupedBackground)
                            .justifyContent(.center)
                            .width(o.contentSize.width.map { SizeDescription.fix($0 / 3 - 8) })
                            .height(.aspectRatio(3))
                        },
                        didSelect: { info in
                            let result = this.value?.onResult

                            this.value?.dismiss(animated: true, completion: {
                                result?(info.data)
                            })
                        }
                    ),
                ].asOutput()
            )
            .attach($0)
            .size(.fill, .fill)
        }
        .size(.fill, .fill)
        .backgroundColor(.systemGroupedBackground)
    }
}
