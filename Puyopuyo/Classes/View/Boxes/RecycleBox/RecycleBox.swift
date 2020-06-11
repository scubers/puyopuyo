//
//  RecycleBox.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/11.
//

import Foundation

public protocol IRecycleSection: class {
    // should be weak reference
    var box: RecycleBox? { get set }
    
    var index: Int { get set }
    
    func getItems() -> [IRecycleItem]
    
    func supplementaryViewType(for kind: String) -> AnyClass
    
    func supplementaryIdentifier(for kind: String) -> String
    
    func supplementaryView(for kind: String) -> UICollectionReusableView
    
    func supplementaryViewSize(for kind: String) -> CGSize
    
    func getSectionInsets() -> UIEdgeInsets?
    
    func getMinimumLineSpacing() -> CGFloat?
    
    func getMinimumItemSpacing() -> CGFloat?
}

public extension IRecycleSection {
    func index(for item: IRecycleItem) -> Int? {
        return getItems().firstIndex(where: { $0 === item })
    }
    
    func item(at index: Int) -> IRecycleItem? {
        let items = getItems()
        if items.count > index {
            return items[index]
        }
        return nil
    }
    
    func currentIndex() -> Int? {
        if let sections = box?.sections {
            return sections.firstIndex(where: { $0 === self })
        }
        return nil
    }
    
    func getLayoutableContentSize() -> CGSize {
        guard let cv = box else { return .zero }
        let inset = getSectionInsets() ?? box?.flowLayout.sectionInset ?? .zero
        let width = cv.bounds.size.width - cv.contentInset.getHorzTotal() - inset.getHorzTotal()
        let height = cv.bounds.size.height - cv.contentInset.getVertTotal() - inset.getVertTotal()
        return CGSize(width: max(0, width), height: max(0, height))
    }
}

public protocol IRecycleItem: class {
    // should be weak reference
    var section: IRecycleSection? { get set }
    
    var indexPath: IndexPath { get set }
    
    func getDiff() -> String
    
    func getItemViewType() -> AnyClass
    
    func getItemIdentifier() -> String
    
    func didSelect()
    
    func getCell() -> UICollectionViewCell
    
    func getItemSize() -> CGSize
}

public extension IRecycleItem {
    func currentIndex() -> Int? {
        return section?.getItems().firstIndex(where: { $0 === self })
    }
}

open class RecycleBox: UICollectionView,
    Stateful,
    Delegatable,
    DataSourceable,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource {
    // contruct method
    public init(
        layout: UICollectionViewFlowLayout = CollectionBoxFlowLayout(),
        direction: UICollectionView.ScrollDirection = .vertical,
        pinHeader: Bool = false,
        lineSpacing: CGFloat = 0,
        itemSpacing: CGFloat = 0,
        estimatedSize: CGSize = .zero,
        sectionInset: UIEdgeInsets = .zero,
        enableDiff: Bool = false,
        sections: SimpleOutput<[IRecycleSection]> = [].asOutput()
    ) {
        flowLayout = layout
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = lineSpacing
        layout.setSectionHeaderPin(pinHeader)
        layout.sectionInset = sectionInset
        layout.estimatedItemSize = estimatedSize
        layout.scrollDirection = direction
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        self.enableDiff = enableDiff
        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)
        backgroundColor = .clear
        delegate = delegateProxy
        dataSource = dataSourceProxy
        
        sections.send(to: viewState).unbind(by: self)
        
        viewState.safeBind(to: self) { this, s in
            // 注册view类型
            this.prepareSection(s)
            this.reload(sections: s)
        }
        
        py_boundsState().distinctMap(\.size).safeBind(to: self) { (this, _) in
            DispatchQueue.main.async {
                this.flowLayout.invalidateLayout()
            }
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    open override func responds(to aSelector: Selector!) -> Bool {
        // 判断是否使用自动计算大小
        if aSelector == #selector(collectionView(_:layout:sizeForItemAt:)), flowLayout.estimatedItemSize != .zero {
            return false
        }
        return super.responds(to: aSelector)
    }
    
    // private
    private var registeredItems = [String: Any]()
    private var registeredSupplementaries = [String: Any]()
    public private(set) var flowLayout: UICollectionViewFlowLayout
    
    var caculatItems = [String: UICollectionViewCell]()
    var caculatSupplementaries = [String: UICollectionReusableView]()
    
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
        self.sections = sections
        reloadData()
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
        getItem(indexPath).getItemSize()
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
        section.index = index
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
        sections.forEach { s in
            self.registerSection(s)
        }
    }
    
    func registerSection(_ section: IRecycleSection) {
        section.box = self
        [UICollectionView.elementKindSectionHeader, UICollectionView.elementKindSectionFooter].forEach { kind in
            let id = section.supplementaryIdentifier(for: kind)
            if registeredSupplementaries["\(kind)_\(id)"] == nil {
                self.register(section.supplementaryViewType(for: kind), forSupplementaryViewOfKind: kind, withReuseIdentifier: id)
                registeredSupplementaries["\(kind)_\(id)"] = 1
            }
        }
    }
    
    func registerItem(_ item: IRecycleItem) {
        if registeredItems[item.getItemIdentifier()] == nil {
            register(item.getItemViewType(), forCellWithReuseIdentifier: item.getItemIdentifier())
            registeredItems[item.getItemIdentifier()] = 1
        }
    }
}
