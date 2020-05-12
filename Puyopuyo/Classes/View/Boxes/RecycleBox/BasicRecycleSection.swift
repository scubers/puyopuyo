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
    public typealias Context = RecycleContext<Data, UICollectionView>
    public init(
        id: String? = nil,
        insets: UIEdgeInsets? = nil,
        lineSpacing: CGFloat? = nil,
        itemSpacing: CGFloat? = nil,
        data: Data,
        items: SimpleOutput<[IRecycleItem]> = [].asOutput(),
        _header: RecycleViewGenerator<RecycleContext<Data, UICollectionView>, Event>? = nil,
        _footer: RecycleViewGenerator<RecycleContext<Data, UICollectionView>, Event>? = nil,
        _event: ((Event, Context) -> Void)? = nil
    ) {
        self.id = id
        sectionInsets = insets
        self.lineSpacing = lineSpacing
        self.itemSpacing = itemSpacing
        headerGen = _header
        footerGen = _footer
        sectionEvent = _event
        self.data = data
        items.safeBind(to: bag) { [weak self] _, items in
            self?.reload(items: items)
        }
    }
    
    private let bag = NSObject()
    public let recycleItems = State<[IRecycleItem]>([])
    public var sectionInsets: UIEdgeInsets?
    public var lineSpacing: CGFloat?
    public var itemSpacing: CGFloat?
    public var data: Data
    
    private let id: String?
    private var headerGen: RecycleViewGenerator<RecycleContext<Data, UICollectionView>, Event>?
    private var footerGen: RecycleViewGenerator<RecycleContext<Data, UICollectionView>, Event>?
    private var sectionEvent: ((Event, Context) -> Void)?
    
    // MARK: - private
    
    private var dataIds = [String]()
    
    private func setRecycleItems(_ items: [IRecycleItem]) {
        recycleItems.value = items
        dataIds = items.map { i -> String in
            i.getDiff()
        }
    }
    
    private func reload(items: [IRecycleItem]) {
        // 赋值section
        items.forEach { $0.recycleSection = self }
        // box 还没赋值时，只更新数据源
        guard let box = recycleBox else {
            setRecycleItems(items)
            return
        }
        
        // iOS低版本当bounds == zero 进行 增量更新的时候，会出现崩溃，高版本会警告
        guard box.bounds != .zero else {
            setRecycleItems(items)
            box.reloadData()
            return
        }
        
        guard box.enableDiff else {
            setRecycleItems(items)
            box.reloadData()
            return
        }
        
        let newDataIds = items.map { i -> String in
            i.getDiff()
        }
        // 需要做diff运算
        
        let diff = Diff(src: dataIds, dest: newDataIds, identifier: { $0 })
        diff.check()
        if diff.isDifferent(), let section = box.viewState.value.firstIndex(where: { $0 === self }) {
            recycleItems.value = items
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
        if index < recycleItems.value.count {
            return recycleItems.value[index]
        }
        return nil
    }
    
    public func getSectionId(kind: String? = nil) -> String {
        "\(type(of: self))_\(id ?? "")_\(kind ?? "")"
    }
    
    // MARK: - IRecycleSection methods
    
    public weak var recycleBox: RecycleBox?
    
    public var index: Int = 0
    
    public func getItems() -> [IRecycleItem] {
        return recycleItems.value
    }
    
    public func supplementaryViewType(for _: String) -> AnyClass {
        RecycleBoxSupplementaryView<Data, Event>.self
    }
    
    public func supplementaryIdentifier(for kind: String) -> String {
        getSectionId(kind: kind)
    }
    
    public func supplementaryView(for kind: String) -> UICollectionReusableView {
        let (view, _) = _getSupplementaryView(for: kind)
        view.onEvent = { [weak self] e in
            self?.with { self?.sectionEvent?(e, $0) }
        }
        
        return view
    }
    
    private func _getSupplementaryView(for kind: String) -> (RecycleBoxSupplementaryView<Data, Event>, UIView?) {
        guard let view = recycleBox?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: getSectionId(kind: kind), for: IndexPath(row: 0, section: index)) as? RecycleBoxSupplementaryView<Data, Event> else {
            fatalError()
        }
        configSupplementaryView(view, kind: kind)
        return (view, view.root)
    }
    
    public func supplementaryViewSize(for kind: String) -> CGSize {
        let (view, rootView): (RecycleBoxSupplementaryView<Data, Event>, UIView?) = {
            let id = supplementaryIdentifier(for: kind)
            if let view = recycleBox?.caculatSupplementaries[id] as? RecycleBoxSupplementaryView<Data, Event> {
                return (view, view.root)
            }
            let view = RecycleBoxSupplementaryView<Data, Event>()
            configSupplementaryView(view, kind: kind)
            recycleBox?.caculatSupplementaries[id] = view
            return (view, view.root)
        }()
        guard let root = rootView else { return .zero }
        let layoutContentSize = getLayoutableContentSize()
        with { view.state.input(value: $0) }
        var size = root.sizeThatFits(layoutContentSize)
        size.width += root.py_measure.margin.getHorzTotal()
        size.height += root.py_measure.margin.getVertTotal()
        return CGSize(width: max(0, size.width), height: max(0, size.height))
    }
    
    private func configSupplementaryView(_ view: RecycleBoxSupplementaryView<Data, Event>, kind: String) {
        let size = getLayoutableContentSize()
        view.targetSize = size
        if view.root == nil {
            var root: UIView?
            let state = view.state
            let event = view.event
            switch kind {
            case UICollectionView.elementKindSectionHeader where headerGen != nil:
                root = headerGen!(state.asOutput(), event.asInput())
            case UICollectionView.elementKindSectionFooter where footerGen != nil:
                root = footerGen!(state.asOutput(), event.asInput())
            default: break
            }
            view.root = root
            if let root = root {
                view.addSubview(root)
            }
        }
        with { view.state.input(value: $0) }
    }
    
    private func with(_ block: (Context) -> Void) {
        block(.init(index: index, size: getLayoutableContentSize(), data: data, view: recycleBox))
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

private class RecycleBoxSupplementaryView<D, E>: UICollectionReusableView {
    var root: UIView?
    let state = SimpleIO<RecycleContext<D, UICollectionView>>()
    let event = SimpleIO<E>()
    
    var onEvent: (E) -> Void = { _ in }
    var targetSize: CGSize = .zero
    
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
        let size = self.targetSize == .zero ? targetSize : self.targetSize
        return root?.sizeThatFits(size) ?? .zero
    }
}
