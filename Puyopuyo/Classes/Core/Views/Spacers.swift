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
        self.py_measure.size.height = .fixed(space)
        self.py_measure.size.width = .fixed(space)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
