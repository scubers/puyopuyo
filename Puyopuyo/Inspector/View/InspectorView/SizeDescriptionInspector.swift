//
//  SizeDescriptionInspector.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//



class SizeDescriptionInspector: VBox, Stateful, Eventable {
    struct ViewState {
        var title: String
        var sizeType: SizeDescription.SizeType
        var fixedValue: CGFloat = 0
        var ratio: CGFloat = 0
        var add: CGFloat = 0
        var min: CGFloat = 0
        var max: CGFloat = 0
        var priority: CGFloat = 0
        var shrink: CGFloat = 0
        var grow: CGFloat = 0
        var aspectRatio: CGFloat = 0
    }

    let state = State<ViewState>(.init(title: "", sizeType: .wrap))
    let emitter = SimpleIO<SizeDescription>()

    init(title: String = "") {
        super.init(frame: .zero)
        self.state.value.title = title
    }

    @available(*, unavailable)
    required init?(coder argument: NSCoder) {
        fatalError()
    }

    override func buildBody() {
        attach {
            PropsSectionTitleView().attach($0)
                .text(binder.title)
                .width(.fill)

            HBox().attach($0) {
                PropsTitleView().attach($0)
                    .text("Type")

                VFlowGroup().attach($0) {
                    for type in [SizeDescription.SizeType.fixed, .wrap, .ratio, .aspectRatio] {
                        SelectorButton().attach($0)
                            .style(TapTransformStyle())
                            .setState(\.title, "\(type)")
                            .setState(\.selected, binder.sizeType.map { $0 == type })
                            .onTap(to: self) { this, _ in
                                this.state.value.sizeType = type
                                this.notify(value: type, keyPath: \.sizeType)
                            }
                    }
                }
                .space(4)
                .width(.fill)
            }
            .space(4)
            .width(.fill)
            .justifyContent(.center)

            VFlow(count: 2).attach($0) {
                PropsInputView().attach($0)
                    .setState(\.title, "Fix")
                    .setState(\.value, binder.fixedValue.distinct())
                    .visibility(binder.sizeType.map { ($0 == .fixed).py_visibleOrGone() })
                    .onEvent(to: self) { this, v in
                        this.notify(value: v, keyPath: \.fixedValue)
                    }

                PropsInputView().attach($0)
                    .setState(\.title, "Ratio")
                    .setState(\.value, binder.ratio.distinct())
                    .visibility(binder.sizeType.map { ($0 == .ratio).py_visibleOrGone() })
                    .onEvent(to: self) { this, v in
                        this.notify(value: v, keyPath: \.ratio)
                    }

                PropsInputView().attach($0)
                    .setState(\.title, "Aspect")
                    .setState(\.value, binder.aspectRatio.distinct())
                    .visibility(binder.sizeType.map { ($0 == .aspectRatio).py_visibleOrGone() })
                    .onEvent(to: self) { this, v in
                        this.notify(value: v, keyPath: \.aspectRatio)
                    }

                PropsInputView().attach($0)
                    .setState(\.title, "Shrink")
                    .setState(\.value, binder.shrink.distinct())
                    .visibility(binder.sizeType.map { ($0 == .wrap).py_visibleOrGone() })
                    .onEvent(to: self) { this, v in
                        this.notify(value: v, keyPath: \.shrink)
                    }

                PropsInputView().attach($0)
                    .setState(\.title, "Grow")
                    .setState(\.value, binder.grow.distinct())
                    .visibility(binder.sizeType.map { ($0 == .wrap).py_visibleOrGone() })
                    .onEvent(to: self) { this, v in
                        this.notify(value: v, keyPath: \.grow)
                    }

                PropsInputView().attach($0)
                    .setState(\.title, "Priority")
                    .setState(\.value, binder.priority.distinct())
                    .visibility(binder.sizeType.map { ($0 == .wrap).py_visibleOrGone() })
                    .onEvent(to: self) { this, v in
                        this.notify(value: v, keyPath: \.priority)
                    }

                PropsInputView().attach($0)
                    .setState(\.title, "Add")
                    .setState(\.value, binder.add.distinct())
                    .visibility(binder.sizeType.map { ($0 == .wrap).py_visibleOrGone() })
                    .onEvent(to: self) { this, v in
                        this.notify(value: v, keyPath: \.add)
                    }

                PropsInputView().attach($0)
                    .setState(\.title, "Max")
                    .setState(\.value, binder.max.distinct())
                    .visibility(binder.sizeType.map { ($0 == .wrap).py_visibleOrGone() })
                    .onEvent(to: self) { this, v in
                        this.notify(value: v, keyPath: \.max)
                    }

                PropsInputView().attach($0)
                    .setState(\.title, "Min")
                    .setState(\.value, binder.min.distinct())
                    .visibility(binder.sizeType.map { ($0 == .wrap).py_visibleOrGone() })
                    .onEvent(to: self) { this, v in
                        this.notify(value: v, keyPath: \.min)
                    }

                UIView().attach($0)
                    .width(.fill)
                    .visibility(binder.sizeType.map { ($0 != .wrap).py_visibleOrGone() })
            }
            .space(4)
            .width(.fill)
        }
        .justifyContent(.left)
        .padding(all: 8)
        .space(8)
        .backgroundColor(.secondarySystemGroupedBackground)
    }

    func notify<V>(value: V, keyPath: WritableKeyPath<ViewState, V>) {
        var state = self.state.value
        state[keyPath: keyPath] = value
        var result: SizeDescription
        switch state.sizeType {
        case .fixed:
            result = .fix(state.fixedValue)
        case .ratio:
            result = .ratio(state.ratio)
        case .wrap:
            result = .wrap(add: state.add, min: state.min, max: state.max, priority: state.priority, shrink: state.shrink, grow: state.grow)
        case .aspectRatio:
            result = .aspectRatio(state.aspectRatio)
        }

        emit(result)
    }

    func createNumberInputGroup(title: String, data: Outputs<String>, event: Inputs<String>) -> UIView {
        HBox().attach {
            PropsTitleView().attach($0)
                .text(title)
                .width(.fill)
                .textAlignment(.center)
                .margin(vert: 8)

            UITextField().attach($0)
                .text(data)
                .onControlEvent(.editingChanged, event.asInput { $0.text ?? "" })
                .size(.fill, .fill)
                .cornerRadius(4)
                .clipToBounds(true)
                .borderWidth(1)
                .borderColor(UIColor.separator)
                .margin(vert: 4)
        }
        .space(4)
        .justifyContent(.center)
        .size(.fill, 40)
        .view
    }
}
