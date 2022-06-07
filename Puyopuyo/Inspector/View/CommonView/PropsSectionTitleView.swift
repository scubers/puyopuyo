//
//  PropsSectionTitleView.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class PropsSectionTitleView: UILabel {
    override init(frame: CGRect) {
        super.init(frame: .zero)

        attach()
            .fontSize(16, weight: .bold)
            .numberOfLines(0)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

class PropsTitleView: UILabel {
    override init(frame: CGRect) {
        super.init(frame: .zero)

        attach()
            .fontSize(14)
            .numberOfLines(0)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}
