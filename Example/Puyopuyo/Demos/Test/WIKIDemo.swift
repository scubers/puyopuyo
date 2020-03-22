//
//  WIKIDemo.swift
//  Puyopuyo_Example
//
//  Created by 王俊仁 on 2020/3/22.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Puyopuyo

class Demo {
    func de() {
        let view = UIView()

        VBox().attach(view) {
            UILabel().attach($0)
                .text("i am a text")
                .size(.wrap(add: 20), 100)

            UIButton().attach($0)
                .text("i am a button")
                .size(.fill, .wrap)
        }

        let textState = State("")
        HBox().attach(view) {
            UILabel().attach($0)
                .text(textState)

            UIButton().attach($0)
                .text("i am a button")
                .onEvent(.touchUpInside, SimpleInput { _ in
                    print("button clicked !!! ")
                })
        }
        textState.input(value: "i am a new text")
    }
}

class CustomView: UIView, Stateful, Eventable {
    struct ViewState {
        var title: String?
        var count = 1
    }

    enum Event {
        case onClick
    }

    var viewState = State(ViewState())
    var eventProducer = SimpleIO<Event>()
    override init(frame: CGRect) {
        super.init(frame: frame)
        attach {
            VBox().attach($0) {
                UILabel().attach($0)
                    .text(self._state.map { $0.title })
                UILabel().attach($0)
                    .text(self._state.map { $0.count.description })

                UIButton().attach($0)
                    .onTap(to: self) { this, _ in
                        this.emmit(.onClick)
                    }
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func test() {
        let state = State(CustomView.ViewState())
        VBox().attach {
            CustomView().attach($0)
                .viewState(state)
                .onEventProduced(SimpleInput { event in
                    switch event {
                    case .onClick:
                        print("clicked~~~")
                    }
                })
        }
        .animator(Animators.default)
        state.value.title = "nwe text"
        state.value.count = 99
        
        UILabel().attach()
            .userInteractionEnabled(true)
            .style(TapRippleStyle())
            .style(TapScaleStyle())
            .styles(CustomStyles.titleStyle())
        
        let value = State<Float>(0)
        UISlider().attach().value(value)
            .onBoundsChanged(SimpleInput { frame in
            })
            .onFrameChanged(SimpleInput { frame in
            })
            .onCenterChanged(SimpleInput { frame in
            })
            .frame(x: 0, y: 0, w: 100, h: 100)
        value.input(value: 0.5)
        
    }
}

class CustomStyles {
    static func titleStyle() -> [Style] {
        [
            UIFont.systemFont(ofSize: 16, weight: .bold),
            TextColorStyle(value: .red, state: .normal),
            TextAlignmentStyle(value: .right, state: .normal),
            (\UIView.layer.cornerRadius).getStyle(with: 12),
        ]
    }
}
