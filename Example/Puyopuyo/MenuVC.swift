//
//  MenuVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/6/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class MenuVC: BaseVC {
    
    var data: [(String, UIViewController.Type)] = [
        ("Flat1", Flat1VC.self),
        ("Visible", VisibleViewController.self),
        ("Colors", StyleTestViewController.self),
        ("ListBox", ListBoxVC.self),
    ]
    
    lazy var tableView: UITableView = {
        let v = UITableView(frame: view.bounds, style: .plain)
        v.dataSource = self
        v.delegate = self
        v.register(UITableViewCell.self, forCellReuseIdentifier: "id")
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.attach(vRoot).size(.ratio(1), .ratio(1))
    }

}

extension MenuVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "id") else { fatalError() }
        cell.textLabel?.text = data[indexPath.row].0
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = data[indexPath.row].1.init()
        navigationController?.pushViewController(vc, animated: true)
    }
}
