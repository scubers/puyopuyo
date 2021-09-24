//
//  BasicListRow.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/18.
//

import Foundation

public class BasicSequenceItem<Data>: ISequenceItem {
    
    public typealias Context = RecyclerInfo<Data>
    public init(
        id: String? = nil,
        selectionStyle: UITableViewCell.SelectionStyle = .default,
        rowHeight: CGFloat? = nil,
        estimatedRowHeight: CGFloat? = nil,
        data: Data,
        differ: ((Data) -> String)? = nil,
        cell: @escaping SequenceViewGenerator<Data>,
        cellConfig: ((UITableViewCell) -> Void)? = nil,
        didSelect: ((Context) -> Void)? = nil,
        function: StaticString = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        self.id = id ?? "\(line)\(column)\(function)"
        self.data = data
        self.cellGen = cell
        self.differ = differ
        self._didSelect = didSelect
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
    
    private func _getCell() -> (SequenceBoxCell<Data>, UIView?) {
        let id = getRowIdentifier()
        var cell = section?.box?.dequeueReusableCell(withIdentifier: id) as? SequenceBoxCell<Data>
        if cell == nil {
            cell = SequenceBoxCell(id: id)
            let box = section?.box
            let holder = RecyclerTrigger<Data> { [weak box, weak cell] in
                if let box = box,
                    let cell = cell,
                    let indexpath = box.indexPath(for: cell),
                    let row = box.getRow(at: indexpath) as? BasicSequenceItem<Data> {
                    return row.getContext()
                }
                return nil
            }
            if let root = cellGen(cell!.state.binder, holder) {
                cell?.root = root
                cell?.contentView.addSubview(root)
            }
            holder.isBuilding = false
            
        }
        if let ctx = getContext() {
            cell?.state.input(value: ctx)
        }
        cell?.selectionStyle = selectionStyle
        _cellConfig?(cell!)
        return (cell!, cell!.root)
    }
    
    private func getContext() -> RecyclerInfo<Data>? {
        if let section = section {
            return RecyclerInfo(data: data, indexPath: indexPath, layoutableSize: section.getLayoutableContentSize())
        }
        return nil
    }
    
}

private class SequenceBoxCell<Data>: UITableViewCell {
    var root: UIView?
    let state = SimpleIO<RecyclerInfo<Data>>()

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
