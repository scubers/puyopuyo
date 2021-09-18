//
//  ChatVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/9/18.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class ChatVC: BaseVC, UICollectionViewDelegateFlowLayout {
    let messages = State<[Message]>((0 ..< 5).map { _ in Message() })
    var box: RecycleBox!

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.showLast()
        }

        Outputs.listen(to: UIResponder.keyboardWillShowNotification).safeBind(to: self) { this, notice in
            let rect = notice.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            this.additionalSafeAreaPadding.value.bottom = rect.height - this.view.safeAreaInsets.bottom
        }

        Outputs.listen(to: UIResponder.keyboardWillHideNotification).safeBind(to: self) { this, _ in
            this.additionalSafeAreaPadding.value.bottom = 0
        }
    }

    override func configView() {
        let this = WeakCatcher(value: self)
        vRoot.attach {
            box = RecycleBox(
                enableDiff: true,
                sections: [
                    DataRecycleSection(
                        items: messages.asOutput(),
                        differ: { $0.chatId.description },
                        cell: { o, _ in
                            MessageView().attach()
                                .viewState(o.map(\.data))
                                .width(.fill)
                                .onEvent { e in
                                    switch e {
                                    case .tapIcon:
                                        this.value?.navigationController?.pushViewController(FeedVC(), animated: true)
                                    }
                                }
                                .view
                        }
                    )
                ].asOutput()
            )
            .attach($0)
            .bind(keyPath: \.showsVerticalScrollIndicator, false)
            .size(.fill, .fill)
            .setDelegate(self)
            .view

            MessageInputView().attach($0)
                .size(.fill, 60)
                .onEvent(to: self) { this, v in
                    switch v {
                    case .send(let text):
                        this.addMessage(message: text, isSelf: true)
                    case .add:
                        this.addMessage()
                    }
                }
        }
        .animator(Animators.default)
    }

    private func addMessage(message: String? = nil, isSelf: Bool = Util.random(array: [true, false])) {
        messages.value.append(Message(content: message ?? Contents().get(), isSelf: isSelf))
        showLast()
    }

    private func showLast() {
        if !messages.value.isEmpty {
            let index = messages.value.count - 1
            box.scrollToItem(at: IndexPath(row: index, section: 0), at: .bottom, animated: true)
        }
    }

    override var canBecomeFirstResponder: Bool { true }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {}

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        becomeFirstResponder()
    }
}

struct Message {
    var chatId = UUID()
    var content: String? = Contents().get()
    var icon: String? = Images().get()
    var name: String? = Names().get()
    var sendAt: Date = .init()

    var isSelf: Bool = false
}

class MessageView: HBox, Stateful, Eventable {
    enum Event {
        case tapIcon
    }

    var viewState = State<Message>.unstable()
    var eventProducer = SimpleIO<Event>()

    override func buildBody() {
        let isSelf = output.map(\.isSelf)
        attach {
            ZBox().attach($0) {
                UIImageView().attach($0)
                    .image(output.map(\.icon).then { downloadImage(url: $0) })
                    .size(50, 50)
                    .cornerRadius(8)
            }
            .style(ShadowStyle())
            .onTap(eventProducer.asInput { _ in .tapIcon })

            VBox().attach($0) {
                UILabel().attach($0)
                    .text(output.map(\.name))
                    .margin(bottom: 4)
                    .visibility(isSelf.map { $0.py_toggled().py_visibleOrGone() })

                ZBox().attach($0) {
                    UILabel().attach($0)
                        .numberOfLines(0)
                        .text(output.map(\.content))
                        .textColor(isSelf.map { $0 ? UIColor.white : .black })
                }
                .width(.wrap(max: 300))
                .padding(all: 12)
                .backgroundColor(isSelf.map { $0 ? Theme.accentColor : .white })
                .cornerRadius(8)
            }
            .justifyContent(isSelf.map { $0 ? .right : .left })
        }
        .space(8)
        .format(isSelf.map { $0 ? .trailing : .leading })
        .reverse(isSelf)
        .padding(all: 10)
    }
}

class MessageInputView: HBox, Eventable, UITextViewDelegate {
    enum Event {
        case send(String?)
        case add
    }

    var eventProducer = SimpleIO<Event>()

    private let text = State("")

    override func buildBody() {
        let hasText = text.map(\.isEmpty).map { !$0 }
        attach {
            UIButton().attach($0)
                .image(UIImage(systemName: "share"))

            UITextView().attach($0)
                .size(.fill, .wrap(min: 40))
                .cornerRadius(8)
                .backgroundColor(.lightGray.withAlphaComponent(0.4))
                .textColor(UIColor.black)
                .fontSize(20)
                .onText(text)
                .view
                .delegate = self

            ZBox().attach($0) {
                UIButton(type: .contactAdd).attach($0)
                    .bind(event: .touchUpInside, input: eventProducer.asInput { _ in .add })
                    .visibility(hasText.map { (!$0).py_visibleOrGone() })

                Label.demo("Send").attach($0)
                    .onTap(to: self) { this, _ in
                        this.send()
                    }
                    .size(Size(width: .wrap(min: 60), height: .wrap(min: 40)))
                    .visibility(hasText.map { $0.py_visibleOrGone() })
            }
            .justifyContent(.center)
            .animator(Animators.default)
        }
        .space(8)
        .backgroundColor(.white)
        .justifyContent(.center)
        .padding(all: 8)
        .animator(Animators.default)
    }

    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text, text.hasSuffix("\n") {
            send()
        }
    }

    func send() {
        emmit(.send(text.value.replacingOccurrences(of: "\n", with: "")))
        text.value = ""
    }
}
