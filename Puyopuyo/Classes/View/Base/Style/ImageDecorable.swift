//
//  ImageDecorable.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/25.
//

import Foundation

public class ImageStyle: UIControlBaseStyle<UIImage?, ImageDecorable> {
    public override func applyDecorable(_ decorable: ImageDecorable) {
        decorable.applyImage(value, state: controlState)
    }
}

public class BgImageStyle: UIControlBaseStyle<UIImage?, BgImageDecorable> {
    public override func applyDecorable(_ decorable: BgImageDecorable) {
        decorable.applyBgImage(value, state: controlState)
    }
}
