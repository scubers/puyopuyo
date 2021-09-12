# Puyopuyo

[![CI Status](https://img.shields.io/travis/scubers/Puyopuyo.svg?style=flat)](https://travis-ci.org/scubers/Puyopuyo)
[![Version](https://img.shields.io/cocoapods/v/Puyopuyo.svg?style=flat)](https://cocoapods.org/pods/Puyopuyo)
[![Platform](https://img.shields.io/cocoapods/p/Puyopuyo.svg?style=flat)](https://cocoapods.org/pods/Puyopuyo)

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

```swift

```

布局的核心是UI节点描述  `Measure` `Regulator`

### Measure 属性

|属性|描述|值|
|--|--|--|
|*margin*|描述本节点的外边距| `UIEdgeInset`, default: .zero|
|*alignment*|描述本节在父布局的偏移位置|`.none, .left, .top, .bottom, .vertCenter, .horzCenter`, default: .none|
|*size*|描述本节点尺寸| `SizeDescription`, `.fixed` 固定尺寸, `.wrap` 包裹所有子节点的尺寸, `.ratio` 占剩余空间的比例；default: `.wrap`|
|*flowEnding*|当前节点在 `FlowBox` 中，并且`arrangeCount = 0`才会生效，标记当前节点是否为当前行最后一个节点| `Bool`, default: false |
|*activated*|描述本节点是否参与计算| `Bool`, default: false|

### Regulator & ZBox 属性

`ZBox` 继承于 `Regulator`

|属性|描述|值|
|--|--|--|
|*justifyContent*|控制所有子节点在Box内的偏移位置，当子节点设置了 `alignment` 时，则优先使用 `alignment`| `.left, .top, .bottom, .vertCenter, .horzCenter`, default: .none |
|*padding*|控制当前布局的内边距| `UIEdgeInset`, default: .zero|

### FlatRegulator 属性

`FlatRegulator` 继承于 `Regulator`

|属性|描述|值|
|--|--|--|
|*space*|控制布局内子节点之间的间距| `CGFloat`, default: 0|
|*format*|控制子节点在主轴上的分布方式| `.leading, .center, .between, .round, .trailing`, default: .leading|
|*reverse*|控制子节点的排列方式是否于添加顺序相反| `Bool` default: false|


### FlowRegulator 属性

`FlowRegulator` 继承于 `FlatRegulator`

|属性|描述|值|
|--|--|--|
|*arrange*|控制布局内每一列的数量，当 `arrange = 0` 时，则根据内容来自动决定是否换行| `Int`, default: 0|
|*itemSpace*|控制布局单列内的节点间距| `CGFloat`, default: 0|
|*runSpace*|控制布局内每列之间的间距| `CGFloat`, default: 0|
|*format*|控制子节点在单列上的分布方式| `.leading, .center, .between, .round, .trailing`, default: .leading|
|*runFormat*|控制布局内列的分布方式| `.leading, .center, .between, .round, .trailing`, default: .leading|
|*runRowSize*|控制布局内列的分布方式| `(Int) -> SizeDescription`, default: .wrap(shrink: 1)|



## Author

Jrwong, jr-wong@qq.com

## License

Puyopuyo is available under the MIT license. See the LICENSE file for more info.
