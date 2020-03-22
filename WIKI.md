# Puyopuyo

这是一个针对UIKit的声明式，响应式的布局系统。

Demo中几乎涵盖了所有的API使用，如果方便可以下载Demo对照查看。

- [Puyopuyo](#puyopuyo)
  * [基本特性](#基本特性)
  * [基本使用](#基本使用)
  * [布局Box](#布局box)
  * [数据管理](#数据管理)
  * [复杂View的构建方式](#复杂View的构建方式)
  * [Style样式](#Style样式)
  * [扩展性](#扩展性)
  * [动画](#动画)
  * [与其他布局混用](#与其他布局混用)
  * [获取视图的最终位置](#获取视图的最终位置)

## 基本特性

- 开发流程：使用声明式的API进行UI构建，并通过响应式的数据绑定方式，确保数据流的走向是：数据 -> View。

- 简单易用：与大多数响应式框架API类似，RN，Vue，SwiftUI等。并且可以和自动布局相结合使用。

- 高效开发：节省成员变量声明，View释放跟随父节点。内置一些常用组件，VBox，HBox，ZBox，TableBox，CollectionBox，NavigationBox。

- 布局原则：尽量一次创建View，然后通过view属性修改来进行更改布局。减少view重复创建带来的消耗。

## 基本使用

通过声明式进行UI构建

```swift
// 声明一个垂直布局
VBox().attach(view) {
    UILabel().attach($0)
        .text("i am a text")
        .size(.wrap(add: 20), 100)

    UIButton().attach($0)
        .text("i am a button")
        .size(.fill, .wrap)
}

```

## 布局Box

内置Box布局系统，方便高效地构建UI

BoxView

|------ ZBox

|------ FlatBox

|-------|------ HBox

|-------|------ VBox

|------ FlowBox

|-------|------ HFlow

|-------|------ VFlow

Box布局通过Regulator的属性，对Box的布局方式进行设置。

每个View都是一个可测量对象`Measurable` 和 `MeasureTargetable`

```swift
public protocol Measurable {
    func caculate(byParent parent: Measure, remain size: CGSize) -> Size
}

public protocol MeasureTargetable: class {
    var py_size: CGSize { get set }
    var py_center: CGPoint { get set }
    func py_enumerateChild(_ block: (Int, Measure) -> Void)
    func py_sizeThatFits(_ size: CGSize) -> CGSize    
}
```

Box通过计算View的center和size来进行布局。并且view可以通过 `py_measure` 来获取测量对象。

## 数据管理

Puyopuyo的数据流是响应式的，通过定义State进行数据的赋值以及修改。对于一个View来说，在开发的生命周期过程中无非完成两项工作，通过输入数据进行展示，通过输出事件来回调响应。

State实现了Inputing，Outputing协议。

```swift
/// 解绑器
public protocol Unbinder {
    func py_unbind()
}
/// 输出接口
public protocol Outputing {
    associatedtype OutputType
    func outputing(_ block: @escaping (OutputType) -> Void) -> Unbinder
}
/// 输入接口
public protocol Inputing {
    associatedtype InputType
    func input(value: InputType)
}
public class State<Value>: Outputing, Inputing {
    public typealias OutputType = Value
    public typealias InputType = Value
    ...
}
```

通过上述代码，State只是其中一个实现。也可以通过其他方式进行实现。比如结合Rx：

```swift
extension Observable: Outputing {
    public typealias OutputType = Element

    public func outputing(_ block: @escaping (Element) -> Void) -> Unbinder {
        let d = subscribe(onNext: { value in
            block(value)
        })
        return Unbinders.create {
            d.dispose()
        }
    }
}
extension PublishSubject: Inputing {
    public typealias InputType = Element
    public func input(value: Element) {
        onNext(value)
    }
}
```

使用

```swift
// 创建一个State
let textState = State("")
HBox().attach(view) {
     UILabel().attach($0)
         .text(textState) // 绑定state
     UIButton().attach($0)
         .text("i am a button")
           // 绑定UIControl事件
         .onEvent(.touchUpInside, SimpleInput { sender in
            print("button clicked !!! ")
         })
 }
// 修改数据源，绑定的Label将自动更新。另外数据和UI没有相互引用。
textState.input(value: "i am a new text")
```



## 复杂View的构建方式

复杂界面的构建原则也应该遵循Inputing，Outputing方式。因此Puyo提供了两个接口，来约束自定义view的构建方式。

`Stateful` 和 `Eventable`

```swift
public protocol Stateful {
    associatedtype StateType
    var viewState: State<StateType> { get }
}

public protocol Eventable {
    associatedtype EventType
    var eventProducer: SimpleIO<EventType> { get }
}
```

当我们构建一个复杂view的时候，需要自定义state，或者event，或者两者都需要（按需定义），这里给出一个都需要的情况：

```swift
class CustomView: UIView, Stateful, Eventable {
    // 自定义State
    struct ViewState {
        var title: String?
        var count = 1
    }
    // 自定义回调事件
    enum Event {
        case onClick
    }
    var viewState = State(ViewState())
    var eventProducer = SimpleIO<Event>()
    override init(frame: CGRect) {
        super.init(frame: frame)
        attach {
            VBox().attach($0) {
                UILabel().attach($0)
                    .text(self._state.map { $0.title }) // view 绑定数据
                UILabel().attach($0)
                    .text(self._state.map { $0.count.description }) // view绑定数据

                UIButton().attach($0)
                    .addWeakAction(to: self, for: .touchUpInside, { (this, _) in
                        // 回调事件
                        this.emmit(.onClick)
                    })
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// 使用
let state = State(CustomView.ViewState())
VBox().attach {
    CustomView().attach($0)
        .viewState(state) // 绑定状态
        .onEventProduced(SimpleInput { event in
            // 事件回调
            switch event {
            case .onClick:
                print("clicked~~~")
            }
        })
}
state.value.title = "nwe text"
state.value.count = 99
```

## Style样式

在View开发过程中，常常会因为一些通用UI样式问题，而向上抽象一些基类，比如`TitleLabel` 文字加粗且大，`RoundedButton`圆角按钮等，其实在Web端开发的时候，CSS是一个很好的样式和UI分离的一个做法。

Puyo内置了一个Style接口，并且UIView默认实现了该接口，可以是样式和UI基类互相分离，当然也是针对场景，基类当然不能完全抛弃。

```swift
@objc public protocol Style {
    func apply(to decorable: Decorable)
}
extension UIView: Decorable {}

// 自定义style

class CustomStyles {
    static func titleStyle() -> [Style] {
        [
            UIFont.systemFont(ofSize: 16, weight: .bold),
            TextColorStyle(value: .red, state: .normal),
            TextAlignmentStyle(value: .right, state: .normal),
            (\UIView.layer.cornerRadius).getStyle(with: 12),
        ]
    }
}

// 使用
UILabel().attach($0)
    .styles(CustomStyles.titleStyle())
```

Style其实只是一个执行接口，并没有规定实现Style的是什么，所以Style也可以用于手势，内部实现的有：

```swift
UILabel().attach()
    .userInteractionEnabled(true)
    .style(TapRippleStyle()) // Material的涟漪效果
    .style(TapScaleStyle()) // 点击改变大小
```

**注意：Style实现只会应用到View上，并不会主动移除，自定义的时候，需要考虑重复添加问题。**

## 扩展性

因为声明式API和UIKit的原生设计本来就不一致，所以声明式API都需要自己进行二次实现。Puyopuyo使用的方式是使用中间类，Puyo，进行扩展。（当然也是因为UIKit中有众多的UI组件，个人能力有限，无法全部扩展完，在使用过程中如果有遇到不方便的，可以自行扩展，并希望能提**PR**合并到代码库中）

例如：**UISlider**

```swift
public extension Puyo where T: UISlider {
    @discardableResult
    func value<O: Outputing>(_ value: O) -> Self where O.OutputType == Float {
        value.asOutput().distinct().safeBind(to: view) { v, s in
            v.value = s
        }
        return self
    }
}
let value = State<Float>(0)
UISlider().attach().value(value)
value.input(value: 0.5)
```

## 动画

因为库是基于UIKit的，所以动画必然也是基于UIKit。BoxView提供`animator`属性。在BoxView执行 `layoutSubviews` 时，使用该对象提供的方法进行动画。

```swift
public protocol Animator {
    func animate(view: UIView, layouting: @escaping () -> Void)
}

// 自定义动画
public struct CustomAnimator: Animator {}

VBox().attach()
    .animator(Animators.none) // 默认值
    .animator(Animators.default) // 默认动画
```

## 与其他布局混用

Box布局的所有布局属性都依赖于`activate = true`，默认也是true。当想和其他布局一同使用，或者不想当前视图被box控制的话，可以设置为false，然后再设置其他布局属性，例如Autolayout的约束。

```swift
VBox().attach {
    UILabel().attach($0)
        // VBox将忽略本视图的计算
        .activate(false) 
        // 忽略之后可以直接设置其位置，该API只能用于 activate = false 的时候
        .frame(x: 0, y: 0, w: 100, h: 100) 
}
```

## 获取视图的最终位置

可以通过相关API获取，具体内部实现为**KVO**。

```swift
UIView().attach()
    .onBoundsChanged(SimpleInput { bounds in
        // bounds 
    })
    .onFrameChanged(SimpleInput { frame in
        // frame
    })
    .onCenterChanged(SimpleInput { center in
        // center
    })
```
