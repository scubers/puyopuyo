//
//  RecycleBox.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/11.
//

import Foundation

public protocol IRecycleSection: AnyObject {
    // should be weak reference
    var box: RecycleBox? { get set }
    
    var sectionIndex: Int { get set }
    
    /// The diff value to calculate diff
    func getDiffableKey() -> String
    
    func getItems() -> [IRecycleItem]
    
    func supplementaryViewType(for kind: String) -> AnyClass
    
    func supplementaryViewId(for kind: String) -> String
    
    func supplementaryView(for kind: String) -> UICollectionReusableView
    
    func supplementaryViewSize(for kind: String) -> CGSize
    
    func getSectionInsets() -> UIEdgeInsets?
    
    func getMinimumLineSpacing() -> CGFloat?
    
    func getMinimumItemSpacing() -> CGFloat?
    
    func didChangeBounds(_ newBounds: CGRect)
}

public extension IRecycleSection {
    func getLayoutableContentSize() -> CGSize {
        guard let cv = box else { return .zero }
        let inset = getSectionInsets() ?? box?.flowLayout.sectionInset ?? .zero
        let width = cv.bounds.size.width - cv.contentInset.getHorzTotal() - inset.getHorzTotal()
        let height = cv.bounds.size.height - cv.contentInset.getVertTotal() - inset.getVertTotal()
        return CGSize(width: max(0, width), height: max(0, height))
    }
}

public protocol IRecycleItem: AnyObject {
    // should be weak reference
    var section: IRecycleSection? { get set }
    
    var indexPath: IndexPath { get set }
    
    /// The diff value to calculate diff
    func getDiffableKey() -> String
    
    func getCellType() -> AnyClass
    
    /// The identifier to register cell in collecitonView
    func getCellId() -> String
    
    func getCell() -> UICollectionViewCell
    
    func getCellSize() -> CGSize
    
    func didSelect()
    
    func didChangeBounds(_ newBounds: CGRect)
}

open class RecycleBox: UICollectionView,
    Stateful,
    Delegatable,
    DataSourceable,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource
{
    // contruct method
    public init(
        direction: UICollectionView.ScrollDirection = .vertical,
        headerPinToBounds: Bool = false,
        footerPinToBounds: Bool = false,
        lineSpacing: CGFloat = 0,
        itemSpacing: CGFloat = 0,
        // Use UICollection size prediction
        estimatedSize: CGSize = .zero,
        sectionInset: UIEdgeInsets = .zero,
        diffable: Bool = false,
        sections: Outputs<[IRecycleSection]> = [].asOutput()
    ) {
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = lineSpacing
        layout.sectionFootersPinToVisibleBounds = headerPinToBounds
        layout.sectionFootersPinToVisibleBounds = footerPinToBounds
        layout.sectionInset = sectionInset
        layout.estimatedItemSize = estimatedSize
        layout.scrollDirection = direction
        
        enableDiff = diffable
        
        flowLayout = layout
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)
        backgroundColor = .clear
        delegate = delegateProxy
        dataSource = dataSourceProxy
        
        sections.send(to: viewState).dispose(by: self)
        
        viewState.debounce().safeBind(to: self) { this, s in
            // 注册view类型
            this.prepareSection(s)
            this.reload(sections: s)
        }
        
        py_boundsState().map(\.size).distinct().debounce(interval: 0.2).safeBind(to: self) { this, size in
            this.didChangeBounds(CGRect(origin: .zero, size: size))
            this.reloadData()
        }
    }
    
    private func didChangeBounds(_ newBounds: CGRect) {
        sections.forEach { section in
            section.didChangeBounds(newBounds)
            section.getItems().forEach { item in
                item.didChangeBounds(newBounds)
            }
        }
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    override open func responds(to aSelector: Selector!) -> Bool {
        // 判断是否使用参考尺寸
        if aSelector == #selector(collectionView(_:layout:sizeForItemAt:)), flowLayout.estimatedItemSize != .zero {
            return false
        }
        return super.responds(to: aSelector)
    }
    
    // private
    private var registeredItems = [String: Any]()
    private var registeredSupplementaries = [String: Any]()
    public private(set) var flowLayout: UICollectionViewFlowLayout
    
    var calculateItems = [String: UICollectionViewCell]()
    var calculateSupplementaryViews = [String: UICollectionReusableView]()
    
    // sections
    public let viewState = State<[IRecycleSection]>([])
    
    public private(set) var sections = [IRecycleSection]()
    
    public var lineSpacing: CGFloat = 0
    public var itemSpacing: CGFloat = 0
    var enableDiff = false
    
    private var delegateProxy: DelegateProxy<UICollectionViewDelegateFlowLayout>! {
        didSet {
            delegate = delegateProxy
        }
    }
    
    private var dataSourceProxy: DelegateProxy<UICollectionViewDataSource>! {
        didSet {
            dataSource = dataSourceProxy
        }
    }
    
    // MARK: - Delegatable, DataSourceable
    
    public func setDelegate(_ delegate: UICollectionViewDelegateFlowLayout, retained: Bool) {
        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: RetainWrapper(value: delegate, retained: retained))
    }
    
    public func setDataSource(_ dataSource: UICollectionViewDataSource, retained: Bool) {
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: RetainWrapper(value: dataSource, retained: retained))
    }
    
    public func reload(sections: [IRecycleSection]) {
        if enableDiff, bounds != .zero {
            updateSectionsWithDiff(sections: sections)
        } else {
            self.sections = sections
            reloadData()
        }
    }
    
    private func updateSectionsWithDiff(sections: [IRecycleSection]) {
        // 全量计算section
        let sectionDiff = Diff(
            src: self.sections.map { $0.getDiffableKey() + $0.getItems().map { $0.getDiffableKey() }.joined() },
            dest: sections.map { $0.getDiffableKey() + $0.getItems().map { $0.getDiffableKey() }.joined() },
            identifier: { $0 }
        )
        
        sectionDiff.check()
        
        self.sections = sections
        performBatchUpdates({
            self.deleteSections(IndexSet(sectionDiff.delete.map { $0.from }))
            self.insertSections(IndexSet(sectionDiff.insert.map { $0.to }))
            sectionDiff.move.forEach { self.moveSection($0.from, toSection: $0.to) }
        }, completion: nil)
    }
    
    // UICollectionDelegate, UICollectionDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        getSection(section).getItems().count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        getItem(indexPath).getCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        getSection(indexPath.section).supplementaryView(for: kind)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getItem(indexPath).didSelect()
        delegateProxy.backup?.value?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        getItem(indexPath).getCellSize()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        getSection(section).supplementaryViewSize(for: UICollectionView.elementKindSectionHeader)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        getSection(section).supplementaryViewSize(for: UICollectionView.elementKindSectionFooter)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        getSection(section).getSectionInsets() ?? flowLayout.sectionInset
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        getSection(section).getMinimumLineSpacing() ?? flowLayout.minimumLineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        getSection(section).getMinimumItemSpacing() ?? flowLayout.minimumInteritemSpacing
    }
    
    func getSection(_ index: Int) -> IRecycleSection {
        let section = sections[index]
        section.sectionIndex = index
        section.box = self
        return section
    }
    
    func getItem(_ indexPath: IndexPath) -> IRecycleItem {
        let section = getSection(indexPath.section)
        let item = section.getItems()[indexPath.row]
        item.indexPath = indexPath
        item.section = section
        return item
    }
}

extension RecycleBox {
    func prepareSection(_ sections: [IRecycleSection]) {
        sections.enumerated().forEach { idx, s in
            s.box = self
            s.sectionIndex = idx
            self.registerSection(s)
        }
    }
    
    func registerSection(_ section: IRecycleSection) {
        section.box = self
        [UICollectionView.elementKindSectionHeader, UICollectionView.elementKindSectionFooter].forEach { kind in
            let id = section.supplementaryViewId(for: kind)
            if registeredSupplementaries["\(kind)_\(id)"] == nil {
                self.register(section.supplementaryViewType(for: kind), forSupplementaryViewOfKind: kind, withReuseIdentifier: id)
                registeredSupplementaries["\(kind)_\(id)"] = 1
            }
        }
    }
    
    func registerItem(_ item: IRecycleItem) {
        if registeredItems[item.getCellId()] == nil {
            register(item.getCellType(), forCellWithReuseIdentifier: item.getCellId())
            registeredItems[item.getCellId()] = 1
        }
    }
}

extension UICollectionView {
    func applyItemUpdates<T>(_ updates: Diff<T>, in section: Int) {
        deleteItems(at: updates.delete.map { IndexPath(row: $0.from, section: section) })
        
        insertItems(at: updates.insert.map { IndexPath(row: $0.to, section: section) })
        
        updates.move.forEach { c in
            self.moveItem(at: IndexPath(row: c.from, section: section), to: IndexPath(row: c.to, section: section))
        }
    }
}

extension PYProxyChain: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let target = target(with: #selector(UICollectionViewDataSource.collectionView(_:numberOfItemsInSection:))) as? UICollectionViewDataSource else {
            return 0
        }
        return target.collectionView(collectionView, numberOfItemsInSection: section)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let target = target(with: #selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:))) as? UICollectionViewDataSource else {
            return UICollectionViewCell()
        }
        return target.collectionView(collectionView, cellForItemAt: indexPath)
    }
}
