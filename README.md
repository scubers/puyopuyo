# Puyopuyo

[![CI Status](https://img.shields.io/travis/scubers/Puyopuyo.svg?style=flat)](https://travis-ci.org/scubers/Puyopuyo)
[![Version](https://img.shields.io/cocoapods/v/Puyopuyo.svg?style=flat)](https://cocoapods.org/pods/Puyopuyo)
[![Platform](https://img.shields.io/cocoapods/p/Puyopuyo.svg?style=flat)](https://cocoapods.org/pods/Puyopuyo)

[中文](./README-chinese.md)

## Description

A declaretive layout library for UIKit base on data driven written in swift.

## Requirements

swift 5.1

## Installation

```ruby
pod 'Puyopuyo'
```

## Usage

A simple cell can be implemented like below. The subviews will be layout by specific rules. The buildin box follow the FlexBox rules.

```swift

/**
 VBox            HBox
 |-----------|   |-------------------|
 |Title      |   |Title   Description|
 |           |   |-------------------|
 |Description|
 |-----------|
 */
 
VBox().attach {
    UILabel().attach($0)
        .text("Title")
        .fontSize(20, weight: .bold)

    UILabel().attach($0)
        .text("Description")
}
.space(20)

// or
/**
VFlow       HFlow
|-------|   |-------|
|0  1  2|   |0  3  6|
|3  4  5|   |1  4  7|
|6  7   |   |2  5   |
|-------|   |-------|
 */
VFlow(count: 3).attach {
    for i in 0..<8 {
        UILabel().attach($0)
            .text(i.description)
    }
}
.space(20)

```

### Library provide three buildin layout

`LinearBox`, `FlowBox`, `ZBox`
```swift
BoxView
    |-- ZBox
    |-- LinearBox
        |-- HBox
        |-- VBox
    |-- FlowBox
        |-- HFlow
        |-- VFlow
    
```

The core of the layout is the description of View nodes. `Measure` `Regulator`

### Measure properties

|Property|Description|Value|
|--|--|--|
|*margin*|Current view's margin| `UIEdgeInset`, default: .zero|
|*alignment*|The alignment in superview|`.none, .left, .top, .bottom, .vertCenter, .horzCenter`, default: .none|
|*size*|Size description| `SizeDescription`, `.fixed` `.wrap`, `.ratio` fill up the residual space ratio；default: `.wrap`, Demo：Size Properties|
|*flowEnding*|Only works in `FlowBox`, and the `arranceCount = 0`, it means that current view is the last view in the row| `Bool`, default: false |
|*activated*|If will be calculate by parent box| `Bool`, default: false|

### Regulator & ZBox properties

`ZBox` extends `Regulator`

|Property|Description|Value|
|--|--|--|
|*justifyContent*|Control all subview's alignment, if subview has set an alignment value, will be override by alignment| `.left, .top, .bottom, .vertCenter, .horzCenter`, default: .none |
|*padding*|Current box's padding| `UIEdgeInset`, default: .zero|

### LinearRegulator properties

`LinearRegulator` extends `Regulator`

|Property|Description|Value|
|--|--|--|
|*space*|Control the space between subviews | `CGFloat`, default: 0|
|*format*|Control the main axis alignment of subviews| `.leading, .center, .between, .round, .trailing`, default: .leading|
|*reverse*|If reverse the order from adding| `Bool` default: false|


### FlowRegulator properties

`FlowRegulator` extends `LinearRegulator`

|Property|Description|Value|
|--|--|--|
|*arrange*|Control the arrange count in each row, when `arrange = 0`, will be separate by contents| `Int`, default: 0|
|*itemSpace*|The space between items| `CGFloat`, default: 0|
|*runSpace*|The space between rows| `CGFloat`, default: 0|
|*format*|The format of the each row| `.leading, .center, .between, .round, .trailing`, default: .leading|
|*runFormat*|The format of rows| `.leading, .center, .between, .round, .trailing`, default: .leading|
|*runRowSize*|The row size in run direction| `(Int) -> SizeDescription`, default: .wrap(shrink: 1)|

## DataDriven

Library provide a data driven api, to keep your UI always representing the right data. And relayout when something changes.

```swift
let text = State("")
    
VBox().attach {
    UILabel().attach($0)
        .text("Title")

    UILabel().attach($0)
        .text(text)
}

// do when some data come back
text.value = "My Description"

// if you are using RxSwift that would be another good choise
// make `Observable` implements Outputing protocol
extension Observable: Outputing {
    public typealias OutputType = Element
    /// .... some code
}

func getDescription() -> Observable<String> {
    // get some description by network or other async works
}

// use in view declare
UILabel().attach($0)
    .text(getDescription())
```

*PS: The dataDriven api is follow the RxSwift's logic, Be aware of the memory leaks*

## Animations

`UIView` has an extension property, is an instance of `protocol Animator {}`

After BoxView layout, each subview's `center`, `bounds` will be assigned, The box will create animation for each view if needed.

*PS: If subview has no animation, will use the nearest superview's animation, the superview must be instance of BoxView*

```swift

struct ExpandAnimator: Animator {
    var duration: TimeInterval { 0.3 }
    func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
        let realSize = delegate.py_size
        let realCenter = delegate.py_center
        let view = delegate as? UIView
        if realSize != size || realCenter != center {
            // if the first time assgining
            if realSize == .zero, realCenter == .zero {
                // move to the right position without animation
                runAsNoneAnimation {
                    delegate.py_center = center
                    let scale: CGFloat = 0.5
                    delegate.py_size = CGSize(width: size.width * scale, height: size.height * scale)
                    view?.layer.transform = CATransform3DMakeRotation(.pi / 8 + .pi, 0, 0, 1)
                }
            }

            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [.curveEaseOut, .overrideInheritedOptions, .overrideInheritedDuration], animations: {
                // call animations finally to set the right size and position
                animations()
                if realSize == .zero, realCenter == .zero {
                    view?.layer.transform = CATransform3DIdentity
                }
            }, completion: nil)
        } else {
            animations()
        }
    }
}
```

Demo: Animation

## Custom View

Because of the BoxView also a view, feel free to subclassing a Box, to reduce the view's hierarchy

```swift
class MyView: VBox {
    override func buildBody() {
        // do your view declare here
    }
}
```

### State and Event

A complex view also need to be provide a data, and create some events, like click. In UIKit, also call `DataSource` and `Delegate`

Library provide a code pattern to defind a data and emit events.

```swift
class MyView: VBox, Stateful, Eventable {
    // declare your dataSource you need
    struct ViewState {
        var name: String?
        var title: String?
    }
    // declare event that will occured
    enum Event {
        case onConfirmed
    }
    /// declare in Stateful implement by this class
    let state = State(ViewState())
    /// declare in Eventable implement by this class
    let emitter = SimpleIO<Event>()

    override func buildBody() {
        attach {
            UILabel().attach($0)
                .text(state.map(\.name)) // use map to transform value

            UILabel().attach($0)
                .text(binder.title) // use binder dynamic member lookup to find value

            UIButton().attach($0)
                .text("Confirm")
                .bind(event: .touchUpInside, input: emitter.asInput { _ in .onConfirmed })
        }
    }
}

// Use view

let state = State(MyView.ViewState())

MyView().attach($0)
    .viewState(state) // bind your data source
    .onEvent(Inputs { event in
        // do your logic when event occured
    })
    
```

## Styles

Demo: Style

```swift
// declare style
let styles: [Style] = [
    (\UIView.backgroundColor).getStyle(with: .white),
    TapRippleStyle(),
    (\UILabel.text).getStyle(with: "Click"),
    (\UIView.isUserInteractionEnabled).getStyle(with: true)
]
// Use style
UILabel().attach()
    .styles(styles)
```

## Extension

See `Puyo+xxx.swift`

```swift
public extension Puyo where T: Eventable {
    @discardableResult
    func onEvent<I: Inputing>(_ input: I) -> Self where I.InputType == T.EmitterType.OutputType {
        let disposer = view.emmiter.send(to: input)
        if let v = view as? DisposableBag {
            disposer.dispose(by: v)
        }
        return self
    }
}
```

You can extension more depende on your needs, expect your contribution

## Author

Jrwong, jr-wong@qq.com

## License

Puyopuyo is available under the MIT license. See the LICENSE file for more info.
