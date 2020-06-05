//
//  BasicRecycleSection.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/11.
//

import Foundation

// var headerGenerator: HeaderFooterGenerator<RecycleContext<[Data], UICollectionView>, CellEvent>
// public typealias RecycleViewGenerator<D, E> = (SimpleOutput<D>, SimpleInput<E>) -> UIView?
public struct RecycleContextHolder<D> {
    var creator: () -> RecycleContext<D, UICollectionView>?
    public func withContext(_ block: (RecycleContext<D, UICollectionView>) -> Void) {
        if let ctx = creator() {
            block(ctx)
        }
    }
}

public typealias RecycleViewGenerator<D> = (SimpleOutput<RecycleContext<D, UICollectionView>>, RecycleContextHolder<D>) -> UIView?

public class BasicRecycleSection<Data>: IRecycleSection {
    public typealias Context = RecycleContext<Data, UICollectionView>
    public init(
        id: String? = nil,
        insets: UIEdgeInsets? = nil,
        lineSpacing: CGFloat? = nil,
        itemSpacing: CGFloat? = nil,
        data: Data,
        items: SimpleOutput<[IRecycleItem]> = [].asOutput(),
        _header: RecycleViewGenerator<Data>? = nil,
        _footer: RecycleViewGenerator<Data>? = nil,
        function: StaticString = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        self.id = id ?? "\(line)\(column)\(function)"
        sectionInsets = insets
        self.lineSpacing = lineSpacing
        self.itemSpacing = itemSpacing
        headerGen = _header
        footerGen = _footer
        self.data = data
        items.safeBind(to: bag) { [weak self] _, items in
            self?.reload(items: items)
        }
    }
    
    let bag = NSObject()
    public let recycleItems = State<[IRecycleItem]>([])
    public var sectionInsets: UIEdgeInsets?
    public var lineSpacing: CGFloat?
    public var itemSpacing: CGFloat?
    public var data: Data
    
    private let id: String?
    private var headerGen: RecycleViewGenerator<Data>?
    private var footerGen: RecycleViewGenerator<Data>?
    
    // MARK: - private
    
    private func setRecycleItems(_ items: [IRecycleItem]) {
        recycleItems.value = items
//        items.forEach { $0.section = self }
    }
    
    private func reload(items: [IRecycleItem]) {
        // 赋值section
        // box 还没赋值时，只更新数据源
        guard let box = box else {
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
        
        // 需要做diff运算
        
        let diff = Diff(src: recycleItems.value, dest: items, identifier: { $0.getDiff() })
        diff.check()
        if diff.isDifferent(), let section = box.viewState.value.firstIndex(where: { $0 === self }) {
            setRecycleItems(items)
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
    
    public weak var box: RecycleBox?
    
    public var index: Int = 0
    
    public func getItems() -> [IRecycleItem] {
        return recycleItems.value
    }
    
    public func supplementaryViewType(for _: String) -> AnyClass {
        RecycleBoxSupplementaryView<Data>.self
    }
    
    public func supplementaryIdentifier(for kind: String) -> String {
        getSectionId(kind: kind)
    }
    
    public func supplementaryView(for kind: String) -> UICollectionReusableView {
        let (view, _) = _getSupplementaryView(for: kind)
        return view
    }
    
    private func _getSupplementaryView(for kind: String) -> (RecycleBoxSupplementaryView<Data>, UIView?) {
        guard let view = box?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: getSectionId(kind: kind), for: IndexPath(row: 0, section: index)) as? RecycleBoxSupplementaryView<Data> else {
            fatalError()
        }
        configSupplementaryView(view, kind: kind)
        return (view, view.root)
    }
    
    public func supplementaryViewSize(for kind: String) -> CGSize {
        let (view, rootView): (RecycleBoxSupplementaryView<Data>, UIView?) = {
            let id = supplementaryIdentifier(for: kind)
            if let view = box?.caculatSupplementaries[id] as? RecycleBoxSupplementaryView<Data> {
                return (view, view.root)
            }
            let view = RecycleBoxSupplementaryView<Data>()
            configSupplementaryView(view, kind: kind)
            box?.caculatSupplementaries[id] = view
            return (view, view.root)
        }()
        guard let root = rootView else { return .zero }
        let layoutContentSize = getLayoutableContentSize()
        withContext { view.state.input(value: $0) }
        var size = root.sizeThatFits(layoutContentSize)
        size.width += root.py_measure.margin.getHorzTotal()
        size.height += root.py_measure.margin.getVertTotal()
        return CGSize(width: max(0, size.width), height: max(0, size.height))
    }
    
    private func configSupplementaryView(_ view: RecycleBoxSupplementaryView<Data>, kind: String) {
        view.targetSize = getLayoutableContentSize()
        if view.root == nil {
            var root: UIView?
            let state = view.state
            let box = self.box
            let holder = RecycleContextHolder { [weak box, weak view] () -> RecycleContext<Data, UICollectionView>? in
                if let view = view,
                    let idx = box?.visibleSupplementaryViews(ofKind: kind).firstIndex(where: { $0 === view }),
                    let indexPathes = box?.indexPathsForVisibleSupplementaryElements(ofKind: kind),
                    let section = box?.getSection(indexPathes[idx].section) as? BasicRecycleSection<Data> {
                    return section.getContext()
                }
                return nil
            }
            switch kind {
            case UICollectionView.elementKindSectionHeader where headerGen != nil:
                root = headerGen!(state.asOutput(), holder)
            case UICollectionView.elementKindSectionFooter where footerGen != nil:
                root = footerGen!(state.asOutput(), holder)
            default: break
            }
            view.root = root
            if let root = root {
                view.addSubview(root)
            }
        }
        withContext { view.state.input(value: $0) }
    }
    
    private func withContext(_ block: (Context) -> Void) {
        block(getContext())
    }
    
    private func getContext() -> RecycleContext<Data, UICollectionView> {
        .init(indexPath: IndexPath(item: 0, section: index), index: index, size: getLayoutableContentSize(), data: data, view: box)
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

private class RecycleBoxSupplementaryView<D>: UICollectionReusableView {
    var root: UIView?
    let state = SimpleIO<RecycleContext<D, UICollectionView>>()
    var targetSize: CGSize = .zero
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
        let size = self.targetSize == .zero ? targetSize : self.targetSize
        return root?.sizeThatFits(size) ?? .zero
    }
}
