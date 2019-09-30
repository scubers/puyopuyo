//
//  ButtonStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

// MARK: - Image

public protocol ImageDecorable {
    func applyImage(_ image: UIImage?, state: UIControl.State)
}

public class ImageStyle: UIControlBaseStyle<UIImage?, ImageDecorable> {
    public override func applyDecorable(_ decorable: ImageDecorable) {
        decorable.applyImage(value, state: controlState)
    }
}

// MARK: - BgImage

public protocol BgImageDecorable {
    func applyBgImage(_ image: UIImage?, state: UIControl.State)
}

public class BgImageStyle: UIControlBaseStyle<UIImage?, BgImageDecorable> {
    public override func applyDecorable(_ decorable: BgImageDecorable) {
        decorable.applyBgImage(value, state: controlState)
    }
}

// MARK: - TitleShadowColor
public protocol TitleShadowColorDecorable {
    func applyTitleShadowColor(_ color: UIColor?, state: UIControl.State)
}

public class TitleShadowColorStyle: UIControlBaseStyle<UIColor?, TitleShadowColorDecorable> {
    public override func applyDecorable(_ decorable: TitleShadowColorDecorable) {
        decorable.applyTitleShadowColor(value, state: controlState)
    }
}
