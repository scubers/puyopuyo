//
//  Utils.swift
//  Puyopuyo
//
//  Created by J on 2022/5/15.
//

import Foundation

extension Comparable {
    mutating func replaceIfLarger(_ value: Self) {
        self = Swift.max(value, self)
    }

    mutating func replaceIfSmaller(_ value: Self) {
        self = Swift.min(value, self)
    }
}

extension CGSize {
    static func sizeByWidth(_ width: CGFloat, aspectRatio: CGFloat) -> CGSize {
        assert(aspectRatio > 0)
        return CGSize(width: width, height: width / aspectRatio)
    }

    static func sizeByHeight(_ height: CGFloat, aspectRatio: CGFloat) -> CGSize {
        assert(aspectRatio > 0)
        return CGSize(width: height * aspectRatio, height: height)
    }

    func ensureNotNegative() -> CGSize {
        return CGSize(width: Swift.max(0, width), height: Swift.max(0, height))
    }

    func expand(to aspectRatio: CGFloat?) -> CGSize {
        guard let aspectRatio = aspectRatio, aspectRatio > 0, self != .zero else {
            return self
        }

        guard width != 0, height != 0 else {
            if width == 0 {
                return CGSize.sizeByHeight(height, aspectRatio: aspectRatio)
            } else {
                return CGSize.sizeByWidth(width, aspectRatio: aspectRatio)
            }
        }

        let currentAspectRatio = width / height

        if currentAspectRatio > aspectRatio {
            return CGSize.sizeByWidth(width, aspectRatio: aspectRatio)
        } else if currentAspectRatio < aspectRatio {
            return CGSize.sizeByHeight(height, aspectRatio: aspectRatio)
        } else {
            return self
        }
    }

    func collapse(to aspectRatio: CGFloat?) -> CGSize {
        guard let aspectRatio = aspectRatio, aspectRatio > 0 else {
            return self
        }

        guard width != 0, height != 0 else {
            return .zero
        }

        let currentAspectRatio = width / height

        if currentAspectRatio > aspectRatio {
            return CGSize.sizeByHeight(height, aspectRatio: aspectRatio)
        } else if currentAspectRatio < aspectRatio {
            return CGSize.sizeByWidth(width, aspectRatio: aspectRatio)
        } else {
            return self
        }
    }

    func clip(by clipper: CGSize) -> CGSize {
        CGSize(width: Swift.min(width, clipper.width), height: Swift.min(height, clipper.height))
            .ensureNotNegative()
    }

    func expand(edge: UIEdgeInsets) -> CGSize {
        return CGSize(width: width + edge.getHorzTotal(), height: height + edge.getVertTotal())
    }

    func collapse(edge: UIEdgeInsets) -> CGSize {
        return CGSize(width: width - edge.getHorzTotal(), height: height - edge.getVertTotal())
    }
}

extension CGFloat {
    func clipDecimal(_ value: Int) -> CGFloat {
        let sign: CGFloat = value > 0 ? 1 : -1
        let intValue = Int(Swift.abs(self))
        let decimalValue = Swift.abs(self) - CGFloat(intValue)
        let factor = pow(10, CGFloat(value))
        let decimal = CGFloat(Int(decimalValue * factor)) / factor
        return (CGFloat(intValue) + decimal) * sign
    }
}

enum DiagnosisUitl {
    static func startDiagnosis(measure: Measure, residual: CGSize, intrinsic: CGSize, msg: String?) {
        #if DEBUG
        guard measure.diagnosisId != nil else { return }
        let content = """

        >>>>>>>>>> [Calculation diagnosis\(msg == nil ? "" : ": \(msg!)")] >>>>>>>>>>
        \(measure.diagnosisMessage)
        >>>>>>>>>> Result
        - Residual: [width: \(residual.width), height: \(residual.height)]
        - Intrinsic: [width: \(intrinsic.width), height: \(intrinsic.height)]
        >>>>>>>>>> [Calculation diagnosis] >>>>>>>>>>

        """
        print(content)
        #endif
    }

    static func constraintConflict(crash: Bool, _ msg: String) {
        #if DEBUG
        let message = "[Puyopuyo] Constraint conflict: \(msg)"
        if crash {
            fatalError(message)
        } else {
            print(message)
        }
        #endif
    }
}
