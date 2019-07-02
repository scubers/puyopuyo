
import TangramKit

// MARK: - tg_属性只能在TangramKit布局内使用
extension PuyoLink where T: UIView {
    
    @discardableResult
    public func tg_size(_ width: TGLayoutSizeType, _ height: TGLayoutSizeType) -> Self {
        view.tg_size(width: width, height: height)
        return self
    }
    
    @discardableResult
    public func tg_size(_ width: TGLayoutSize, _ height: TGLayoutSize) -> Self {
        view.tg_size(width: width, height: height)
        return self
    }
    
    @discardableResult
    public func tg_size(_ width: TGLayoutSize, _ height: TGLayoutSizeType) -> Self {
        view.tg_size(width: width, height: height)
        return self
    }
    
    @discardableResult
    public func tg_size(_ width: TGLayoutSizeType, _ height: TGLayoutSize) -> Self {
        view.tg_size(width: width, height: height)
        return self
    }
    
    @discardableResult
    public func tg_width(_ width: CGFloat) -> Self {
        view.tg_width.equal(width)
        return self
    }
    
    @discardableResult
    public func tg_width(_ width: TGLayoutSize) -> Self {
        view.tg_width.equal(width)
        return self
    }
    
    @discardableResult
    public func tg_height(_ height: CGFloat) -> Self {
        view.tg_height.equal(height)
        return self
    }
    
    @discardableResult
    public func tg_height(_ height: TGLayoutSize) -> Self {
        view.tg_height.equal(height)
        return self
    }
    
    @discardableResult
    public func tg_margin(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        if let all = all {
            view.tg_margin(all)
        }
        if let top = top { view.tg_top.equal(top) }
        if let left = left { view.tg_left.equal(left) }
        if let bottom = bottom { view.tg_bottom.equal(bottom) }
        if let right = right { view.tg_right.equal(right) }
        return self
    }
    
    @discardableResult
    public func tg_alignment(_ aligment: TGGravity) -> Self {
        view.tg_alignment = aligment
        return self
    }
    
    @discardableResult
    public func tg_visibility(_ visibility: TGVisibility) -> Self {
        view.tg_visibility = visibility
        return self
    }
}

extension PuyoLink where T: TGBaseLayout {
    @discardableResult
    public func tg_gravity(_ gravity: TGGravity) -> Self {
        view.tg_gravity = gravity
        return self
    }
    
    @discardableResult
    public func tg_space(v: CGFloat = 0, h: CGFloat = 0) -> Self {
        view.tg_vspace = v
        view.tg_hspace = h
        return self
    }
    
    @discardableResult
    public func tg_padding(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        if let all = all {
            view.tg_padding = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        }
        if let top = top { view.tg_topPadding = (top) }
        if let left = left { view.tg_leftPadding = (left) }
        if let bottom = bottom { view.tg_bottomPadding = (bottom) }
        if let right = right { view.tg_rightPadding = (right) }
        return self
    }
    
    @discardableResult
    public func tg_border(all: TGBorderline? = nil, top: TGBorderline? = nil, left: TGBorderline? = nil, bottom: TGBorderline? = nil, right: TGBorderline? = nil) -> Self {
        if let all = all {
            view.tg_boundBorderline = all
        }
        if let top = top { view.tg_topBorderline = (top) }
        if let left = left { view.tg_leftBorderline = (left) }
        if let bottom = bottom { view.tg_bottomBorderline = (bottom) }
        if let right = right { view.tg_rightBorderline = (right) }
        return self
    }
    @discardableResult
    public func tg_reverseLayout(_ reverse: Bool) -> Self {
        view.tg_reverseLayout = reverse
        return self
    }
}
