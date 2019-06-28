//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

open class BoxView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .init(rawValue: 0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public var layout: BaseLayout {
        return py_measure as! BaseLayout
    }
    
    
    open override func setNeedsLayout() {
        super.setNeedsLayout()
        // 如果自己是固定尺寸，则不需要通知上层进行布局
        let measure = py_measure
        if let superview = superview as? BoxView, (measure.size.width.isWrap || measure.size.height.isWrap) {
            superview.setNeedsLayout()
        }
    }
}
