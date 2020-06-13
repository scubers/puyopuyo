//
//  TestVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import RxSwift
import TangramKit
import UIKit

class NewView: ZBox, Eventable {
    var eventProducer = SimpleIO<String>()
    override func buildBody() {
        attach {
            UIButton(type: .contactAdd).attach($0)
                .bind(to: self, event: .touchUpInside, action: { this, _ in
                    this.emmit("100")
                })
        }
    }
}

class TestVC: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false

        VBox().attach(view) {
            VFlow(count: 0).attach($0) {
                for idx in 0..<20 {
                    UIView().attach($0)
                        .size(50, 50)
                        .attach {
                            if idx == 1 {
                                $0.attach().flowEnding(true)
                            }
                        }
                }
            }
            .space(10)
            .size(.fill, .fill)
        }
        .onTap(to: self) { this, _ in
            this.navigationController?.pushViewController(SubVC(), animated: true)
        }
        .space(10)
        .padding(all: 20)
        .size(.fill, .fill)
        view.backgroundColor = .white
        Util.randomViewColor(view: view)
    }

    func build() {
        attach {
            UIView().attach($0) {
                UILabel().attach($0)
                    .text("测试Label")
                UIButton().attach($0)
                    .text("测试Button", state: .normal)
            }
        }
    }
}

protocol ControllerBuilder {
    associatedtype Controller: UIViewController
    var viewController: Controller? { get }
    func prepareBuild(with context: () -> Controller)
    func build(with context: () -> Controller)
    func afterBuild(with context: () -> Controller)
}

extension ControllerBuilder {
    func prepareBuild(with context: () -> Controller) {}
    func build(with context: () -> Controller) {}
    func afterBuild(with context: () -> Controller) {}
}

protocol BuilderCoordinator {
    func build(_ context: @autoclosure () -> Any)
}

extension BuilderCoordinator where Self: ControllerBuilder {
    func build(_ context: @autoclosure () -> Any) {
        prepareBuild(with: { context() as! Controller })
        build(with: { context() as! Controller })
        afterBuild(with: { context() as! Controller })
    }
}

class ParentVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator?.build(self)
    }

    var coordinator: BuilderCoordinator? { nil }
}

class SubVC: ParentVC {
    override var coordinator: BuilderCoordinator? { Builder(viewController: self) }
    struct Builder: ControllerBuilder, BuilderCoordinator {
        weak var viewController: SubVC?

        class Person {
            var name: String?
            var wallet: Wallet?
            var party: Party?
        }

        class Wallet {
            var amount: String?
        }

        struct Party {
            var version: String?
            var person: Person?
        }

//        let sections = State([IRecycleSection]())
        var sections = State(value: [IRecycleSection]())
        var person = State(Person())
        func build(with context: () -> SubVC) {
            context().attach {
                VBox().attach($0) {
                    RecycleBox(
                        sections: self.sections.asOutput()
                    )
                    .attach($0)
                    .size(.fill, .fill)
                    Label.demo("").attach($0)
                        .text(self.sections.binding.count.description)
                }
                .backgroundColor(Util.randomColor())
                .onTap { self.finish() }
                .size(.fill, .fill)
            }
        }

        func afterBuild(with context: () -> SubVC) {
            reload()
        }

        func finish() {
            viewController?.navigationController?.popViewController(animated: true)
        }

        func reload() {
            sections.input(
                value: (0..<10).map {
                    DataRecycleSection<String>(
                        list: (0..<$0).map { $0.description }.asOutput(),
                        _cell: { o, _ in
                            HBox().attach {
                                Label.demo("").attach($0)
                                    .text(o.binding.data)
                            }
                            .view
                        }
                    )
                }
            )
        }
    }
}
