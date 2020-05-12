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
        _event: ((Event, Context) -> Void)? = nil,
        _didSelect: ((Context) -> Void)? = nil
    ) {
        self.id = id
        self.data = data
        self.onEvent = _event
        self.cellGen = _cell
        self.differ = differ
        self._didSelect = _didSelect
    }
    
    public let id: String
    public var data: Data
    private let cellGen: RecycleViewGenerator<Context, Event>
    private var onEvent: ((Event, Context) -> Void)?
    private var _didSelect: ((Context) -> Void)?
    private var differ: ((Data) -> String)?
    
    // MARK: - methods
    
    private func triggerEvent(ctx: Context, event: Event) {
        onEvent?(event, ctx)
    }
    
    // MARK: - IRecycleItem methods
    
    public weak var recycleSection: IRecycleSection?
    
    public var indexPath: IndexPath = IndexPath()
    
    public func getItemViewType() -> AnyClass {
        RecycleBoxCell<Data, Event>.self
    }
    
    public func getItemIdentifier() -> String {
        "\(type(of: self))_\(getItemViewType())_\(id)"
    }
    
    private lazy var address = Unmanaged.passUnretained(self).toOpaque().debugDescription
    public func getDiff() -> String {
        differ?(data) ?? (address + "\(data)")
    }
    
    public func didSelect() {
        with {
            self._didSelect?($0)
        }
    }
    
    private func with(context block: (Context) -> Void) {
        if let section = recycleSection {
            block(.init(index: indexPath.item, size: section.getLayoutableContentSize(), data: data, view: section.recycleBox))
        }
    }
    
    public func getCell() -> UICollectionViewCell {
        let (cell, _) = _getCell()
        let box = recycleSection?.recycleBox
        cell.onEvent = { [weak cell, weak box] e in
            guard let box = box, let cell = cell else { return }
            guard let idx = box.indexPath(for: cell) else { return }
            guard let item = box.getItem(idx) as? BasicRecycleItem<Data, Event> else { return }
            guard let _ = item.recycleSection else { return }
            item.with {
                item.triggerEvent(ctx: $0, event: e)
            }
        }
        return cell
    }
    
    private func _getCell() -> (RecycleBoxCell<Data, Event>, UIView?) {
        recycleSection?.recycleBox?.registerItem(self)
        guard let section = recycleSection,
            let cell = section.recycleBox?.dequeueReusableCell(withReuseIdentifier: getItemIdentifier(), for: indexPath) as? RecycleBoxCell<Data, Event> else {
            fatalError()
        }
        configCell(cell)
        return (cell, cell.root)
    }
    
    public func getItemSize() -> CGSize {
        guard let section = recycleSection else {
            return .zero
        }
        let (cell, rootView): (RecycleBoxCell<Data, Event>, UIView?) = {
            if let cell = section.recycleBox?.caculatItems[getItemIdentifier()] as? RecycleBoxCell<Data, Event> {
                return (cell, cell.root)
            }
            let cell = RecycleBoxCell<Data, Event>()
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
    
    private func configCell(_ cell: RecycleBoxCell<Data, Event>) {
        guard let section = recycleSection else { return }
        let size = section.getLayoutableContentSize()
        cell.targetSize = size
        let ctx = RecycleContext<Data, UICollectionView>(index: indexPath.row, size: size, data: data, view: section.recycleBox)
        if cell.root == nil {
            let root = cellGen(cell.state.asOutput(), cell.event.asInput())
            cell.root = root
            if let root = root {
                cell.contentView.addSubview(root)
            }
        }
        cell.state.input(value: ctx)
    }
}

private class RecycleBoxCell<D, E>: UICollectionViewCell {
    var root: UIView?
    let state = SimpleIO<RecycleContext<D, UICollectionView>>()
    let event = SimpleIO<E>()
    
    var onEvent: (E) -> Void = { _ in }
    
    var targetSize: CGSize = .zero
    var cachedSize: CGSize?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        event.safeBind(to: self) { this, e in
            this.onEvent(e)
        }
    }
    
    required init?(coder _: NSCoder) {
        fatalError()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
        if let cached = cachedSize { return cached }
        let size = self.targetSize == .zero ? targetSize : self.targetSize
        let final = root?.sizeThatFits(size) ?? .zero
        return final
    }
}
