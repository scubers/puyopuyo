//
//  AlignmentInspector.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation


class AlignmentInspector: VBox, Stateful, Eventable {
    struct ViewState {
        var title: String
        var alignment: Alignment
    }

    let state = State(ViewState(title: "", alignment: .none))

    let emitter = SimpleIO<Alignment>()

    override func buildBody() {
        let this = WeakableObject(value: self)
        attach {
            PropsSectionTitleView().attach($0)
                .text(binder.title)
                .width(.fill)

            VFlow(count: 2).attach($0) {
                for target in [Alignment.top, .left, .bottom, .right, .vertCenter, .horzCenter] {
                    createButton(title: "\(target)", target: target, selected: binder.alignment.asOutput(), onClick: Inputs {
                        this.value?.notifyToggle($0)
                    }).attach($0)
                }
            }
            .space(4)
            .width(.fill)
        }
        .justifyContent(.left)
        .padding(all: 8)
        .space(8)
        .backgroundColor(.secondarySystemGroupedBackground)
        .width(.fill)
    }

    func notifyToggle(_ alignment: Alignment) {
        var selected = state.value.alignment
        if selected.contains(alignment) {
            selected.remove(alignment)
        } else {
            switch alignment {
            case .left: selected.remove([.right, .horzCenter])
            case .right: selected.remove([.left, .horzCenter])
            case .top: selected.remove([.bottom, .vertCenter])
            case .bottom: selected.remove([.top, .vertCenter])
            case .horzCenter: selected.remove([.left, .right])
            case .vertCenter: selected.remove([.top, .bottom])
            default: break
            }
            selected.insert(alignment)
        }
        state.value.alignment = selected

        emit(selected)
    }
}

private func createButton(title: String, target: Alignment, selected: Outputs<Alignment>, onClick: Inputs<Alignment>) -> UIView {
    SelectorButton().attach()
        .setState(\.title, title)
        .setState(\.selected, selected.map { $0.contains(target) })
        .onTap(onClick.asInput { _ in target })
        .size(.fill, 40)
        .style(TapTransformStyle())
        .view
}
