//
//  SingleSelectVC.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


import UIKit

public func findViewController(for responder: UIResponder?) -> UIViewController? {
    if let responder = responder as? UIViewController {
        return responder
    }
    return findViewController(for: responder?.next)
}

public func findTopViewController(for responder: UIResponder?) -> UIViewController? {
    findTopViewController(for: findViewController(for: responder))
}

func findTopViewController(for vc: UIViewController?) -> UIViewController? {
    guard let vc = vc else {
        return nil
    }

    if let vc = vc as? UINavigationController {
        if vc.viewControllers.isEmpty {
            return vc
        }
        return findTopViewController(for: vc.viewControllers.last)
    } else if let vc = vc as? UITabBarController {
        if vc.viewControllers?.isEmpty ?? true {
            return vc
        }
        return findTopViewController(for: vc.selectedViewController)
    } else {
        return vc
    }
}

func presentSelection<T>(from: UIResponder?, _ selection: [Selection<T>], selected: Int, result: Inputs<Int>) {
    findTopViewController(for: findViewController(for: from))?.present(SingleSelectVC(selection: selection, selected: selected, result: result), animated: true)
}

struct Selection<T> {
    let title: String
    let value: T
}

class SingleSelectVC<T>: UIViewController {
    init(selection: [Selection<T>], selected: Int, result: Inputs<Int>) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
        self.selection.value = selection
        self.selected.value = selected
    }

    let selection = State([Selection<T>]())
    let selected = State<Int>(0)
    let result: Inputs<Int>

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var contentView: ViewDisplayable?

    override func viewDidLoad() {
        super.viewDidLoad()

        modalPresentationStyle = .popover

        func selectedState(for index: Outputs<Int>) -> Outputs<Bool> {
            Outputs.combine(index, selected).map { $0 == $1 }
        }

        let this = WeakableObject(value: self)

        contentView = VBox().attach(view) {
            Outputs.combine(selection, selected).safeBind(to: $0) { vbox, value in
                vbox.layoutChildren.forEach { $0.removeFromSuperBox() }

                for (index, element) in value.0.enumerated() {
                    HBox().attach(vbox) {
                        UIView().attach($0)
                            .backgroundColor(.systemPink)
                            .size(10, 10)
                            .cornerRadius(5)
                            .clipToBounds(true)
                            .visibility((index == value.1).py_visibleOrNot())

                        UILabel().attach($0)
                            .text(element.title)
                            .textColor(UIColor.label)
                    }
                    .justifyContent(.center)
                    .onTap {
                        this.value?.selected.value = index
                        let result = this.value?.result
                        this.value?.dismiss(animated: true, completion: {
                            result?.input(value: index)
                        })
                    }
                    .space(4)
                    .padding(all: 8)
                    .width(.fill)
                }
            }
        }
        .size(200, .wrap)

        preferredContentSize = contentView?.dislplayView.sizeThatFits(.zero) ?? CGSize(width: 100, height: 100)
    }
}
