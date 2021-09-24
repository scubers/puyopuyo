//
//  SequenceBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/22.
//

import UIKit

public protocol ISequenceSection: AnyObject {
    // should be weak reference
    var box: SequenceBox? { get set }

    var index: Int { get set }

    func getItems() -> [ISequenceItem]

    func headerView() -> UITableViewHeaderFooterView

    func getHeaderHeight() -> CGFloat?
    func getEstimatedHeaderHeight() -> CGFloat?

    func footerView() -> UITableViewHeaderFooterView

    func getFooterHeight() -> CGFloat?
    func getEstimatedFooterHeight() -> CGFloat?
}

public extension ISequenceSection {
    func index(for item: ISequenceItem) -> Int? {
        return getItems().firstIndex(where: { $0 === item })
    }

    func item(at index: Int) -> ISequenceItem? {
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
        let width = cv.bounds.size.width - cv.contentInset.getHorzTotal()
        let height = cv.bounds.size.height - cv.contentInset.getVertTotal()
        return CGSize(width: max(0, width), height: max(0, height))
    }
}

public protocol ISequenceItem: AnyObject {
    // should be weak reference
    var section: ISequenceSection? { get set }

    var indexPath: IndexPath { get set }

    func getRowIdentifier() -> String

    func didSelect()

    func getCell() -> UITableViewCell

    func getRowHeight() -> CGFloat?

    func getEstimatedRowHeight() -> CGFloat?

    func getDiff() -> String
}

public class SequenceBox: UITableView,
    Stateful,
    Delegatable,
    DataSourceable,
    UITableViewDelegate,
    UITableViewDataSource
{
    public init(style: UITableView.Style = .plain,
                diff: Bool = false,
                sections: Outputs<[ISequenceSection]> = [].asOutput(),
                header: BoxGenerator<UIView>? = nil,
                footer: BoxGenerator<UIView>? = nil)
    {
        super.init(frame: .zero, style: style)

        enableDiff = diff
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

        separatorStyle = .singleLine

        dataSource = dataSourceProxy
        delegate = delegateProxy

        estimatedRowHeight = 0
        estimatedSectionHeaderHeight = 0
        estimatedSectionFooterHeight = 0

        rowHeight = UITableView.automaticDimension
        sectionHeaderHeight = UITableView.automaticDimension
        sectionFooterHeight = UITableView.automaticDimension

        // 监听tableView变化，动态改变TableBox大小
        py_observing(\.contentSize)
            .unwrap(or: .zero)
            .safeBind(to: self) { (this, size: CGSize) in
                if this.wrapContent {
                    this.attach().height(size.height)
                }
            }

        sections.send(to: viewState).dispose(by: self)
        viewState.safeBind(to: self) { this, s in
            this.prepareSections(s)
            DispatchQueue.main.async {
                this.reloadSections(s)
            }
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }

    fileprivate var heightCache = [IndexPath: CGFloat]()

    private var headerView: UIView!
    private var footerView: UIView!

    public private(set) var sections = [ISequenceSection]()
    public let viewState = State<[ISequenceSection]>([])
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
        getSection(at: section).getItems().count
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

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        getRow(at: indexPath).didSelect()
        tableView.deselectRow(at: indexPath, animated: true)
        delegateProxy.backup?.value?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    public func getSection(at index: Int) -> ISequenceSection {
        let s = sections[index]
        s.index = index
        s.box = self
        return s
    }

    public func getRow(at indexPath: IndexPath) -> ISequenceItem {
        let section = getSection(at: indexPath.section)
        let r = section.getItems()[indexPath.row]
        r.indexPath = indexPath
        r.section = section
        return r
    }
}

private extension SequenceBox {
    func prepareSections(_ sections: [ISequenceSection]) {
        sections.forEach { s in
            s.box = self
        }
    }

    func reloadSections(_ sections: [ISequenceSection]) {
        headerView.setNeedsDisplay()
        headerView.layoutIfNeeded()

        footerView.setNeedsDisplay()
        footerView.layoutIfNeeded()

        if enableDiff {
            reloadWithDiff(sections: sections)
        } else {
            self.sections = sections
            reloadData()
        }
    }

    private func reloadWithDiff(sections: [ISequenceSection]) {
        // section calculating
        let sectionDiff = Diff(
            src: (0..<self.sections.count).map { $0 },
            dest: (0..<sections.count).map { $0 },
            identifier: { $0.description }
        )
        sectionDiff.check()

        // item calculating

        let itemDiffs = sections.enumerated().map { idx, section -> Diff<ISequenceItem> in
            var diff: Diff<ISequenceItem>
            if idx < self.sections.count {
                diff = Diff(src: self.sections[idx].getItems(), dest: section.getItems(), identifier: { $0.getDiff() })
            } else {
                diff = Diff(src: [], dest: section.getItems(), identifier: { $0.getDiff() })
            }
            diff.check()
            return diff
        }

        self.sections = sections
        performBatchUpdates({
            self.applySectionUpdates(sectionDiff)
            itemDiffs.enumerated().forEach { section, diff in
                self.applyItemUpdates(diff, in: section)
            }
        }, completion: nil)
    }
}

public extension Puyo where T: SequenceBox {
    @discardableResult
    func wrapContent(_ wrap: Bool = true) -> Self {
        view.wrapContent = wrap
        view.py_setNeedsRelayout()
        return self
    }
}

extension UITableView {
    func applySectionUpdates<T>(_ updates: Diff<T>) {
        if !updates.delete.isEmpty {
            // 删除section
            deleteSections(IndexSet(updates.delete.map { $0.from }), with: .automatic)
        }

        if !updates.insert.isEmpty {
            insertSections(IndexSet(updates.insert.map { $0.to }), with: .automatic)
        }
    }

    func applyItemUpdates<T>(_ updates: Diff<T>, in section: Int) {
        if !updates.delete.isEmpty {
            deleteRows(at: updates.delete.map { IndexPath(row: $0.from, section: section) }, with: .automatic)
        }

        if !updates.insert.isEmpty {
            insertRows(at: updates.insert.map { IndexPath(row: $0.to, section: section) }, with: .automatic)
        }

        updates.move.forEach { c in
            self.moveRow(at: IndexPath(row: c.from, section: section), to: IndexPath(row: c.to, section: section))
        }
    }
}
