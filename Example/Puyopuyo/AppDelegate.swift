//
//  AppDelegate.swift
//  Puyopuyo
//
//  Created by Jrwong on 06/22/2019.
//  Copyright (c) 2019 Jrwong. All rights reserved.
//

import UIKit
import Puyopuyo

class NavController: UINavigationController {
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = NavController(rootViewController: MenuVC())
//        window?.rootViewController = UINavigationController(rootViewController: TestVC())
        window?.makeKeyAndVisible()
        
        let v = UIView()
        v[keyPath: \UIView.py_measure.size.width] = .fill
        
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
    
    public func outputing(_ block: @escaping (Element) -> Void) -> Unbinder {
        let d = subscribe(onNext: { value in
            block(value)
        })
        return Unbinders.create {
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
