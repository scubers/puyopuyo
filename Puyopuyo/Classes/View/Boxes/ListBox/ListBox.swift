//
//  ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/22.
//

import UIKit

public protocol IListSection: class {
    // should be weak reference
    var listBox: ListBox? { get set }

    var index: Int { get set }

    func getRows() -> [IListRow]

    func headerView() -> UITableViewHeaderFooterView
    
    func getHeaderHeight() -> CGFloat?
    func getEstimatedHeaderHeight() -> CGFloat?
    
    func footerView() -> UITableViewHeaderFooterView
    
    func getFooterHeight() -> CGFloat?
    func getEstimatedFooterHeight() -> CGFloat?
    
}

public extension IListSection {
    func index(for row: IListRow) -> Int? {
        return getRows().firstIndex(where: { $0 === row })
    }

    func row(at index: Int) -> IListRow? {
        let items = getRows()
        if items.count > index {
            return items[index]
        }
        return nil
    }

    func currentIndex() -> Int? {
        if let sections = listBox?.sections {
            return sections.firstIndex(where: { $0 === self })
        }
        return nil
    }

    func getLayoutableContentSize() -> CGSize {
        guard let cv = listBox else { return .zero }
        let width = cv.bounds.size.width - cv.contentInset.getHorzTotal()
        let height = cv.bounds.size.height - cv.contentInset.getVertTotal()
        return CGSize(width: max(0, width), height: max(0, height))
    }
}

public protocol IListRow: class {
    // should be weak reference
    var listSection: IListSection? { get set }

    var indexPath: IndexPath { get set }

    func getRowIdentifier() -> String

    func didSelect()

    func getCell() -> UITableViewCell

    func getRowHeight() -> CGFloat?
    
    func getEstimatedRowHeight() -> CGFloat?
    
    func getDiff() -> String
}

public class ListBox: UITableView,
    Delegatable,
    DataSourceable,
    UITableViewDelegate,
    UITableViewDataSource {
    public init(style: UITableView.Style = .plain,
                separatorStyle: UITableViewCell.SeparatorStyle = .singleLine,
                rowHeight: CGFloat = UITableView.automaticDimension,
                estimatedRowHeight: CGFloat = 0,
                
                sectionHeaderHeight: CGFloat = UITableView.automaticDimension,
                estimatedHeaderHeight: CGFloat = 0,
                
                sectionFooterHeight: CGFloat = UITableView.automaticDimension,
                estimatedFooterHeight: CGFloat = 0,
                enableDiff: Bool = false,
                sections: SimpleOutput<[IListSection]> = [].asOutput(),
                header: BoxGenerator<UIView>? = nil,
                footer: BoxGenerator<UIView>? = nil) {
        super.init(frame: .zero, style: style)

        self.enableDiff = enableDiff
        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)

        headerView = ZBox().attach {
            header?().attach($0)
        }
        .size(.fill, .wrap)
        .isCenterControl(false)
        .view

        footerView = ZBox().attach {
            footer?().attach($0)
        }
        .isCenterControl(false)
        .size(.fill, .wrap)
        .view

        tableHeaderView = headerView
        tableFooterView = footerView

        self.separatorStyle = separatorStyle

        dataSource = dataSourceProxy
        delegate = delegateProxy
        self.estimatedRowHeight = estimatedRowHeight
        estimatedSectionHeaderHeight = estimatedHeaderHeight
        estimatedSectionFooterHeight = estimatedFooterHeight
        
        self.rowHeight = rowHeight
        self.sectionHeaderHeight = sectionHeaderHeight
        self.sectionFooterHeight = sectionFooterHeight

        _ = sections.send(to: viewState)
        _ = viewState.catchObject(self) { (this, s) in
            this.prepareSections(s)
            this.reloadSections(s)
        }

        // 监听tableView变化，动态改变TableBox大小
        py_observing(for: #keyPath(UITableView.contentSize))
            .safeBind(to: self) { (this, size: CGSize?) in
                if this.wrapContent {
                    this.attach().height(size?.height ?? 0)
                }
            }
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }

    fileprivate var heightCache = [IndexPath: CGFloat]()

    private var headerView: UIView!
    private var footerView: UIView!

    public private(set) var sections = [IListSection]()
    public let viewState = State<[IListSection]>([])
    public var wrapContent = false
    public var enableDiff = false

    private var delegateProxy: DelegateProxy<UITableViewDelegate>! {
        didSet {
            delegate = delegateProxy
        }
    }

    private var dataSourceProxy: DelegateProxy<UITableViewDataSource>! {
        didSet {
            dataSource = dataSourceProxy
        }
    }

    // MARK: - Delegatable, DataSourceable

    public func setDelegate(_ delegate: UITableViewDelegate, retained: Bool) {
        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: RetainWrapper(value: delegate, retained: retained))
    }

    public func setDataSource(_ dataSource: UITableViewDataSource, retained: Bool) {
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: RetainWrapper(value: dataSource, retained: retained))
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    public func numberOfSections(in _: UITableView) -> Int {
        sections.count
    }

    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        getSection(at: section).getRows().count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        getRow(at: indexPath).getCell()
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        getRow(at: indexPath).getRowHeight() ?? rowHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        getSection(at: section).headerView()
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        getSection(at: section).getHeaderHeight() ?? sectionHeaderHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        getSection(at: section).footerView()
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        getSection(at: section).getFooterHeight() ?? sectionFooterHeight
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        getSection(at: section).getEstimatedHeaderHeight() ?? estimatedSectionHeaderHeight
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        getSection(at: section).getEstimatedFooterHeight() ?? estimatedSectionFooterHeight
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        getRow(at: indexPath).getEstimatedRowHeight() ?? estimatedRowHeight
    }
    
    public func getSection(at index: Int) -> IListSection {
        let s = sections[index]
        s.index = index
        s.listBox = self
        return s
    }
    
    public func getRow(at indexPath: IndexPath) -> IListRow {
        let section = getSection(at: indexPath.section)
        let r = section.getRows()[indexPath.row]
        r.indexPath = indexPath
        r.listSection = section
        return r
    }

}

private extension ListBox {
    func prepareSections(_ sections: [IListSection]) {
        sections.forEach { (s) in
            s.listBox = self
        }
    }
    
    func reloadSections(_ sections: [IListSection]) {
        self.sections = sections
        reloadData()
    }
}

public extension Puyo where T: ListBox {
    @discardableResult
    func wrapContent(_: Bool = true) -> Self {
        view.wrapContent = true
        view.py_setNeedsLayout()
        return self
    }
}
