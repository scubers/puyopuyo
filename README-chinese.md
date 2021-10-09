# Puyopuyo

[![CI Status](https://img.shields.io/travis/scubers/Puyopuyo.svg?style=flat)](https://travis-ci.org/scubers/Puyopuyo)
[![Version](https://img.shields.io/cocoapods/v/Puyopuyo.svg?style=flat)](https://cocoapods.org/pods/Puyopuyo)
[![Platform](https://img.shields.io/cocoapods/p/Puyopuyo.svg?style=flat)](https://cocoapods.org/pods/Puyopuyo)

[English](./README.md)


介绍: 

Youtube: [https://youtu.be/3MOBCtIfRFA](https://youtu.be/3MOBCtIfRFA)

Bilibili: [https://www.bilibili.com/video/BV1Kh411J7vJ](https://www.bilibili.com/video/BV1Kh411J7vJ/)

## 描述

基于数据驱动的声明式UIKit

Puyopuyo是基于Frame进行布局，并且提供了一套响应式的数据驱动开发模型的UI框架。

## Requirements

swift 5.1

## Installation

```ruby
pod 'Puyopuyo'
```

## 使用

一个简单的菜单Cell，可以如下实现，根据不同的布局规则，子节点将根据规则自动布局。内建的布局Box遵循FlexBox规则。

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

### 框架内提供三种布局方式

`LinearBox`, `FlowBox`, `ZBox`. 继承关系如下：
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


布局的核心是UI节点描述  `Measure` `Regulator`

### Measure 属性

|属性|描述|值|
|--|--|--|
|*margin*|描述本节点的外边距| `UIEdgeInset`, default: .zero|
|*alignment*|描述本节在父布局的偏移位置|`.none, .left, .top, .bottom, .vertCenter, .horzCenter`, default: .none|
|*size*|描述本节点尺寸| `SizeDescription`, `.fixed` 固定尺寸, `.wrap` 包裹所有子节点的尺寸, `.ratio` 占剩余空间的比例；default: `.wrap`, 详情查看Demo：Size Properties|
|*flowEnding*|当前节点在 `FlowBox` 中，并且`arrangeCount = 0`才会生效，标记当前节点是否为当前行最后一个节点| `Bool`, default: false |
|*activated*|描述本节点是否参与计算| `Bool`, default: false|

### Regulator & ZBox 属性

`ZBox` 继承于 `Regulator`

|属性|描述|值|
|--|--|--|
|*justifyContent*|控制所有子节点在Box内的偏移位置，当子节点设置了 `alignment` 时，则优先使用 `alignment`| `.left, .top, .bottom, .vertCenter, .horzCenter`, default: .none |
|*padding*|控制当前布局的内边距| `UIEdgeInset`, default: .zero|

### LinearRegulator 属性

`LinearRegulator` 继承于 `Regulator`

|属性|描述|值|
|--|--|--|
|*space*|控制布局内子节点之间的间距| `CGFloat`, default: 0|
|*format*|控制子节点在主轴上的分布方式| `.leading, .center, .between, .round, .trailing`, default: .leading|
|*reverse*|控制子节点的排列方式是否于添加顺序相反| `Bool` default: false|


### FlowRegulator 属性

`FlowRegulator` 继承于 `LinearRegulator`

|属性|描述|值|
|--|--|--|
|*arrange*|控制布局内每一列的数量，当 `arrange = 0` 时，则根据内容来自动决定是否换行| `Int`, default: 0|
|*itemSpace*|控制布局单列内的节点间距| `CGFloat`, default: 0|
|*runSpace*|控制布局内每列之间的间距| `CGFloat`, default: 0|
|*format*|控制子节点在单列上的分布方式| `.leading, .center, .between, .round, .trailing`, default: .leading|
|*runFormat*|控制布局内列的分布方式| `.leading, .center, .between, .round, .trailing`, default: .leading|
|*runRowSize*|控制布局内列的分布方式| `(Int) -> SizeDescription`, default: .wrap(shrink: 1)|

## 数据驱动

声明式的UI进行布局之后，当数据变化后，UI将自动根据需要重新布局。

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

*注意：数据驱动的所有逻辑遵循RxSwift的使用逻辑，请注意内存泄露*

## 动画

View提供一个扩展属性 `view.py_animator`. 类型为 `protocol Animator {}`

在BoxView进行布局后，给子view进行位置进行赋值时，会调用该对象的`animate`方法，并且会给对应的view创建独立的动画。

*当子view没有设置动画，会沿用其父布局（BoxView）的动画*

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

具体查看 Demo: Animation

## 自定义View

因为布局自身也是一个view，所以在自定义view时，可以直接继承相应的Box。降低view层级。

```swift
class MyView: VBox {
    override func buildBody() {
        // do your view declare here
    }
}
```

### 自定义view的状态与事件管理

一个复杂的View通常以输入数据进行展示，通过抛出事件进行交互。在UIKit里面通常体现为 `DataSource, Delegate`.

在系统里，提供了一个交互模式，进行定义。

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

let state = State(MyView.state())

MyView().attach($0)
    .state(state) // bind your data source
    .onEvent(Inputs { event in
        // do your logic when event occured
    })
    
```

## 样式

系统提供 `Decorable, Style` 两个接口，进行定义样式。并给UIView提供属性 `py_styleSheet` 进行样式的设置。

详情见Demo: Style

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

## 扩展Puyo

根据常用操作，系统已经提供了声明式中常用的API，详情见 `Puyo+xxxx.swift`. 如下：

```swift
public extension Puyo where T: Eventable {
    @discardableResult
    func onEvent<I: Inputing>(_ input: I) -> Self where I.InputType == T.EmitterType.OutputType {
        let disposer = view.emitter.send(to: input)
        if let v = view as? DisposableBag {
            disposer.dispose(by: v)
        }
        return self
    }
}
```

若有更多需求，可自行扩展Puyo，期待您的贡献

## Author

Jrwong, jr-wong@qq.com

## License

Puyopuyo is available under the MIT license. See the LICENSE file for more info.
