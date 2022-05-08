//
//  Borders.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/31.
//

import Foundation

public class Borders {
    public static func all(_ border: Border?) -> Borders {
        let b = Borders()
        b.top = border
        b.left = border
        b.bottom = border
        b.right = border
        return b
    }

    public var top: Border?
    private weak var topLayer: CAShapeLayer?

    public var left: Border?
    private weak var leftLayer: CAShapeLayer?

    public var bottom: Border?
    private weak var bottomLayer: CAShapeLayer?

    public var right: Border?
    private weak var rightLayer: CAShapeLayer?

    func updateTop(to superLayer: CALayer) {
        guard let border = top else {
            topLayer?.removeFromSuperlayer()
            return
        }
        let layer = generateLayerIfNeeded(originlayer: topLayer, border: border)
        topLayer = layer
        let frame = superLayer.frame
        var layerFrame = CGRect.zero
        layerFrame.origin.x = border.leadInset
        layerFrame.origin.y = border.offset
        layerFrame.size.width = frame.size.width - (border.leadInset + border.trailInset)
        layerFrame.size.height = border.thick
        layer.frame = layerFrame
        layer.path = getHorzPath(layerFrame).cgPath
        if layer.superlayer != layer {
            superLayer.addSublayer(layer)
        }
    }

    func updateLeft(to superLayer: CALayer) {
        guard let border = left else {
            leftLayer?.removeFromSuperlayer()
            return
        }
        let layer = generateLayerIfNeeded(originlayer: leftLayer, border: border)
        leftLayer = layer
        let frame = superLayer.frame
        var layerFrame = CGRect.zero
        layerFrame.origin.x = border.offset
        layerFrame.origin.y = border.leadInset
        layerFrame.size.width = border.thick
        layerFrame.size.height = frame.size.height - (border.leadInset + border.trailInset)
        layer.frame = layerFrame
        layer.path = getVertPath(layerFrame).cgPath
        if layer.superlayer != layer {
            superLayer.addSublayer(layer)
        }
    }

    func updateBottom(to superLayer: CALayer) {
        guard let border = bottom else {
            bottomLayer?.removeFromSuperlayer()
            return
        }
        let layer = generateLayerIfNeeded(originlayer: bottomLayer, border: border)
        bottomLayer = layer
        let frame = superLayer.frame
        var layerFrame = CGRect.zero
        layerFrame.origin.x = border.leadInset
        layerFrame.origin.y = frame.height - border.offset - border.thick
        layerFrame.size.width = frame.size.width - (border.leadInset + border.trailInset)
        layerFrame.size.height = border.thick
        layer.frame = layerFrame
        layer.path = getHorzPath(layerFrame).cgPath
        if layer.superlayer != layer {
            superLayer.addSublayer(layer)
        }
    }

    func updateRight(to superLayer: CALayer) {
        guard let border = right else {
            rightLayer?.removeFromSuperlayer()
            return
        }
        let layer = generateLayerIfNeeded(originlayer: rightLayer, border: border)
        rightLayer = layer
        let frame = superLayer.frame
        var layerFrame = CGRect.zero
        layerFrame.origin.x = frame.width - border.offset - border.thick
        layerFrame.origin.y = border.leadInset
        layerFrame.size.width = border.thick
        layerFrame.size.height = frame.size.height - (border.leadInset + border.trailInset)
        layer.frame = layerFrame
        layer.path = getVertPath(layerFrame).cgPath
        if layer.superlayer != layer {
            superLayer.addSublayer(layer)
        }
    }

    private func generateLayerIfNeeded(originlayer: CAShapeLayer?, border: Border) -> CAShapeLayer {
        let layer = originlayer ?? CAShapeLayer()
        layer.strokeColor = border.color?.cgColor
        layer.lineWidth = border.thick
        layer.strokeStart = 0
        layer.strokeEnd = 1
        layer.zPosition = 1000
        layer.lineDashPattern = border.dash.map { NSNumber(value: Float($0)) }
        return layer
    }

    private func getHorzPath(_ frame: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: frame.height / 2))
        path.addLine(to: CGPoint(x: frame.width, y: frame.height / 2))
        return path
    }

    private func getVertPath(_ frame: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width / 2, y: 0))
        path.addLine(to: CGPoint(x: frame.width / 2, y: frame.height))
        return path
    }
}

public enum BorderOptions {
    case thick(CGFloat)
    case color(UIColor)
    case lead(CGFloat)
    case trail(CGFloat)
    case offset(CGFloat)
    case dash(CGFloat, CGFloat)
}

public struct Border {
    public var thick: CGFloat = 1
    public var color: UIColor?
    public var leadInset: CGFloat = 0
    public var trailInset: CGFloat = 0
    public var offset: CGFloat = 0
    public var dash: [CGFloat] = []
    public init(thick: CGFloat = 1, color: UIColor? = nil, leadInset: CGFloat = 0, trailInset: CGFloat = 0, offset: CGFloat = 0, dash: [CGFloat] = []) {
        self.thick = thick
        self.color = color
        self.leadInset = leadInset
        self.trailInset = trailInset
        self.offset = offset
        self.dash = dash
    }

    public init?(options: [BorderOptions]) {
        if options.isEmpty { return nil }
        options.forEach {
            switch $0 {
            case let .thick(x): self.thick = x
            case let .color(x): self.color = x
            case let .lead(x): self.leadInset = x
            case let .trail(x): self.trailInset = x
            case let .offset(x): self.offset = x
            case let .dash(x, y): self.dash = [x, y]
            }
        }
    }
}
