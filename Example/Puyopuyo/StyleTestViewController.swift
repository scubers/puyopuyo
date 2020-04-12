//
//  StyleTestViewController.swift
//  Puyopuyo_Example
//
//  Created by Junren Wong on 2019/6/28.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import RxSwift
import UIKit

class StyleTestViewController: BaseVC {
    let text = BehaviorSubject(value: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func color(hex hexString: String) -> UIColor? {
        guard hexString.count == 6 else {
            return nil
        }
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    func setupViews() {
        UIScrollView().attach(vRoot) {
            VBox().attach($0) {
                VBox().attach($0) {
                    UITextField().attach($0)
                        .bind(to: self, event: .editingChanged, action: { this, v in
                            this.text.onNext(v.text ?? "")
                        })
                        .backgroundColor(State(.lightGray).asOutput().some())
                        .size(100, 40)
                    
                    UIView().attach($0)
                        .backgroundColor(self.text.map { [weak self] in self?.color(hex: $0) })
                        .borderWidth(Util.pixel(1))
                        .borderColor(State(Optional.some(UIColor.blue)))
                        .size(100, 40)
                }
                .size(.fill, .wrap)
                
                VBox().attach($0) {
                    self.getDescriptionLabel(text: "字体(Font size)").attach($0)
                    self.getDescriptionLabel(text: "Large Title: 32", fontSize: 32).attach($0)
                    self.getDescriptionLabel(text: "Head line: 18", fontSize: 18).attach($0)
                    self.getDescriptionLabel(text: "Sub Head line: 16", fontSize: 16).attach($0)
                    self.getDescriptionLabel(text: "Primary: 14", fontSize: 14).attach($0)
                    self.getDescriptionLabel(text: "Secondary: 12", fontSize: 12).attach($0)
                    self.getDescriptionLabel(text: "Tertiary: 10", fontSize: 10).attach($0)
                    self.getDescriptionLabel(text: "Quaternary: 8", fontSize: 8).attach($0)
                }
                .space(5)
                
                VBox().attach($0) {
                    HBox().attach($0) {
                        self.getDescriptionLabel(text: "背景色(Background color)").attach($0).size(100, 30)
                        self.getDescriptionLabel(text: "字体色(Text color)").attach($0).size(.wrap, 30)
                    }
                    .space(20)
                    
                    HBox().attach($0) {
                        self.getColorView(colorString: "#ffffff").attach($0).size(100, 50)
                        self.getDescriptionLabel(text: "Primary", color: "#333333").attach($0)
                    }
                    .space(20)
                    
                    HBox().attach($0) {
                        self.getColorView(colorString: "#dddddd").attach($0).size(100, 50)
                        self.getDescriptionLabel(text: "Secondary", color: "#555555").attach($0)
                    }
                    .space(20)
                    
                    HBox().attach($0) {
                        self.getColorView(colorString: "#bbbbbb").attach($0).size(100, 50)
                        self.getDescriptionLabel(text: "Tertiary", color: "#666666").attach($0)
                    }
                    .space(20)
                    
                    HBox().attach($0) {
                        self.getColorView(colorString: "#999999").attach($0).size(100, 50)
                        self.getDescriptionLabel(text: "Quaternary", color: "#777777").attach($0)
                    }
                    .space(20)
                }
                .space(5)
                
                VBox().attach($0) {
                    self.getDescriptionLabel(text: "主题色(Theme)").attach($0)
                    
                    HBox().attach($0) {
                        self.getColorView(colorString: "#D03B5C").attach($0).size(100, 50)
                        self.getDescriptionLabel(text: "主题色").attach($0)
                    }
                    .space(20)
                    
                    HBox().attach($0) {
                        self.getColorView(colorString: "#EE8800").attach($0).size(100, 50)
                        self.getDescriptionLabel(text: "主题描边色").attach($0)
                    }
                    .space(20)
                    
                    HBox().attach($0) {
                        self.getColorView(colorString: "#FF4444").attach($0).size(100, 50)
                        self.getDescriptionLabel(text: "辅助填充色").attach($0)
                    }
                    .space(20)
                    
                    HBox().attach($0) {
                        self.getColorView(colorString: "#C9C9C9").attach($0).size(100, 50)
                        self.getDescriptionLabel(text: "边框颜色").attach($0)
                    }
                    .space(20)
                    
                    HBox().attach($0) {
                        self.getColorView(colorString: "#666B77").attach($0).size(100, 50)
                        self.getDescriptionLabel(text: "导航栏颜色").attach($0)
                    }
                    .space(20)
                }
                .space(5)
                
                self.getMeiyeColors().attach($0)
            }
            .padding(top: 10, left: 20, right: 20)
            .space(20)
            .width(.ratio(1))
            .justifyContent(.left)
        }
        .size(.ratio(1), .ratio(1))
    }
    
    func getMeiyeColors() -> UIView {
        return
            VBox().attach { x in
                    
                    self.getDescriptionLabel(text: "iOS美业的颜色").attach(x)
                    
                    self.colors.enumerated().forEach { idx, color in
                        HBox().attach(x) {
                            self.getColorView(colorString: color).attach($0).size(100, 30)
                            self.getDescriptionLabel(text: color).attach($0)
                            self.getDescriptionLabel(text: "\(idx)").attach($0)
                        }
                        .space(10)
                    }
                }
                .space(5)
                .view
    }
    
    func getColorView(colorString: String) -> UIView {
        let v = UIView()
        v.backgroundColor = .init(hexString: colorString)
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.black.cgColor
        return v
    }
    
    func getDescriptionLabel(text: String, color: String = "#000000", fontSize: CGFloat = 16) -> UILabel {
        let v = UILabel()
        v.textColor = .init(hexString: color)
        v.text = text
        v.font = UIFont.systemFont(ofSize: fontSize)
        return v
    }
    
    var colors = [
        "0xD03B5C",
        "0xF6A623",
        "0xEE8800",
        "0xFF4444",
        "0xC9C9C9",
        "0x666B77",
        "0x333333",
        "0x666666",
        "0x999999",
        "0xCBCBCB",
        "0x7F848D",
        "0xbbbbbb",
        "0xF2F2F2",
        "0x8b8b8b",
        "0xEEEEEE",
        "0xF8F8F8",
        "0xFAFAFA",
        "0xFCFCFC",
        "0xC7C7C7",
        "0x4990E2",
        "0x4A90E2",
        "0xE74C75",
        "0xF7F7F7",
        "0xF6A623",
        "0x7ED321",
        "0x21D377", // 折扣卡
        "0xAAE03C",
        "0xF76B1C", // 次卡
        "0xF6BE4E",
        "0x189CD5", // 充值卡
        "0x50EDC9",
        "0xEE5959", // 组合卡
        "0xF5A373",
        "0x7ED321",
        "0xE84C75",
        "0xFFFEEE",
        "0xFFFFFF",
        "0x00000F",
        "0xEDEDED",
        "0xE84C75",
        "0xE6E6E6",
        "0xFCEDF1",
        "0xE74C75",
        "0xED809D",
        "0xECF3FC",
        "0x4A90E2",
        "0x7AADE9",
        "0xECF8E5",
        "0x44BB00",
        "0x7ED321",
        "0x3F3F3F",
        "0x111111",
        "0x555555",
        "0xD2D2D2",
        "0x9B9B9B",
        "0xE5E5E5",
        "0xF4F4F4",
        "0xDDDDDD",
        "0xE74C75",
        "0xFFF3F6",
        "0x7ED321",
        "0xB3B3B3",
        "0x464646",
        "0xF2F2F2",
        "0xFF4444",
        "0xf7f9fb",
        "0xE74C75",
        "0xE8603B",
        "0xE77F45",
        "0x835E1E",
        "0xA3564C",
        "0x4F8866",
        "0x4E89A0",
        "0x7A7196",
        "0x6F6F6F",
        "0x505B6B",
        "0xDED7C2",
        "0x21BF8F",
        "0x1DB788",
        "0xf6f7f8",
        "0xfdf1f4",
        "0x3488E0",
        "0x23ABE3"
    ]
}

extension UIColor {
    // Hex String -> UIColor
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
