//
//  TapCoverStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

// MARK: - TapRippleStyle

public class TapRippleStyle: BaseGestureStyle {
    var color: UIColor = UIColor.lightGray.withAlphaComponent(0.6)
    public init(color: UIColor? = nil) {
        super.init(identifier: "TapRippleStyle")
        if let c = color {
            self.color = c
        }
    }

    open override func getGesture() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer()
        let delegate = ShouldSimulateOtherGestureDelegate()
        tap.delegate = delegate
        tap.py_setUnbinder(delegate, for: "\(styleIdentifier)_delegate")
        tap.py_addAction { self.animate($0) }
        return tap
    }

    private func animate(_ gesture: UIGestureRecognizer) {
        guard let view = gesture.view else { return }
        let round = CAShapeLayer()
        round.cornerRadius = view.layer.cornerRadius
        let point = gesture.location(in: gesture.view)
        round.path = UIBezierPath(arcCenter: point, radius: 10, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true).cgPath
        round.fillColor = color.cgColor
        round.opacity = 0
        round.frame = view.bounds
        round.zPosition = 100_000
        round.masksToBounds = true
        view.layer.addSublayer(round)
        let duration: Double = 0.5
        let big = CABasicAnimation(keyPath: "path")
        big.duration = duration
        let size = view.bounds.size
        big.toValue = UIBezierPath(arcCenter: point, radius: max(size.height, size.width), startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true).cgPath
        big.timingFunction = CAMediaTimingFunction(name: .easeOut)
        round.add(big, forKey: "big")

        let alpha = CABasicAnimation(keyPath: "opacity")
        alpha.duration = duration
        alpha.toValue = 0.1
        alpha.fromValue = 1
        round.add(alpha, forKey: "opacity")

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            round.removeFromSuperlayer()
        }
    }
}

// MARK: - TapCoverStyle

public class TapCoverStyle: BaseGestureStyle {
    var color: UIColor = UIColor.lightGray.withAlphaComponent(0.6)
    public init(color: UIColor? = nil) {
        super.init(identifier: "TapCoverStyle")
        if let c = color {
            self.color = c
        }
    }

    open override func getGesture() -> UIGestureRecognizer {
        let gesture = Gesture(color: color)
        let delegate = ShouldSimulateOtherGestureDelegate()
        gesture.delegate = delegate
        gesture.py_setUnbinder(delegate, for: "\(styleIdentifier)_delegate")
        return gesture
    }

    class Gesture: LayerGesture {
        override func touchesBegan(_: Set<UITouch>, with _: UIEvent) {
            layer.frame = view?.bounds ?? .zero
            layer.fillColor = color.cgColor
            layer.path = UIBezierPath(rect: layer.bounds).cgPath
            layer.opacity = 0
            layer.zPosition = 1000
            layer.masksToBounds = true
            layer.cornerRadius = view?.layer.cornerRadius ?? 0
            view?.layer.addSublayer(layer)
            showLayer()
        }

        override func touchesEnded(_: Set<UITouch>, with _: UIEvent) {
            dismissLayer()
        }

        override func touchesCancelled(_: Set<UITouch>, with _: UIEvent) {
            dismissLayer()
        }

        func showLayer() {
            let big = CABasicAnimation(keyPath: "opacity")
            big.duration = 0.2
            big.fromValue = 0
            big.toValue = 1
            layer.add(big, forKey: "show")
            layer.opacity = 1
        }

        func dismissLayer() {
            let big = CABasicAnimation(keyPath: "opacity")
            big.duration = 0.2
            big.toValue = 0
            layer.add(big, forKey: "dimiss")
            layer.opacity = 0
        }
    }
}

// MARK: - TapScaleStyle

public class TapScaleStyle: BaseGestureStyle {
    var scale: Double
    public init(scale: Double = 0.9) {
        self.scale = scale
        super.init(identifier: "TapScaleStyle")
    }

    public override func getGesture() -> UIGestureRecognizer {
        let tap = Gesture()
        tap.scale = scale
        let d = ShouldSimulateOtherGestureDelegate()
        tap.delegate = d
        tap.py_setUnbinder(d, for: "\(styleIdentifier)_delegate")
        return tap
    }

    class Gesture: UIGestureRecognizer {
        var scale: Double = 1
        override func touchesBegan(_: Set<UITouch>, with _: UIEvent) {
            startAnimate()
        }

        override func touchesCancelled(_: Set<UITouch>, with _: UIEvent) {
            dismissAnimate()
        }

        override func touchesEnded(_: Set<UITouch>, with _: UIEvent) {
            dismissAnimate()
        }

        private func startAnimate() {
            guard let view = view else { return }
            UIView.animate(withDuration: 0.15) {
                view.layer.transform = CATransform3DMakeScale(CGFloat(self.scale), CGFloat(self.scale), 1)
            }
        }

        private func dismissAnimate() {
            guard let view = view else { return }
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
}

// MARK: - TapSelectStyle

public class TapSelectStyle: BaseGestureStyle {
    var animated = false
    var duration: TimeInterval = 0.2
    var normalSheet: StyleSheet!
    var selectedSheet: StyleSheet?
    var selected = false
    weak var lastView: Decorable?
    public init(normal: StyleSheet, selected: StyleSheet? = nil, toggle: SimpleOutput<Bool>? = nil, animated: Bool = true, duration: TimeInterval = 0.2) {
        super.init(identifier: "TapSelectStyle")
        self.animated = animated
        self.duration = duration
        normalSheet = normal
        selectedSheet = selected
        _ = toggle?.outputing { value in
            self.selected = value
            if let view = self.lastView {
                self.applyStyleSheet(view: view)
            }
        }
    }

    public override func apply(to gestureStyle: GestureDecorable) {
        super.apply(to: gestureStyle)
        // 初次应用时，需要把指定的样式应用上
        applyStyleSheet(view: gestureStyle)
    }

    public override func getGesture() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer()
        let d = ShouldSimulateOtherGestureDelegate()
        tap.delegate = d
        tap.py_setUnbinder(d, for: styleIdentifier + "_delegate")
        let duration = self.duration
        let animated = self.animated
        tap.py_addAction { g in
            self.selected = !self.selected

            let action = { self.applyStyleSheet(view: g.view!) }

            if animated {
                UIView.animate(withDuration: duration) {
                    action()
                }
            } else {
                action()
            }
        }
        return tap
    }

    private func applyStyleSheet(view: Decorable) {
        if selected, let sheet = selectedSheet {
            view.applyStyleSheet(sheet)
        } else {
            view.applyStyleSheet(normalSheet)
        }
        lastView = view
    }
}
