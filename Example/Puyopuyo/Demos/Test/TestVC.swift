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

class Person {
    var name: String?
    var age = 1
}

class Store: AbstractStateStoreObject {
    @ChangeNotifier var person = Person()

    @ChangeNotifier var name: String? = "abc"
    var age: Int = 0

    func aaa() {}
}

class TestVC: UIViewController {
    @StateStore var store = Store()
    @GlobalStore var store1: Store
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        store1.onStoreChanged().safeBind(to: self) { _, s in
            print(s)
        }
        store.onStoreChanged().safeBind(to: self) { _, s in
            print(s)
        }
        
        $store.person.name.safeBind(to: self) { (this, s) in
            print(s ?? "")
        }

        store.name = "1"
        store.age = 10
        store.$person.trigger { $0.name = "100" }
        

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

/// 存在的意义只是因为iOS13以下不支持 some 关键字
protocol BuilderCoordinator {
    func build(_ context: UIViewController)
}

extension BuilderCoordinator where Self: ControllerBuilder {
    func build(_ context: UIViewController) {
        prepareBuild(with: { context as! Controller })
        build(with: { context as! Controller })
        afterBuild(with: { context as! Controller })
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
    
    @GlobalStore var store: Store
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.name = "100"
    }
    
    override var coordinator: BuilderCoordinator? { Builder(viewController: self) }
    struct Builder: ControllerBuilder, BuilderCoordinator {
        weak var viewController: SubVC?

        let view = UIView()

        let sections = State(value: [IRecycleSection]())
        func build(with context: () -> SubVC) {
            context().attach {
                VBox().attach($0) {
                    RecycleBox(
                        sections: sections.asOutput()
                    )
                    .attach($0)
                    .size(.fill, .fill)
                    Label.demo("").attach($0)
                        .text(sections.binding.count.description)
                }
                .backgroundColor(Util.randomColor())
                .onTap(finish)
                .size(.fill, .fill)
            }
        }

        func afterBuild(with context: () -> SubVC) {
            reload()
            sections.outputing { _ in
                print(self)
            }
            .unbind(by: context())
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
