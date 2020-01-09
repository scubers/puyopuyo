//
//  RetainWrapper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/15.
//

import UIKit

public class RetainWrapper<Wrapped: AnyObject> {
    public private(set) var retained = true
    weak var weakValue: Wrapped?
    var strongValue: Wrapped?

    public var value: Wrapped? { strongValue ?? weakValue }

    public init(value: Wrapped, retained: Bool = true) {
        self.retained = retained
        if retained {
            strongValue = value
        } else {
            weakValue = value
        }
    }
}

extension RetainWrapper: Unbinder {
    public func py_unbind() {}
}

public class ProxyChain<Delegate: AnyObject>: PYProxyChain {
    public var delegates: [Delegate] {
        return targets.filter({ $0.getValue() != nil }).map({ $0.getValue() as! Delegate })
    }

    public required init(wrappers: [RetainWrapper<Delegate>]) {
        super.init(targets: wrappers.map {
            PYTarget(value: $0.value as Any, retained: $0.retained)
        })
    }
}

public class DelegateProxy<Delegate: AnyObject>: PYProxyChain {
    public var original: RetainWrapper<Delegate>
    public var backup: RetainWrapper<Delegate>?
    public required init(original: RetainWrapper<Delegate>, backup: RetainWrapper<Delegate>?) {
        self.original = original
        self.backup = backup
        var objs = [PYTarget(value: original.value as Any, retained: original.retained)]
        if let backup = backup {
            objs.append(PYTarget(value: backup.value as Any, retained: backup.retained))
        }
        super.init(targets: objs)
    }
}

extension PYProxyChain: UITextFieldDelegate {}
extension PYProxyChain: UITextViewDelegate {}
extension PYProxyChain: UISearchBarDelegate {}
extension PYProxyChain: UIPickerViewDelegate {}
