//
//  IgnoreChangeVC.swift
//  MeiyeSetting
//
//  Created by Jrwong on 2019/8/1.
//

import UIKit
import TangramKit
import RxSwift
import Puyopuyo

/// 忽略找零
@objc class VisibleViewController: BaseVC {
    
    // MARK: - Accessor
    
    @objc public var refreshBlock: ((Bool) -> Void)?
    
    private let isOn = State(value: false)
    
    var visible: State<Visiblity> {
        return isOn.map({ (value) -> Visiblity in
            return value ? .gone : .visible
        })
    }
    
    // MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        // Do any additional setup after loading the view.
    }
}

// MARK: - Public Methods
extension VisibleViewController {
    
}

// MARK: - Private Methods
private extension VisibleViewController {
    func setupUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isOn.value = true
        }
        view.backgroundColor = .lightGray
        let height: CGFloat = 44
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.attach(vRoot) {
            VBox().attach($0) {
                
                HBox().attach($0) {
                    
                    UILabel().attach($0)
                        .text("收款时合计金额抹除角分金额")
                        .font(UIFont.systemFont(ofSize: 16))
                        .size(.fill, .fill)
                    
                    UISwitch().attach($0)
                        .onValueChange({ [weak self] (value) in
                            //                        self?.refreshBlock?(value)
                            self?.changeState(value)
                            self?.isOn.value = (value)
                        })
                    //                    .isOn(self.isOn)
                    //                    .size(.wrap, .wrap)
                    }
                    .padding(all: 8)
                    .backgroundColor(.white)
                    .justifyContent(.center)
                    .size(.fill, height)
                
                self.getSectionLabel("开启后，如收款合计金额有角分金额，将自动抹零。").attach($0)
                
                UIView().attach($0)
                    .size(.fill, 30)
                
                self.getSectionLabel("示例预览").attach($0)
                
                VBox().attach($0) {
                    
                    self.getTemplateView(title: "合计", value: "￥ 179.42").attach($0)
                        .size(.fill, height)
                    
                    self.getTemplateView(title: "抹零", value: "￥ 0.42").attach($0)
                        .visible(self.visible)
                        .size(.fill, height)
                    
                    self.getTemplateView(title: "应收金额", value: "￥ 179.42").attach($0)
                        .visible(self.visible)
                        .size(.fill, height)
                    
                    self.getTemplateView(title: "应收金额", value: "￥ 179.00").attach($0)
                        .visible(self.visible)
                        .size(.fill, height)
                    }
                    .size(.fill, .wrap)
                
                }
                .space(8)
                .padding(all: nil, top: 20, left: 8, bottom: 8, right: 8)
                .size(.fill, .fill)
        }
            .size(.fill, .fill)
        
    }
    
    func getSectionLabel(_ title: String?) -> UILabel {
        let v = UILabel()
        v.text = title
        v.font = UIFont.systemFont(ofSize: 12)
        return v
    }
    
    func getTemplateView(title: String, value: String) -> UIView {
        return
            HBox().attach(nil) {
                
                UILabel().attach($0)
                    .font(UIFont.systemFont(ofSize: 16))
                    .text(title)
                
                UILabel().attach($0)
                    .font(UIFont.systemFont(ofSize: 16))
                    .text(value)
                }
                .justifyContent(.center)
                .formation(.sides)
                .padding(all: 8)
                .backgroundColor(UIColor.white)
                .view
    }
    
    func bindViewModel() {
        
    }
    
    func changeState(_ value: Bool) {
    }
}
