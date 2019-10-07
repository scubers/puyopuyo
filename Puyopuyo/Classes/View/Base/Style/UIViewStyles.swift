//
//  UIViewStyles.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/10/7.
//

import Foundation

public class CorderRadiusStyle: NSObjectStyle<UIView, CGFloat> {
    public init(value: CGFloat) {
        super.init(keyPath: \UIView.layer.cornerRadius, value: value)
    }
}

public class BackgroundColorStyle: NSObjectStyle<UIView, UIColor?> {
    public init(value: UIColor?) {
        super.init(keyPath: \UIView.backgroundColor, value: value)
    }
}

public class BorderColorStyle: NSObjectStyle<UIView, CGColor?> {
    public init(value: CGColor?) {
        super.init(keyPath: \UIView.layer.borderColor, value: value)
    }
}

public class AlphaStyle: NSObjectStyle<UIView, CGFloat> {
    public init(value: CGFloat) {
        super.init(keyPath: \UIView.alpha, value: value)
    }
}

public class BorderWidthStyle: NSObjectStyle<UIView, CGFloat> {
    public init(value: CGFloat) {
        super.init(keyPath: \UIView.layer.borderWidth, value: value)
    }
}

public class UserInteractionEnabledStyle: NSObjectStyle<UIView, Bool> {
    public init(value: Bool) {
        super.init(keyPath: \UIView.isUserInteractionEnabled, value: value)
    }
}

public class ClipToBoundsStyle: NSObjectStyle<UIView, Bool> {
    public init(value: Bool) {
        super.init(keyPath: \UIView.clipsToBounds, value: value)
    }
}

public class ContentModeStyle: NSObjectStyle<UIView, UIView.ContentMode> {
    public init(value: UIView.ContentMode) {
        super.init(keyPath: \UIView.contentMode, value: value)
    }
}

public class FrameStyle: NSObjectStyle<UIView, CGRect> {
    public init(value: CGRect) {
        super.init(keyPath: \UIView.frame, value: value)
    }
}

public class BoundsStyle: NSObjectStyle<UIView, CGRect> {
    public init(value: CGRect) {
        super.init(keyPath: \UIView.bounds, value: value)
    }
}
