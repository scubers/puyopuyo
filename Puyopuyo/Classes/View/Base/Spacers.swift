//
//  Spacers.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/11.
//

import UIKit

public class Spacer: UIView {
    public init(_ space: CGFloat = 10) {
        super.init(frame: .zero)
        py_measure.size.height = .fix(space)
        py_measure.size.width = .fix(space)
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
