//
//  BasicRecycleItem.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/11.
//

import Foundation

public class BasicRecycleItem<Data>: IRecycleItem {
    public typealias Context = RecycleContext<Data, UICollectionView>
    public init(
        id: String,
        data: Data,
        differ: ((Data) -> String)? = nil,
        _cell: @escaping RecycleViewGenerator<Data>,
        _cellConfig: ((UICollectionViewCell) -> Void)? = nil,
        _didSelect: ((Context) -> Void)? = nil
    ) {
        self.id = id
        self.data = data
        self.cellGen = _cell
        self.differ = differ
        self._didSelect = _didSelect
    }
    
    public let id: String
    public var data: Data
    private let cellGen: RecycleViewGenerator<Data>
    private var _didSelect: ((Context) -> Void)?
    private var _cellConfig: ((UICollectionViewCell) -> Void)?
    private var differ: ((Data) -> String)?
    
    // MARK: - methods
    
    // MARK: - IRecycleItem methods
    
    public weak var recycleSection: IRecycleSection?
    
    public var indexPath: IndexPath = IndexPath()
    
    public func getItemViewType() -> AnyClass {
        RecycleBoxCell<Data>.self
    }
    
    public func getItemIdentifier() -> String {
        "\(type(of: self))_\(getItemViewType())_\(id)"
    }
    
    private lazy var address = Unmanaged.passUnretained(self).toOpaque().debugDescription
    public func getDiff() -> String {
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
    
    private func getContext() -> RecycleContext<Data, UICollectionView>? {
        if let section = recycleSection {
            return .init(indexPath: indexPath, index: indexPath.item, size: section.getLayoutableContentSize(), data: data, view: section.recycleBox)
        }
        return nil
    }
    
    public func getCell() -> UICollectionViewCell {
        let (cell, _) = _getCell()
        return cell
    }
    
    private func _getCell() -> (RecycleBoxCell<Data>, UIView?) {
        recycleSection?.recycleBox?.registerItem(self)
        guard let section = recycleSection,
            let cell = section.recycleBox?.dequeueReusableCell(withReuseIdentifier: getItemIdentifier(), for: indexPath) as? RecycleBoxCell<Data> else {
            fatalError()
        }
        configCell(cell)
        return (cell, cell.root)
    }
    
    public func getItemSize() -> CGSize {
        guard let section = recycleSection else {
            return .zero
        }
        let (cell, rootView): (RecycleBoxCell<Data>, UIView?) = {
            if let cell = section.recycleBox?.caculatItems[getItemIdentifier()] as? RecycleBoxCell<Data> {
                return (cell, cell.root)
            }
            let cell = RecycleBoxCell<Data>()
            configCell(cell)
            section.recycleBox?.caculatItems[getItemIdentifier()] = cell
            return (cell, cell.root)
        }()
        guard let root = rootView else { return .zero }
        
        let layoutContentSize = section.getLayoutableContentSize()
        cell.state.input(value: RecycleContext<Data, UICollectionView>(index: indexPath.row, size: layoutContentSize, data: data, view: section.recycleBox))
        var size = root.sizeThatFits(layoutContentSize)
        size.width += root.py_measure.margin.getHorzTotal()
        size.height += root.py_measure.margin.getVertTotal()
        return CGSize(width: max(0, size.width), height: max(0, size.height))
    }
    
    private func configCell(_ cell: RecycleBoxCell<Data>) {
        guard let section = recycleSection else { return }
        let size = section.getLayoutableContentSize()
        cell.targetSize = size
        let ctx = RecycleContext<Data, UICollectionView>(index: indexPath.row, size: size, data: data, view: section.recycleBox)
        if cell.root == nil {
            let box = section.recycleBox
            let holder = RecycleContextHolder { [weak box, weak cell] () -> RecycleContext<Data, UICollectionView>? in
                if let cell = cell,
                    let idx = box?.indexPath(for: cell),
                    let item = box?.getItem(idx) as? BasicRecycleItem<Data> {
                    return item.getContext()
                }
                return nil
            }
            let root = cellGen(cell.state.asOutput(), holder)
            cell.root = root
            if let root = root {
                cell.contentView.addSubview(root)
            }
        }
        cell.state.input(value: ctx)
        _cellConfig?(cell)
    }
}

private class RecycleBoxCell<D>: UICollectionViewCell {
    var root: UIView?
    let state = SimpleIO<RecycleContext<D, UICollectionView>>()
    
    var targetSize: CGSize = .zero
    var cachedSize: CGSize?
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
        if let cached = cachedSize { return cached }
        let size = self.targetSize == .zero ? targetSize : self.targetSize
        let final = root?.sizeThatFits(size) ?? .zero
        return final
    }
}
