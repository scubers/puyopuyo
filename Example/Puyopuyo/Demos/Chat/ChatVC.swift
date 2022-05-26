//
//  ChatVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/9/18.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class ChatVC: BaseViewController, UICollectionViewDelegateFlowLayout {
    let messages = State<[Message]>((0 ..< 5).map { _ in Message() })
    var box: RecycleBox!
    let additionalSafeAreaPadding = State(UIEdgeInsets.zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        let this = WeakableObject(value: self)
        VBox().attach(view) {
            box = RecycleBox(
                diffable: true,
                sections: [
                    ListRecycleSection(
                        items: messages.asOutput(),
                        diffableKey: { $0.chatId.description },
                        cell: { o, _ in
                            MessageView().attach()
                                .state(o.map(\.data))
                                .width(.fill)
                                .onEvent(.tapIcon) {
                                    this.value?.navigationController?.pushViewController(FeedVC(), animated: true)
                                }
                                .view
                        }
                    )
                ].asOutput()
            )
            .attach($0)
            .assign(\.showsVerticalScrollIndicator, false)
            .size(.fill, .fill)
            .setDelegate(self)
            .backgroundColor(.systemGroupedBackground)
            .view

            MessageInputView().attach($0)
                .width(.fill)
                .padding(bottom: view.py_safeArea().binder.bottom.map { $0 + 12 })
                .onEvent(to: self) { this, v in
                    switch v {
                    case .send(let text):
                        this.addMessage(message: text, isSelf: true)
                    case .add:
                        this.addMessage()
                    case .onStartEdit:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            this.showLast()
                        }
                    }
                }
        }
        .animator(Animators.default)
        .padding(bottom: additionalSafeAreaPadding.binder.bottom)
        .size(.fill, .fill)

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

    var state = State<Message>.unstable()
    var emitter = SimpleIO<Event>()

    override func buildBody() {
        let isSelf = binder.isSelf
        attach {
            ZBox().attach($0) {
                UIImageView().attach($0)
                    .image(binder.icon.then { downloadImage(url: $0) })
                    .size(40, 40)
                    .cornerRadius(8)
            }
            .style(ShadowStyle())
            .onTap(emitter.asInput { _ in .tapIcon })

            VGroup().attach($0) {
                UILabel().attach($0)
                    .text(binder.name)
                    .margin(bottom: 4)
                    .visibility(isSelf.map { $0.py_toggled().py_visibleOrGone() })

                ZBox().attach($0) {
                    UILabel().attach($0)
                        .numberOfLines(0)
                        .text(binder.content)
                        .textColor(isSelf.map { $0 ? Theme.antiAccentColor : .label })
                }
                .width(.wrap(max: 250))
                .padding(all: 12)
                .backgroundColor(isSelf.map { $0 ? Theme.accentColor : .secondarySystemGroupedBackground })
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
        case onStartEdit
    }

    var emitter = SimpleIO<Event>()

    private let text = State("")

    override func buildBody() {
        let hasText = text.map(\.isEmpty).map { !$0 }.distinct()
        attach {
            UIButton().attach($0)
                .image(UIImage(systemName: "circle"))

            UITextView().attach($0)
                .size(.fill, .wrap(min: 40))
                .cornerRadius(8)
                .backgroundColor(UIColor.systemGray6)
                .fontSize(20)
                .onText(text)
                .view
                .delegate = self

            ZGroup().attach($0) {
                UIButton(type: .contactAdd).attach($0)
                    .onControlEvent(.touchUpInside, emitter.asInput { _ in .add })
                    .alpha(hasText.map { !$0 ? 1 : 0 })
                    .size(hasText.map { $0 ? Size.fixed(1) : Size(width: .wrap, height: .wrap) })

                Label.demo("Send").attach($0)
                    .onTap(to: self) { this, _ in
                        this.send()
                    }
                    .size(hasText.map { !$0 ? Size.fixed(1) : Size(width: .wrap(min: 60), height: .wrap(min: 40)) })
                    .alpha(hasText.map { $0 ? 1 : 0 })
            }
            .justifyContent(.center)
        }
        .space(8)
        .backgroundColor(UIColor.systemBackground)
        .justifyContent(.center)
        .padding(
            vert: 12.asOutput(),
            left: py_safeArea().binder.left.map { $0 + 8 },
            right: py_safeArea().binder.right.map { $0 + 8 }
        )
        .animator(Animators.default)
    }

    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text, text.hasSuffix("\n") {
            send()
        }
    }

    func send() {
        emit(.send(text.value.replacingOccurrences(of: "\n", with: "")))
        text.value = ""
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        emit(.onStartEdit)
    }
}
