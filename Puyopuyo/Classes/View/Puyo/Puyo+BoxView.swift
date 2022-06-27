//
//  Puyo+ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/2.
//

import Foundation

// MARK: - BoxView

public extension Puyo where T: BoxView {
    @discardableResult
    func autoJudgeScroll(_ judge: Bool) -> Self {
        set(\T.isScrollViewControl, judge)
    }

//    @discardableResult
//    func centerControl(_ control: BoxView.RootBoxConfig.ControlType) -> Self {
//        set(\T.rootBoxConfig.centerControl, control)
//    }

//    @discardableResult
//    func sizeControl(_ control: BoxView.RootBoxConfig.ControlType) -> Self {
//        set(\T.rootBoxConfig.sizeControl, control)
//    }

    @discardableResult
    func borders(_ options: [BorderOptions]) -> Self {
        set(\T.borders, Borders.all(Border(options: options)))
    }

    @discardableResult
    func topBorder(_ options: [BorderOptions]) -> Self {
        set(\T.borders.top, Border(options: options))
    }

    @discardableResult
    func leftBorder(_ options: [BorderOptions]) -> Self {
        set(\T.borders.left, Border(options: options))
    }

    @discardableResult
    func bottomBorder(_ options: [BorderOptions]) -> Self {
        set(\T.borders.bottom, Border(options: options))
    }

    @discardableResult
    func rightBorder(_ options: [BorderOptions]) -> Self {
        set(\T.borders.right, Border(options: options))
    }
}

public extension Puyo where T: RegulatorSpecifier & AutoDisposable {
    @discardableResult
    func padding(all: CGFloatable? = nil,
                 horz: CGFloatable? = nil,
                 vert: CGFloatable? = nil,
                 top: CGFloatable? = nil,
                 left: CGFloatable? = nil,
                 bottom: CGFloatable? = nil,
                 right: CGFloatable? = nil) -> Self
    {
        PuyoHelper.padding(for: view.regulator, all: all?.cgFloatValue, horz: horz?.cgFloatValue, vert: vert?.cgFloatValue, top: top?.cgFloatValue, left: left?.cgFloatValue, bottom: bottom?.cgFloatValue, right: right?.cgFloatValue)
        return self
    }

    @discardableResult
    func padding<S: Outputing>(all: S? = nil, horz: S? = nil, vert: S? = nil, top: S? = nil, left: S? = nil, bottom: S? = nil, right: S? = nil) -> Self where S.OutputType: CGFloatable {
        if let s = all {
            doOn(s) { PuyoHelper.padding(for: $0.regulator, all: $1.cgFloatValue) }
        }
        if let s = top {
            doOn(s) { PuyoHelper.padding(for: $0.regulator, top: $1.cgFloatValue) }
        }
        if let s = horz {
            doOn(s) { PuyoHelper.padding(for: $0.regulator, horz: $1.cgFloatValue) }
        }
        if let s = vert {
            doOn(s) { PuyoHelper.padding(for: $0.regulator, vert: $1.cgFloatValue) }
        }
        if let s = left {
            doOn(s) { PuyoHelper.padding(for: $0.regulator, left: $1.cgFloatValue) }
        }
        if let s = bottom {
            doOn(s) { PuyoHelper.padding(for: $0.regulator, bottom: $1.cgFloatValue) }
        }
        if let s = right {
            doOn(s) { PuyoHelper.padding(for: $0.regulator, right: $1.cgFloatValue) }
        }
        return self
    }

    @discardableResult
    func padding<O: Outputing>(_ padding: O) -> Self where O.OutputType == UIEdgeInsets {
        set(\T.regulator.padding, padding)
    }

    @discardableResult
    func justifyContent(_ alignment: Alignment) -> Self {
        set(\T.regulator.justifyContent, alignment)
    }

    @discardableResult
    func justifyContent<O: Outputing>(_ alignment: O) -> Self where O.OutputType == Alignment {
        set(\T.regulator.justifyContent, alignment)
    }
}

// MARK: - Delegatable & DataSourceable

public extension Puyo where T: Delegatable {
    @discardableResult
    func setDelegate(_ delegate: T.DelegateType, retained: Bool = false) -> Self {
        view.setDelegate(delegate, retained: retained)
        return self
    }
}

public extension Puyo where T: DataSourceable {
    @discardableResult
    func setDataSource(_ dataSource: T.DataSourceType, retained: Bool = false) -> Self {
        view.setDataSource(dataSource, retained: retained)
        return self
    }
}
