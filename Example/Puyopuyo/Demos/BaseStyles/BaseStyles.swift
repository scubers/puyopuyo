//
//  BaseStyles.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/10/7.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo


extension StyleSheet {
    
    /// 圆角
    static var rounded: StyleSheet {
        return StyleSheet(styles: [
            CorderRadiusStyle(value: 6),
            ClipToBoundsStyle(value: true)
        ])
    }
    
    /// 主要按钮
    static var mainButton: StyleSheet {
        return
            StyleSheet(styles: [
                UIFont.systemFont(ofSize: 14),
                ClipToBoundsStyle(value: true),
                TextAlignmentStyle(value: .center),
                TapCoverStyle(),
            ]).combine(sheet: rounded)
    }
    
    /// 标题
    static var title: StyleSheet {
        return
            StyleSheet(styles: [
                UIFont.systemFont(ofSize: 16),
                TextColorStyle(value: .black),
                TextAlignmentStyle(value: .left),
                (\UILabel.lineBreakMode).getStyle(with: .byTruncatingTail)
            ])
    }
    
    /// 正文
    static var mainText: StyleSheet {
        return
            StyleSheet(styles: [
                UIFont.systemFont(ofSize: 14),
                TextColorStyle(value: .black),
                TextAlignmentStyle(value: .left),
                (\UILabel.lineBreakMode).getStyle(with: .byTruncatingTail)
            ])
    }
}
