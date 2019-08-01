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
@objc public class VisibleViewController: UIViewController {
    
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
        
        VBox().attach(view) {
            
            HBox().attach($0)
                .size(.fill, height)
            
            VBox().attach($0) {
                UILabel().attach($0)
                    .text("123")
                    .visible(self.visible)
                }
                .size(.fill, .wrap)
            }
            .space(8)
            .padding(all: nil, top: 20, left: 8, bottom: 8, right: 8)
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
