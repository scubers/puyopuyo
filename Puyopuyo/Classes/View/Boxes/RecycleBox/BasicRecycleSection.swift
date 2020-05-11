//
//  BasicRecycleSection.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/11.
//

import Foundation

// var headerGenerator: HeaderFooterGenerator<RecycleContext<[Data], UICollectionView>, CellEvent>
public typealias RecycleViewGenerator<D, E> = (SimpleOutput<D>, SimpleInput<E>) -> UIView?

public class BasicRecycleSection<Data, Event>: IRecycleSection {
    public init(
        id: String? = nil,
        insets: UIEdgeInsets? = nil,
        lineSpacing: CGFloat? = nil,
        itemSpacing: CGFloat? = nil,
        data: Data,
        enableDiff: Bool = false,
        items: SimpleOutput<[IRecycleItem]> = [].asOutput(),
        _header: RecycleViewGenerator<RecycleContext<Data, UICollectionView>, Event>? = nil,
        _footer: RecycleViewGenerator<RecycleContext<Data, UICollectionView>, Event>? = nil,
        _event: ((Data, Event) -> Void)? = nil
    ) {
        self.id = id
        sectionInsets = insets
        self.lineSpacing = lineSpacing
        self.itemSpacing = itemSpacing
        headerGen = _header
        footerGen = _footer
        sectionEvent = _event
        self.data = data
        self.enableDiff = enableDiff
        items.safeBind(to: bag) { [weak self] _, items in
            self?.reload(items: items)
        }
    }
    
    private let bag = NSObject()
    public let dataSource = State<[IRecycleItem]>([])
    public var sectionInsets: UIEdgeInsets?
    public var lineSpacing: CGFloat?
    public var itemSpacing: CGFloat?
    public var data: Data
    
    private let id: String?
    private var headerGen: RecycleViewGenerator<RecycleContext<Data, UICollectionView>, Event>?
    private var footerGen: RecycleViewGenerator<RecycleContext<Data, UICollectionView>, Event>?
    private var sectionEvent: ((Data, Event) -> Void)?
    private var enableDiff = false
    
    // MARK: - private
    
    private var dataIds = [String]()
    
    private func setDataSource(_ items: [IRecycleItem]) {
        dataSource.value = items
        dataIds = items.map { i -> String in
            i.recycleSection = self
            return i.getDiff()
        }
    }
    
    private func reload(items: [IRecycleItem]) {
        // box 还没赋值时，只更新数据源
        guard let box = recycleBox else {
            setDataSource(items)
            return
        }
        
        // iOS低版本当bounds == zero 进行 增量更新的时候，会出现崩溃，高版本会警告
        guard box.bounds != .zero else {
            setDataSource(items)
            box.reloadData()
            return
        }
        
        guard enableDiff else {
            setDataSource(items)
            box.reloadData()
            return
        }
        
        let newDataIds = items.map { i -> String in
            i.recycleSection = self
            return i.getDiff()
        }
        // 需要做diff运算
        
        let diff = Diff(src: dataIds, dest: newDataIds, identifier: { $0 })
        diff.check()
        if diff.isDifferent(), let section = box.viewState.value.firstIndex(where: { $0 === self }) {
            dataSource.value = items
            dataIds = newDataIds
            box.performBatchUpdates({
                if !diff.delete.isEmpty {
                    box.deleteItems(at: diff.delete.map { IndexPath(row: $0.from, section: section) })
                }
                if !diff.insert.isEmpty {
                    box.insertItems(at: diff.insert.map { IndexPath(row: $0.to, section: section) })
                }
                diff.move.forEach { c in
                    box.moveItem(at: IndexPath(row: c.from, section: section), to: IndexPath(row: c.to, section: section))
                }
            }, completion: nil)
        }
    }
    
    func getItem(_ index: Int) -> IRecycleItem? {
        if index < dataSource.value.count {
            return dataSource.value[index]
        }
        return nil
    }
    
    public func getSectionId(kind: String? = nil) -> String {
        "\(NSStringFromClass(type(of: self)))_\(id ?? "")_\(kind ?? "")"
    }
    
    // MARK: - IRecycleSection methods
    
    public weak var recycleBox: RecycleBox?
    
    public var index: Int = 0
    
    public func getItems() -> [IRecycleItem] {
        return dataSource.value
    }
    
    public func supplementaryViewType(for kind: String) -> AnyClass {
        CollectionBoxSupplementaryView<Data, Event>.self
    }
    
    public func supplementaryIdentifier(for kind: String) -> String {
        getSectionId(kind: kind)
    }
    
    public func supplementaryView(for kind: String) -> UICollectionReusableView {
        let (view, _) = _getSupplementaryView(for: kind)
        view.onEvent = { [weak self, weak view] e in
            guard let self = self, let view = view else { return }
            let data = view.state.value.data
            self.sectionEvent?(data, e)
        }
        
        return view
    }
    
    private func _getSupplementaryView(for kind: String) -> (CollectionBoxSupplementaryView<Data, Event>, UIView?) {
        guard let view = recycleBox?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: getSectionId(kind: kind), for: IndexPath(row: 0, section: index)) as? CollectionBoxSupplementaryView<Data, Event> else {
            fatalError()
        }
        let size = getLayoutableContentSize()
        view.targetSize = size
        let ctx = RecycleContext<Data, UICollectionView>(index: index, size: size, data: data, view: recycleBox)
        if view.root == nil {
            var root: UIView?
            let state = State(ctx)
            let event = SimpleIO<Event>()
            switch kind {
            case UICollectionView.elementKindSectionHeader where headerGen != nil:
                root = headerGen!(state.asOutput(), event.asInput())
            case UICollectionView.elementKindSectionFooter where footerGen != nil:
                root = footerGen!(state.asOutput(), event.asInput())
            default: break
            }
            view.state = state
            view.event = event
            view.root = root
            if let root = root {
                view.addSubview(root)
            }
        } else {
            view.state.value = ctx
        }
        return (view, view.root)
    }
    
    public func supplementaryViewSize(for kind: String) -> CGSize {
        let (view, rootView): (CollectionBoxSupplementaryView<Data, Event>, UIView?) = {
            let id = supplementaryIdentifier(for: kind)
            if let cell = recycleBox?.caculatSupplementaries[id] as? CollectionBoxSupplementaryView<Data, Event> {
                return (cell, cell.root)
            }
            let (cell, root) = _getSupplementaryView(for: kind)
            recycleBox?.caculatSupplementaries[id] = cell
            return (cell, root)
        }()
        guard let root = rootView else { return .zero }
        let layoutContentSize = getLayoutableContentSize()
        view.state.value = RecycleContext<Data, UICollectionView>(index: index, size: layoutContentSize, data: data, view: recycleBox)
        var size = root.sizeThatFits(layoutContentSize)
        size.width += root.py_measure.margin.getHorzTotal()
        size.height += root.py_measure.margin.getVertTotal()
        return CGSize(width: max(0, size.width), height: max(0, size.height))
    }
    
    public func getSectionInsets() -> UIEdgeInsets? {
        sectionInsets
    }
    
    public func getMinimumLineSpacing() -> CGFloat? {
        lineSpacing
    }
    
    public func getMinimumItemSpacing() -> CGFloat? {
        itemSpacing
    }
}
