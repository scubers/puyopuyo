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
    
    /// 只应用固有尺寸
    func _selfSizeAdapting(size: Size) {
        let parentCGSize = superview?.bounds.size ?? .zero
        // 本身固有尺寸
        if size.isFixed() {
            let size = Caculator.caculate(size: size, by: parentCGSize)
            bounds.size = CGSize(width: size.width.fixedValue, height: size.height.fixedValue)
        } else if size.width.isFixed {
            let width = Caculator.caculateFix(width: size.width, by: parentCGSize.width)
            bounds.size.width = width.fixedValue
        } else if size.height.isFixed {
            let height = Caculator.caculateFix(width: size.height, by: parentCGSize.height)
            bounds.size.height = height.fixedValue
        }
    }

    
    open override func setNeedsLayout() {
        super.setNeedsLayout()
        // 如果自己是固定尺寸，则不需要通知上层进行布局
        let measure = py_measure
        if let superview = superview as? BoxView, measure.size.maybeWrap() {
            superview.setNeedsLayout()
        }
    }
}
