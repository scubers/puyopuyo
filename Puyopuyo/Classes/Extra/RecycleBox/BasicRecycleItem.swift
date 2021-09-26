//
//  BasicRecycleItem.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/11.
//

import Foundation

public class BasicRecycleItem<Data>: IRecycleItem {
    public typealias Context = RecyclerInfo<Data>
    public init(
        id: String? = nil,
        data: Data,
        diffableKey: ((Data) -> String)? = nil,
        cell: @escaping RecycleViewGenerator<Data>,
        cellConfig: ((UICollectionViewCell) -> Void)? = nil,
        didSelect: ((Context) -> Void)? = nil,
        function: StaticString = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        self.id = id ?? "\(line)\(column)\(function)"
        self.data = data
        self.cellGen = cell
        self.differ = diffableKey
        self._didSelect = didSelect
        self._cellConfig = cellConfig
    }
    
    public let id: String
    public var data: Data
    private let cellGen: RecycleViewGenerator<Data>
    private var _didSelect: ((Context) -> Void)?
    private var _cellConfig: ((UICollectionViewCell) -> Void)?
    private var differ: ((Data) -> String)?
    
    // MARK: - methods
    
    // MARK: - IRecycleItem methods
    
    public weak var section: IRecycleSection?
    
    public var indexPath = IndexPath()
    
    public func getCellType() -> AnyClass {
        RecycleBoxCell<Data>.self
    }
    
    public func getCellId() -> String {
        "\(type(of: self))_\(getCellType())_\(id)"
    }
    
    private lazy var address = Unmanaged.passUnretained(self).toOpaque().debugDescription
    public func getDiffableKey() -> String {
        differ?(data) ?? (address + "\(data)")
    }
    
    public func didSelect() {
        withContext {
            self._didSelect?($0)
        }
    }
    
    private func withContext(_ block: (Context) -> Void) {
        if let ctx = getContext() {
            block(ctx)
        }
    }
    
    private func getContext() -> RecyclerInfo<Data>? {
        if let section = section {
            return RecyclerInfo(data: data, indexPath: indexPath, layoutableSize: section.getLayoutableContentSize())
        }
        return nil
    }
    
    public func getCell() -> UICollectionViewCell {
        let (cell, _) = getRawCellWithoutData()
        withContext { cell.state.input(value: $0) }
        return cell
    }
    
    private func getRawCellWithoutData() -> (RecycleBoxCell<Data>, UIView?) {
        section?.box?.registerItem(self)
        guard let section = section,
              let cell = section.box?.dequeueReusableCell(withReuseIdentifier: getCellId(), for: indexPath) as? RecycleBoxCell<Data>
        else {
            fatalError()
        }
        cell.selfSizingResidualSize = section.getLayoutableContentSize()
        if cell.root == nil {
            let box = section.box
            let holder = RecyclerTrigger<Data> { [weak box, weak cell] in
                if let cell = cell,
                   let idx = box?.indexPath(for: cell),
                   let item = box?.getItem(idx) as? BasicRecycleItem<Data>
                {
                    return item.getContext()
                }
                return nil
            }
            cell.root = cellGen(cell.state.binder, holder)
            holder.isBuilding = false
        }
        return (cell, cell.root)
    }
    
    private func getCalculateCell() -> RecycleBoxCell<Data> {
        guard let section = section, let box = section.box else {
            return RecycleBoxCell<Data>()
        }
        
        var cell = (box.calculateItems[getCellId()] as? RecycleBoxCell<Data>)
        if cell == nil {
            cell = RecycleBoxCell<Data>()
            cell?.root = cellGen(cell!.state.binder, RecyclerTrigger())
            box.calculateItems[getCellId()] = cell!
        }
        
        return cell!
    }
    
    public func getCellSize() -> CGSize {
        guard let section = section else {
            return .zero
        }
        
        let cell = getCalculateCell()
        guard let root = cell.root, let ctx = getContext() else { return .zero }
        
        let layoutContentSize = section.getLayoutableContentSize()
        
        cell.state.input(value: ctx)
        var size = root.sizeThatFits(layoutContentSize)
        size.width += root.py_measure.margin.getHorzTotal()
        size.height += root.py_measure.margin.getVertTotal()
        return CGSize(width: max(0, size.width), height: max(0, size.height))
    }
}

private class RecycleBoxCell<D>: UICollectionViewCell {
    var root: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let view = root {
                contentView.addSubview(view)
            }
        }
    }

    let state = SimpleIO<RecyclerInfo<D>>()
    
    var selfSizingResidualSize: CGSize = .zero
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
        let size = selfSizingResidualSize == .zero ? targetSize : selfSizingResidualSize
        let final = root?.sizeThatFits(size) ?? .zero
        return final
    }
}
