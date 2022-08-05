//
//  Helper.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

struct Helper {
    static func randomColor() -> UIColor {
        let red = CGFloat(arc4random()%256) / 255.0
        let green = CGFloat(arc4random()%256) / 255.0
        let blue = CGFloat(arc4random()%256) / 255.0
        let c = UIColor(red: red, green: green, blue: blue, alpha: 0.7)
        return c
    }

    static func toJson(_ dict: [String: Any], prettyPrinted: Bool = false) -> String? {
        var options: JSONSerialization.WritingOptions = [.fragmentsAllowed]
        if prettyPrinted {
            options = options.union(.prettyPrinted)
        }
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: options), let json = String(data: data, encoding: .utf8) {
            return json
        }
        return nil
    }

    static func fromJson(_ json: String?) -> [String: Any]? {
        if let data = json?.data(using: .utf8), let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return jsonObject
        }
        return nil
    }

    static let defaultViewJson = """
    {"width":300,"height":200,"root":{"width":{"ratio":1,"sizeType":"ratio"},"templateId":"template.linearBox","children":[{"width":{"fixedValue":80,"sizeType":"fixed"},"height":{"aspectRatio":1,"sizeType":"aspectRatio"},"url":"https:\\/\\/gimg2.baidu.com\\/image_search\\/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20171221%2F2a14e6b09df846a1908379c06045ba96.jpeg&amp;refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&amp;app=2002&amp;size=f9999,10000&amp;q=a80&amp;n=0&amp;g=0n&amp;fmt=jpeg?sec=1633419559&amp;t=b72763232c581a611d7cc913047dc0d1","templateId":"template.uiimageview"},{"direction":"vertical","space":4,"children":[{"templateId":"template.uilabel","text":"Jrwong"},{"templateId":"template.uilabel","text":"Description"}],"padding":{"left":8,"top":8,"bottom":8,"right":8},"templateId":"template.linearBox","width":{"sizeType":"ratio","ratio":1}},{"templateId":"template.uilabel","text":">"}],"padding":{"right":8,"top":8,"bottom":8,"left":8},"justifyContent":{"alignment":["horzCenter", "vertCenter"]}}}
    """
}
