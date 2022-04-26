//
//  BoxHelper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/9.
//

import UIKit

public class BoxControl<R: Regulator> {
    ///
    /// Control `contentSize` when superview is UIScrollView
    public var isScrollViewControl = false

    ///
    /// Control `center` when superview is not BoxView
    public var isCenterControl = true

    ///
    /// Control `size` when superview is not BoxView
    public var isSizeControl = true
    
    public var borders = Borders()
}

public protocol Boxable {
    associatedtype RegulatorType: Regulator
    var control: BoxControl<RegulatorType> { get }
    var regulator: RegulatorType { get }
}

public extension Boxable {
    @available(*, deprecated, message: "Use [control]")
    var boxHelper: BoxControl<RegulatorType> { control }
}

enum BoxUtil {
    static func isBox(_ view: UIView?) -> Bool {
        view is RegulatorView
    }
}

public typealias BoxBuilder<T> = (T) -> Void
public typealias BoxGenerator<T> = () -> T
