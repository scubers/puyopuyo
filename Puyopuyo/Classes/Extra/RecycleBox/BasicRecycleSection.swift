//
//  BasicRecycleSection.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/11.
//

import Foundation

public typealias RecycleViewGenerator<D> = (OutputBinder<RecyclerInfo<D>>, RecyclerTrigger<D>) -> UIView?

public class BasicRecycleSection<Data>: IRecycleSection, DisposableBag {
    public func addDisposer(_ disposer: Disposer, for key: String?) {
        bag.addDisposer(disposer, for: key)
    }
    
    public typealias Context = RecyclerInfo<Data>
    public init(
        id: String? = nil,
        insets: UIEdgeInsets? = nil,
        lineSpacing: CGFloat? = nil,
        itemSpacing: CGFloat? = nil,
        
        data: Data,
        items: Outputs<[IRecycleItem]> = [].asOutput(),
        
        header: RecycleViewGenerator<Data>? = nil,
        footer: RecycleViewGenerator<Data>? = nil,
        
        function: StaticString = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        self.id = id ?? "\(line)\(column)\(function)"
        sectionInsets = insets
        self.lineSpacing = lineSpacing
        self.itemSpacing = itemSpacing
        headerGen = header
        footerGen = footer
        self.data = data
        items.safeBind(to: self) { this, items in
            this.reload(items: items)
        }
    }
    
    private let bag = NSObject()
    private var recycleItems = [IRecycleItem]()
    public var sectionInsets: UIEdgeInsets?
    public var lineSpacing: CGFloat?
    public var itemSpacing: CGFloat?
    public var data: Data
    
    private let id: String?
    private var headerGen: RecycleViewGenerator<Data>?
    private var footerGen: RecycleViewGenerator<Data>?
    
    // MARK: - private
    
    private func reload(items: [IRecycleItem]) {
        // 赋值section
        items.enumerated().forEach { idx, item in
            item.section = self
            item.indexPath = IndexPath(item: idx, section: self.sectionIndex)
        }
        
        // box 还没赋值时，只更新数据源
        guard let box = box else {
            recycleItems = items
            return
        }
        
        // iOS低版本当bounds == zero 进行 增量更新的时候，会出现崩溃，高版本会警告
        guard box.bounds != .zero else {
            recycleItems = items
            box.reloadData()
            return
        }
        
        guard box.enableDiff else {
            recycleItems = items
            box.reloadData()
            return
        }
        
        // 需要做diff运算
        
        let diff = Diff(src: recycleItems, dest: items, identifier: { $0.getDiffableKey() })
        diff.check()
        if diff.isDifferent(), let section = box.viewState.value.firstIndex(where: { $0 === self }) {
            recycleItems = items
            box.performBatchUpdates({
                box.applyItemUpdates(diff, in: section)
            }, completion: nil)
        }
    }
    
    func getItem(_ index: Int) -> IRecycleItem? {
        if index < recycleItems.count {
            return recycleItems[index]
        }
        return nil
    }
    
    public func getSectionId(kind: String? = nil) -> String {
        "\(type(of: self))_\(id ?? "")_\(kind ?? "")"
    }
    
    // MARK: - IRecycleSection methods
    
    public weak var box: RecycleBox?
    
    public var sectionIndex: Int = 0
    
    public func getItems() -> [IRecycleItem] {
        return recycleItems
    }
    
    public func supplementaryViewType(for _: String) -> AnyClass {
        RecycleBoxSupplementaryView<Data>.self
    }
    
    public func supplementaryViewId(for kind: String) -> String {
        getSectionId(kind: kind)
    }
    
    public func supplementaryView(for kind: String) -> UICollectionReusableView {
        let (view, _) = getRawSupplementaryViewWithoutData(for: kind)
        view.state.input(value: getContext())
        return view
    }
    
    private func getRawSupplementaryViewWithoutData(for kind: String) -> (RecycleBoxSupplementaryView<Data>, UIView?) {
        guard let view = box?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: getSectionId(kind: kind), for: IndexPath(row: 0, section: sectionIndex)) as? RecycleBoxSupplementaryView<Data> else {
            fatalError()
        }
        // 初始化
        if view.root == nil {
            var root: UIView?
            let state = view.state
            let box = self.box
            let holder = RecyclerTrigger<Data> { [weak box, weak view] in
                if let view = view,
                   let idx = box?.visibleSupplementaryViews(ofKind: kind).firstIndex(where: { $0 === view }),
                   let indexPathes = box?.indexPathsForVisibleSupplementaryElements(ofKind: kind),
                   let section = box?.getSection(indexPathes[idx].section) as? BasicRecycleSection<Data>
                {
                    return section.getContext()
                }
                return nil
            }
            switch kind {
            case UICollectionView.elementKindSectionHeader where headerGen != nil:
                root = headerGen!(state.binder, holder)
            case UICollectionView.elementKindSectionFooter where footerGen != nil:
                root = footerGen!(state.binder, holder)
            default: break
            }
            view.root = root
            holder.isBuilding = false
        }
        view.selfSizingResidualSize = getLayoutableContentSize()
        return (view, view.root)
    }
    
    private func getCalculateView(for kind: String) -> RecycleBoxSupplementaryView<Data> {
        guard let box = box else {
            return RecycleBoxSupplementaryView<Data>()
        }
        
        var cell = box.calculateSupplementaryViews[getSectionId(kind: kind)] as? RecycleBoxSupplementaryView<Data>
        if cell == nil {
            cell = RecycleBoxSupplementaryView<Data>()
            
            cell?.root = kind == UICollectionView.elementKindSectionHeader
                ? (headerGen == nil ? nil : headerGen!(cell!.state.binder, RecyclerTrigger()))
                : (footerGen == nil ? nil : footerGen!(cell!.state.binder, RecyclerTrigger()))
            box.calculateSupplementaryViews[getSectionId(kind: kind)] = cell!
        }
        
        return cell!
    }
    
    public func supplementaryViewSize(for kind: String) -> CGSize {
        let view = getCalculateView(for: kind)
        guard let root = view.root else { return .zero }
        let layoutContentSize = getLayoutableContentSize()
        view.state.input(value: getContext())
        var size = root.sizeThatFits(layoutContentSize)
        size.width += root.py_measure.margin.getHorzTotal()
        size.height += root.py_measure.margin.getVertTotal()
        return CGSize(width: max(0, size.width), height: max(0, size.height))
    }
    
    private func getContext() -> RecyclerInfo<Data> {
        RecyclerInfo(data: data, indexPath: IndexPath(item: 0, section: sectionIndex), layoutableSize: getLayoutableContentSize())
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
    var root: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let view = root {
                addSubview(view)
            }
        }
    }

    var selfSizingResidualSize: CGSize = .zero
    let state = SimpleIO<RecyclerInfo<D>>()
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
        let size = selfSizingResidualSize == .zero ? targetSize : selfSizingResidualSize
        return root?.sizeThatFits(size) ?? .zero
    }
}
