//
//  Delegates.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/20.
//

import Foundation

public protocol Delegatable {
    associatedtype DelegateType
    func setDelegate(_ delegate: DelegateType, retained: Bool)
}

public protocol DataSourceable {
    associatedtype DataSourceType
    func setDataSource(_ dataSource: DataSourceType, retained: Bool)
}
