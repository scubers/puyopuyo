//
//  AppDelegate.swift
//  Puyopuyo
//
//  Created by Jrwong on 06/22/2019.
//  Copyright (c) 2019 Jrwong. All rights reserved.
//

import Puyopuyo
import RxSwift
import UIKit

class Person {
    var name: String?
    var cat = Cat()
}

class Cat {
    var name: String?
    var age: Int = 1
    var dog: Dog?
}

class Dog {
    var name: String?
}

// class MySection: BasicRecycleSection<Void> {}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var view = UIView()
    var disposable: Disposer?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIImageView.appearance().tintColor = Theme.accentColor

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: MenuViewController())
//        window?.rootViewController = NavController(rootViewController: UIViewController())
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

import Foundation
import Puyopuyo
import RxSwift

extension Observable: Outputing {
    public typealias OutputType = Element

    public func outputing(_ block: @escaping (Element) -> Void) -> Puyopuyo.Disposer {
        let d = subscribe(onNext: { value in
            block(value)
        })
        return Disposers.create {
            d.dispose()
        }
    }
}

extension PublishSubject: Inputing {
    public typealias InputType = Element

    public func input(value: Element) {
        onNext(value)
    }
}

extension BehaviorSubject: Inputing {
    public typealias ValueType = Element

    public typealias InputType = Element

    public func input(value: Element) {
        onNext(value)
    }
}

class PLinking<T: Viewable, U> {
    weak var view: T?

    init(_ value: T) {
        self.view = value
    }
}

struct PBinding<U> {
    var view: Viewable?

    static var none: PBinding<Void> { .init(view: nil) }
}

protocol Viewable: AnyObject {
    var selfView: UIView? { get }
}

protocol ParentDataAsuming {
    associatedtype ParentData
}

// protocol PuyoLinking: AnyObject {
//    associatedtype Holder: Viewable
// }

extension Viewable {
    func bind<U>(_ binding: PBinding<U>, _ block: (PBinding<Void>) -> Void = { _ in }) -> PLinking<UIView, U> {
        guard let view = selfView else { fatalError() }
        binding.view?.selfView?.addSubview(view)
        return PLinking(view)
    }

    func bind(_ block: (PBinding<Void>) -> Void = { _ in }) -> PLinking<UIView, Void> {
        bind(.none, block)
    }
}

extension Viewable where Self: ParentDataAsuming {
    func bind<U>(_ binding: PBinding<U>, _ block: (PBinding<ParentData>) -> Void = { _ in }) -> PLinking<Self, U> {
        guard let view = selfView else { fatalError() }
        binding.view?.selfView?.addSubview(view)
        return PLinking(self)
    }

    func bind(_ block: (PBinding<ParentData>) -> Void = { _ in }) -> PLinking<Self, Void> {
        bind(.none, block)
    }
}

extension UIView: Viewable {
    var selfView: UIView? { self }
}

class RegView<R: Puyopuyo.Regulator, ParentData>: BoxView<R>, ParentDataAsuming {}

class StringView: RegView<LinearRegulator, String> {}
class IntView: RegView<LinearRegulator, Int> {}

func test() {
    let abc = UIView().bind {
        let b = StringView().bind($0) {
            let c = IntView().bind($0) {
                let d = UIView().bind($0)
                print(d)
            }
            print(c)
        }
        print(b)
    }
    print(abc)
}

extension PLinking {
    var ensureView: UIView {
        guard let view = view?.selfView else { fatalError() }
        return view
    }
}

extension PLinking where U == String {
    func title(_ value: String?) -> Self {
        return self
    }
}
