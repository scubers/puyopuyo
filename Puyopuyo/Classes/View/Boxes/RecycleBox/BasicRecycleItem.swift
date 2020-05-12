//
//  BasicRecycleItem.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/11.
//

import Foundation

public class BasicRecycleItem<Data, Event>: IRecycleItem {
    public typealias Context = RecycleContext<Data, UICollectionView>
    public init(
        id: String,
        data: Data,
        differ: ((Data) -> String)? = nil,
        _cell: @escaping RecycleViewGenerator<Context, Event>,
        _event: ((Event, Context) -> Void)? = nil
    ) {
        self.id = id
        self.data = data
        self.onEvent = _event
        self.cellGen = _cell
        self.differ = differ
    }
    
    public let id: String
    public var data: Data
    private let cellGen: RecycleViewGenerator<Context, Event>
    private var onEvent: ((Event, Context) -> Void)?
    private var differ: ((Data) -> String)?
    
    // MARK: - methods
    
    private func triggerEvent(ctx: Context, event: Event) {
        onEvent?(event, ctx)
    }
    
    // MARK: - IRecycleItem methods
    
    public weak var recycleSection: IRecycleSection?
    
    public var indexPath: IndexPath = IndexPath()
    
    public func getItemViewType() -> AnyClass {
        CollectionBoxCell<Data, Event>.self
    }
    
    public func getItemIdentifier() -> String {
        "\(type(of: self))_\(getItemViewType())_\(id)"
    }
    
    private lazy var address = Unmanaged.passUnretained(self).toOpaque().debugDescription
    public func getDiff() -> String {
        differ?(data) ?? (address + "\(data)")
    }
    
    public func didSelect() {}
    
    public func getCell() -> UICollectionViewCell {
        let (cell, _) = _getCell()
        let box = recycleSection?.recycleBox
        cell.onEvent = { [weak cell, weak box] e in
            guard let box = box, let cell = cell else { return }
            guard let idx = box.indexPath(for: cell) else { return }
            guard let item = box.getItem(idx) as? BasicRecycleItem<Data, Event> else { return }
            guard let section = item.recycleSection else { return }
            item.triggerEvent(ctx: .init(index: idx.item, size: section.getLayoutableContentSize(), data: item.data, view: box), event: e)
        }
        return cell
    }
    
    private func _getCell() -> (CollectionBoxCell<Data, Event>, UIView?) {
        recycleSection?.recycleBox?.registerItem(self)
        guard let section = recycleSection,
            let cell = section.recycleBox?.dequeueReusableCell(withReuseIdentifier: getItemIdentifier(), for: indexPath) as? CollectionBoxCell<Data, Event> else {
            fatalError()
        }
        let size = section.getLayoutableContentSize()
        cell.targetSize = size
        let ctx = RecycleContext<Data, UICollectionView>(index: indexPath.row, size: size, data: data, view: section.recycleBox)
        if cell.root == nil {
            let state = State(ctx)
            let event = SimpleIO<Event>()
            let root = cellGen(state.asOutput(), event.asInput())
            cell.root = root
            cell.state = state
            cell.event = event
            if let root = root {
                cell.contentView.addSubview(root)
            }
        } else {
            cell.state.value = ctx
        }
        return (cell, cell.root)
    }
    
    public func getItemSize() -> CGSize {
        guard let section = recycleSection else {
            return .zero
        }
        let (cell, rootView): (CollectionBoxCell<Data, Event>, UIView?) = {
            if let cell = section.recycleBox?.caculatItems[getItemIdentifier()] as? CollectionBoxCell<Data, Event> {
                return (cell, cell.root!)
            }
            let (cell, root) = _getCell()
            section.recycleBox?.caculatItems[getItemIdentifier()] = cell
            section.recycleBox?.flowLayout.invalidateLayout()
            return (cell, root)
        }()
        guard let root = rootView else { return .zero }
        
        let layoutContentSize = section.getLayoutableContentSize()
        cell.state.value = RecycleContext<Data, UICollectionView>(index: indexPath.row, size: layoutContentSize, data: data, view: section.recycleBox)
        var size = root.sizeThatFits(layoutContentSize)
        size.width += root.py_measure.margin.getHorzTotal()
        size.height += root.py_measure.margin.getVertTotal()
        return CGSize(width: max(0, size.width), height: max(0, size.height))
    }
}
