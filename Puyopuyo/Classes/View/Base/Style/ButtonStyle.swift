//
//  ButtonStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

// MARK: - Image

public protocol ImageStyleable {
    func applyImage(_ image: UIImage?, state: UIControl.State)
}

public class ImageStyle: UIControlBaseStyle<UIImage?, ImageStyleable> {
    public override func applyStyleable(_ styleable: ImageStyleable) {
        styleable.applyImage(value, state: controlState)
    }
}

// MARK: - BgImage

public protocol BgImageStyleable {
    func applyBgImage(_ image: UIImage?, state: UIControl.State)
}

public class BgImageStyle: UIControlBaseStyle<UIImage?, BgImageStyleable> {
    public override func applyStyleable(_ styleable: BgImageStyleable) {
        styleable.applyBgImage(value, state: controlState)
    }
}

// MARK: - TitleShadowColor
public protocol TitleShadowColorStyleable {
    func applyTitleShadowColor(_ color: UIColor?, state: UIControl.State)
}

public class TitleShadowColorStyle: UIControlBaseStyle<UIColor?, TitleShadowColorStyleable> {
    public override func applyStyleable(_ styleable: TitleShadowColorStyleable) {
        styleable.applyTitleShadowColor(value, state: controlState)
    }
}
