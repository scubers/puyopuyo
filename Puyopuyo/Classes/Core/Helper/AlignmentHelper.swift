//
//  AlignmentHelper.swift
//  Puyopuyo
//
//  Created by J on 2022/5/15.
//

import Foundation

enum AlignmentHelper {
    static func getCrossAlignmentOffset(_ measure: Measure, direction: Direction, justifyContent: Alignment, parentPadding: BorderInsets, parentSize: CGSize, semanticDirection: SemanticDirection = .leftToRight) -> CGFloat {
        let parentCalSize = parentSize.getCalFixedSize(by: direction)
        let parentCalPadding = CalEdges(insets: parentPadding, direction: direction, in: semanticDirection)

        let subCalMargin = CalEdges(insets: measure.margin, direction: direction, in: semanticDirection)
        let subFixedSize = measure.calculatedSize.getCalFixedSize(by: direction)

        let targetAlignment: Alignment = {
            if measure.alignment == .none || measure.alignment.hasCrossAligment(for: direction) {
                return measure.alignment
            }
            return justifyContent
        }()

        var calAlignment: CalAlignment
        if direction == .horizontal {
            calAlignment = CalAlignment.fetchVert(targetAlignment)
        } else {
            calAlignment = CalAlignment.fetchHorz(targetAlignment, direction: semanticDirection)
        }

        return getAlignmentPosition(
            containerSize: parentCalSize.cross,
            startPadding: parentCalPadding.forward,
            endPadding: parentCalPadding.backward,

            contentSize: subFixedSize.cross,

            startMargin: subCalMargin.forward,
            endMargin: subCalMargin.backward,

            alignment: calAlignment
        ) ?? 0
    }

    enum CalAlignment {
        case none
        case start
        case center(CGFloat)
        case end

        static func fetchHorz(_ alignment: Alignment, direction: SemanticDirection) -> CalAlignment {
            guard alignment.hasHorzAlignment || alignment.hasSemanticAlignment else {
                return .none
            }

            let align = SemanticDirectionHelper(semanticDirection: direction).transform(alignment: alignment)

            if align.contains(.left) {
                return .start
            }
            if align.contains(.right) {
                return .end
            }
            if align.contains(.horzCenter) {
                return .center(align.centerRatio.x)
            }

            fatalError()
        }

        static func fetchVert(_ alignment: Alignment) -> CalAlignment {
            guard alignment.hasVertAlignment else {
                return .none
            }

            if alignment.contains(.top) {
                return .start
            }
            if alignment.contains(.bottom) {
                return .end
            }
            if alignment.contains(.vertCenter) {
                return .center(alignment.centerRatio.y)
            }

            fatalError()
        }
    }

    static func getAlignmentPosition(
        containerSize: CGFloat,
        startPadding: CGFloat,
        endPadding: CGFloat,
        contentSize: CGFloat,
        startMargin: CGFloat,
        endMargin: CGFloat,
        alignment: CalAlignment
    ) -> CGFloat? {
        switch alignment {
        case .none:
            return nil
        case .start:
            return startPadding + startMargin + contentSize / 2
        case .end:
            return containerSize - endPadding - endMargin - contentSize / 2
        case .center(let v):
            let ratio = Swift.min(Swift.max(-1, v), 1) + 1
            let residualSpace = containerSize - startPadding - endPadding - contentSize - startMargin - endMargin
            let delta = residualSpace / 2 * ratio
            let value = startPadding + startMargin + contentSize / 2 + delta
            return value
        }
    }
}
