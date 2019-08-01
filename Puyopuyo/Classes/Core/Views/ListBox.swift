//
//  ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/2.
//

import Foundation

public class ListBox<View: BoxView, Data>: UIView, UITableViewDelegate, UITableViewDataSource {
    
    public private(set) var tableView: UITableView
    private var root = VBox()
    private var data: State<[[Data]]>
    
    public var cellBlock: (UITableView, View, IndexPath, Data) -> Void = { _, _, _, _ in }
    public var didSelect: (UITableView, IndexPath, Data) -> Void = { _, _, _ in }
    
    public init(style: UITableView.Style = .plain, data: State<[[Data]]>) {
        tableView = UITableView(frame: .zero, style: style)
        self.data = data
        super.init(frame: .zero)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        root.attach(self) {
            self.tableView.attach($0).size(.ratio(1), .ratio(1))
        }
        .size(.ratio(1), .ratio(1))
        
        let unbinder = data.safeBind(self) { (self, _) in
            self.tableView.reloadData()
        }
        py_setUnbinder(unbinder, for: "listBoxUnbinder")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "id")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "id")
            cell?.contentView.addSubview(View().attach().size(.ratio(1), .ratio(1)).view)
        }
        if let view = cell?.contentView.subviews.first as? View {
            cellBlock(tableView, view, indexPath, data.value[indexPath.section][indexPath.row])
        }
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.value[section].count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return data.value.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(tableView, indexPath, data.value[indexPath.section][indexPath.row])
    }
    
}
