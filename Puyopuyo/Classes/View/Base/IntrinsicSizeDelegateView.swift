//
//  IntrinsicSizeDelegateView.swift
//  Puyopuyo
//
//  Created by J on 2022/6/28.
//

import Foundation

public class IntrinsicSizeDelegateView: UIView {
    private var root: UIView

    public init(_ root: () -> ViewDisplayable) {
        self.root = root().dislplayView
        super.init(frame: .zero)
        addSubview(self.root)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        root.sizeThatFits(size)
    }

    public func applyContentSize(thatFits size: CGSize) {
        bounds.size = sizeThatFits(size)
    }
}
