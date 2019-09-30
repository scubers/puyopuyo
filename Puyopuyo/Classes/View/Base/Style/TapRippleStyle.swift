//
//  TapCoverStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

// MARK: - TapCoverStyle
public class TapRippleStyle<T: GestureStyleable>: TapGestureStyle<T> {
    
    var color: UIColor = UIColor.lightGray.withAlphaComponent(0.6)
    public init(color: UIColor? = nil) {
        super.init(identifier: "TapRippleStyle") { (_) in }
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
        round.zPosition = 100000
        round.masksToBounds = true
        view.layer.addSublayer(round)
        let duration: Double = 0.5
        let big = CABasicAnimation(keyPath: "path")
        big.duration = duration
        let size = view.bounds.size
        big.toValue = UIBezierPath(arcCenter: point, radius: max(size.height, size.width), startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true).cgPath
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
public class TapCoverStyle<T: GestureStyleable>: TapGestureStyle<T> {
    var color: UIColor = UIColor.lightGray.withAlphaComponent(0.6)
    public init(color: UIColor? = nil) {
        super.init(identifier: "TapCoverStyle") { (_) in }
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
    
    class Gesture: UIGestureRecognizer {
        private var color: UIColor = UIColor.lightGray.withAlphaComponent(0.4)
        init(color: UIColor?) {
            super.init(target: nil, action: nil)
            if let color = color { self.color = color }
        }
        private var layer = CAShapeLayer()
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
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
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
            dismissLayer()
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
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
