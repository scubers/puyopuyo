//
//  BasicListRow.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/18.
//

import Foundation

public class BasicSequenceItem<Data>: ISequenceItem {
    
    public typealias Context = RecycleContext<Data, UITableView>
    public init(
        id: String? = nil,
        selectionStyle: UITableViewCell.SelectionStyle = .default,
        rowHeight: CGFloat? = nil,
        estimatedRowHeight: CGFloat? = nil,
        data: Data,
        differ: ((Data) -> String)? = nil,
        _cell: @escaping SequenceViewGenerator<Data>,
        _cellConfig: ((UITableViewCell) -> Void)? = nil,
        _didSelect: ((Context) -> Void)? = nil,
        function: StaticString = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        self.id = id ?? "\(line)\(column)\(function)"
        self.data = data
        self.cellGen = _cell
        self.differ = differ
        self._didSelect = _didSelect
        self.rowHeight = rowHeight
        self.estimatedRowHeight = estimatedRowHeight
        self.selectionStyle = selectionStyle
    }
    
    public let id: String
    public var data: Data
    private let cellGen: SequenceViewGenerator<Data>
    private var rowHeight: CGFloat?
    private var estimatedRowHeight: CGFloat?
    private var _didSelect: ((Context) -> Void)?
    private var _cellConfig: ((UITableViewCell) -> Void)?
    private var differ: ((Data) -> String)?
    private var selectionStyle: UITableViewCell.SelectionStyle

    
    weak public var section: ISequenceSection?
    
    public var indexPath: IndexPath = IndexPath()
    
    public func getRowIdentifier() -> String {
        "\(type(of: self))_\(id)"
    }
    
    public func didSelect() {
        if let ctx = getContext() {
            _didSelect?(ctx)
        }
    }
    
    public func getCell() -> UITableViewCell {
        let (cell, _) = _getCell()
        return cell
    }
    
    public func getRowHeight() -> CGFloat? {
        rowHeight
    }
    
    public func getEstimatedRowHeight() -> CGFloat? {
        estimatedRowHeight
    }
    
    private lazy var address = Unmanaged.passUnretained(self).toOpaque().debugDescription
    public func getDiff() -> String {
        differ?(data) ?? (address + "\(data)")
    }
    
    private func _getCell() -> (ListBoxCell<Data>, UIView?) {
        let id = getRowIdentifier()
        var cell = section?.box?.dequeueReusableCell(withIdentifier: id) as? ListBoxCell<Data>
        if cell == nil {
            cell = ListBoxCell(id: id)
            let box = section?.box
            let holder = SequenceContextHolder<Data> { [weak box, weak cell] in
                if let box = box,
                    let cell = cell,
                    let indexpath = box.indexPath(for: cell),
                    let row = box.getRow(at: indexpath) as? BasicSequenceItem<Data> {
                    return row.getContext()
                }
                return nil
            }
            if let root = cellGen(cell!.state.asOutput(), holder) {
                cell?.root = root
                cell?.contentView.addSubview(root)
            }
            
        }
        if let ctx = getContext() {
            cell?.state.input(value: ctx)
        }
        cell?.selectionStyle = selectionStyle
        _cellConfig?(cell!)
        return (cell!, cell!.root)
    }
    
    private func getContext() -> RecycleContext<Data, UITableView>? {
        if let section = section {
            return .init(indexPath: indexPath, index: indexPath.row, size: section.getLayoutableContentSize(), data: data, view: section.box)
        }
        return nil
    }
    
}

private class ListBoxCell<Data>: UITableViewCell {
    var root: UIView?
    let state = SimpleIO<RecycleContext<Data, UITableView>>()

    required init(id: String) {
        super.init(style: .value1, reuseIdentifier: id)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
        guard let root = root else {
            return .zero
        }
        var size = root.sizeThatFits(targetSize)
        size.height += (root.py_measure.margin.top + root.py_measure.margin.bottom)
        return size
    }
}
