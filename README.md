# Puyopuyo

[![CI Status](https://img.shields.io/travis/Jrwong/Puyopuyo.svg?style=flat)](https://travis-ci.org/Jrwong/Puyopuyo)
[![Version](https://img.shields.io/cocoapods/v/Puyopuyo.svg?style=flat)](https://cocoapods.org/pods/Puyopuyo)
[![License](https://img.shields.io/cocoapods/l/Puyopuyo.svg?style=flat)](https://cocoapods.org/pods/Puyopuyo)
[![Platform](https://img.shields.io/cocoapods/p/Puyopuyo.svg?style=flat)](https://cocoapods.org/pods/Puyopuyo)

## 描述

声明式响应式布局系统。

也许你觉得这只是一个语法糖，但是，的确，它就是一个语法糖。

## Requirements

swift 4.2

## Installation

```ruby
pod 'Puyopuyo'
```

## 使用

相对于亲儿子的**SwiftUI**，当然是比较麻烦一点的了。单纯地声明布局，不能实现**View** 和父**View**的关系。所以需要在后面添加一个`attach(superview)`的操作。

```swift
VBox().attach($0) {
    Label("""
        aligment = left
        width = .wrap add 20
        height = 100
        """).attach($0)
        .size(.wrap(add: 20), 100)

    Label("""
        aligment = right
        width = .wrap add 50
        height = 200
        """).attach($0)
        .aligment(.right)
        .size(.wrap(add: 50), 150)

    Label("""
        aligment = center
        width = .wrap add 80
        height = wrap
        """).attach($0)
        .aligment(.center)
        .size(.wrap(add: 80), .wrap)    

    }
    .space(10)
    .size(.fill, .wrap)
    .padding(all: 10)
    .margin(all: 10)
```

## Author

Jrwong, jr-wong@qq.com

## License

Puyopuyo is available under the MIT license. See the LICENSE file for more info.
