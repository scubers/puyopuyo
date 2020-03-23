# Puyopuyo

[![CI Status](https://img.shields.io/travis/scubers/Puyopuyo.svg?style=flat)](https://travis-ci.org/scubers/Puyopuyo)
[![Version](https://img.shields.io/cocoapods/v/Puyopuyo.svg?style=flat)](https://cocoapods.org/pods/Puyopuyo)
[![Platform](https://img.shields.io/cocoapods/p/Puyopuyo.svg?style=flat)](https://cocoapods.org/pods/Puyopuyo)

## 描述

一个UIKit的声明式、响应式布局。

被一个大佬的库和**SwiftUI**所启发。[TangramKit](https://github.com/youngsoft/TangramKit)

具体详细使用方式可以查看**Demo**使用，或者查看[**WIKI**](https://github.com/scubers/puyopuyo/blob/master/WIKI.md)。

## Requirements

swift 5.1

## Installation

```ruby
pod 'Puyopuyo'
```

## 使用

相对于亲儿子的**SwiftUI**，当然是比较麻烦一点的了。单纯地声明布局，不能实现**View** 和父**View**的关系。所以需要在后面添加一个`attach(superview)`的操作。

```swift
// 初始化一个view，附着在一个父view上，完成view的构建，并设置其相关属性
VBox().attach(view) {
    UILabel().attach($0)
        .text("i am a text")
        .size(.wrap(add: 20), 100)

    UIButton().attach($0)
        .text("i am a button")
        .size(.fill, .wrap)
}
```

一旦我们通过声明布局后，即可以不需要成员变量持有view，所有view也都可以跟随着父视图销毁时同时销毁。

数据流变化：

通过State，进行view和数据之间的绑定操作

```swift
// 创建一个state
let textState = State("")

HBox().attach(view) {
    UILabel().attach($0)
        .text(textState) // 绑定state
}
// state值改变
textState.input(value: "i am a new text")
```

拥抱响应式，从此规范数据流，让UI构建更流畅！！！

## Author

Jrwong, jr-wong@qq.com

## License

Puyopuyo is available under the MIT license. See the LICENSE file for more info.
