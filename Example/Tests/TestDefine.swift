//
//  TestDefine.swift
//  Puyopuyo_Tests
//
//  Created by J on 2022/5/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

#if true
typealias LinearBag = LinearBox
typealias HBag = HBox
typealias VBag = VBox
typealias FlowBag = FlowBox
typealias HFlowBag = HFlow
typealias VFlogBag = VFlow
typealias ZBag = ZBox
#else
typealias LinearBag = LinearGroup
typealias HBag = HGroup
typealias VBag = VGroup
typealias FlowBag = FlowGroup
typealias HFlowBag = HFlowGroup
typealias VFlogBag = VFlowGroup
typealias ZBag = ZGroup
#endif
