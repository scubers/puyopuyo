//
//  Util.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo
import UIKit

struct Util {
    static func randomColor() -> UIColor {
        let red = CGFloat(arc4random()%256) / 255.0
        let green = CGFloat(arc4random()%256) / 255.0
        let blue = CGFloat(arc4random()%256) / 255.0
        let c = UIColor(red: red, green: green, blue: blue, alpha: 0.7)
        return c
    }

    static func randomViewColor(view: UIView) {
        view.subviews.forEach { v in
            v.backgroundColor = self.randomColor()
            self.randomViewColor(view: v)
        }
    }

    static func random<T>(array: [T]) -> T {
        let index = arc4random_uniform(UInt32(array.count))
        return array[Int(index)]
    }

    static func getViewController(from view: UIView) -> UIViewController? {
        var responder = view.next
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }

    static func pixel(_ pixcel: CGFloat) -> CGFloat {
        return pixcel / UIScreen.main.scale
    }
}

class FPSView: ZBox {
    let text = State<String?>(nil)

    var times = 0

    var link: CADisplayLink? {
        willSet {
            link?.invalidate()
        }
    }

    var timestamp: CFTimeInterval = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        UILabel().attach(self).text(text)
        backgroundColor = .white
    }

    deinit {
        link?.invalidate()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        link = CADisplayLink(target: self, selector: #selector(ticks(link:)))
        link?.add(to: RunLoop.main, forMode: .common)
    }

    @objc func ticks(link: CADisplayLink) {
        guard superview != nil else {
            link.invalidate()
            self.link = nil
            return
        }
        times += 1
        if timestamp == 0 {
            timestamp = link.timestamp
        }
        let passed = link.timestamp - timestamp
        if passed >= 1 {
            let fps = Double(times) / passed
            text.value = String(format: "FPS: %.1f", fps)
            timestamp = link.timestamp
            times = 0
        }
    }
}

class Iterator<T> {
    var arr: [T]
    init(_ arr: [T]) {
        assert(arr.count > 0)
        self.arr = arr
    }

    private var index: Int = -1
    func next() -> T {
        index += 1
        if index >= arr.count {
            index = 0
        }
        return arr[index]
    }
}

extension UIColor {
    // Hex String -> UIColor
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

enum Theme {
    static let accentColor = UIColor(hexString: "237cff")
    static let antiAccentColor = UIColor.white

    static let background = UIColor(hexString: "eeeeee")
    static let card = UIColor(hexString: "ffffff")

    static let dividerColor = UIColor.black.withAlphaComponent(0.2)

    static let demoBoxBorder: [BorderOptions] = [
        .color(.lightGray),
        .thick(Util.pixel(1)),
        .dash(2, 2)
    ]
}

extension Puyo where T: Boxable & UIView {
    @discardableResult
    func demo() -> Self {
        borders(Theme.demoBoxBorder)
        padding(all: 10)
        margin(all: 10)
        return self
    }
}
