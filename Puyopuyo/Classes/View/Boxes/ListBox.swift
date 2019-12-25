//
//  ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/22.
//

import UIKit

public protocol ListBoxSection: class {
    var listBox: ListBox? { get set }
    func numberOfRows() -> Int
    func didSelect(row: Int)
    func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    func header(for tableView: UITableView, at section: Int) -> UIView?
    func footer(for tableView: UITableView, at section: Int) -> UIView?
}

/**
 封装TableView的重用机制。
 ListBox的大小不能为包裹，因为内部UITableView需要一个明确的大小。
 */
public class ListBox: UITableView,
    StatefulView,
    Delegatable,
    DataSourceable,
    UITableViewDelegate,
    UITableViewDataSource {
    public let viewState = State<[ListBoxSection]>([])
    public var wrapContent = false

    private var heightCache = [IndexPath: CGFloat]()

    private var headerView: UIView!
    private var footerView: UIView!

    public init(style: UITableView.Style = .plain,
                sections: [ListBoxSection] = [],
                header: BoxGenerator<UIView>? = nil,
                footer: BoxGenerator<UIView>? = nil) {
        super.init(frame: .zero, style: style)

        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)

        headerView = ZBox().attach {
            header?().attach($0)
        }
        .size(.fill, .wrap)
        .isSelfPositionControl(false)
        .view

        footerView = ZBox().attach {
            footer?().attach($0)
        }
        .isSelfPositionControl(false)
        .size(.fill, .wrap)
        .view

        tableHeaderView = headerView
        tableFooterView = footerView

        viewState.value = sections
        dataSource = dataSourceProxy
        delegate = delegateProxy
        estimatedRowHeight = 60
        rowHeight = UITableView.automaticDimension

        viewState.safeBind(to: self) { this, sections in
            sections.forEach { s in
                s.listBox = this
            }
            this.reload()
        }

        // 监听tableView变化，动态改变ListBox大小
        py_observing(for: #keyPath(UITableView.contentSize))
            .safeBind(to: self, { (this, size: CGSize?) in
                if this.wrapContent {
                    this.attach().size(.fill, size?.height ?? 0)
                }
            })
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }

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

    public func reload() {
        heightCache.removeAll()

        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()

        reloadData()
    }

    // MARK: - Delegatable, DataSourceable

    public func setDelegate(_ delegate: UITableViewDelegate, retained: Bool) {
        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: RetainWrapper(value: delegate, retained: retained))
    }

    public func setDataSource(_ dataSource: UITableViewDataSource, retained: Bool) {
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: RetainWrapper(value: dataSource, retained: retained))
    }

    // MARK: - UITableViewDelegate, DataSource

    public func numberOfSections(in _: UITableView) -> Int {
        return viewState.value.count
    }

    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewState.value[section].numberOfRows()
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewState.value[indexPath.section]
        return section.cell(for: tableView, at: indexPath)
    }

    public func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heightCache[indexPath] {
            return height
        }
        return UITableView.automaticDimension
    }

    public func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sec = viewState.value[section]
        return sec.header(for: tableView, at: section)
    }

    public func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sec = viewState.value[section]
        return sec.footer(for: tableView, at: section)
    }

    // MARK: - should delegate to outside

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewState.value[indexPath.section].didSelect(row: indexPath.row)
        delegateProxy.backup?.value?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightCache[indexPath] = cell.bounds.height
        delegateProxy.backup?.value?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
}

public class ListSection<Data, Cell: UIView, CellEvent>: ListBoxSection {
    public weak var listBox: ListBox?

    public let dataSource = State<[Data]>([])

    public typealias HeaderFooterGenerator<Data, CellEvent> = (SimpleOutput<(Int, Data)>, SimpleInput<CellEvent>) -> UIView?
    var headerGenerator: HeaderFooterGenerator<[Data], CellEvent>
    var footerGenerator: HeaderFooterGenerator<[Data], CellEvent>

    public typealias CellGenerator<Data, Cell, CellEvent> = (SimpleOutput<(Int, Data)>, SimpleInput<CellEvent>) -> Cell
    var cellGenerator: CellGenerator<Data, Cell, CellEvent>

    public typealias OnCellEvent<Event> = (Event) -> Void
    var onCellEvent: OnCellEvent<Event>

    public var identifier: String
    private var diffIdentifier: ((Data) -> String)?
    public init(identifier: String,
                dataSource: SimpleOutput<[Data]>,
                _diffIdentifier: ((Data) -> String)? = nil,
                _cell: @escaping CellGenerator<Data, Cell, CellEvent>,
                _header: @escaping HeaderFooterGenerator<[Data], CellEvent> = { _, _ in EmptyView() },
                _footer: @escaping HeaderFooterGenerator<[Data], CellEvent> = { _, _ in EmptyView() },
                _event: @escaping OnCellEvent<Event> = { _ in }) {
        self.identifier = identifier
        cellGenerator = _cell
        headerGenerator = _header
        footerGenerator = _footer
        onCellEvent = _event
        diffIdentifier = _diffIdentifier
        _ = dataSource.outputing({ [weak self] (data) in
            self?.reload(with: data)
        })
    }

    public enum Event {
        case didSelect(Int, Data)
        case headerEvent(Int, [Data], CellEvent)
        case footerEvent(Int, [Data], CellEvent)
        case itemEvent(Int, Data, CellEvent)
    }

    public func numberOfRows() -> Int {
        return dataSource.value.count
    }

    public func didSelect(row: Int) {
        onCellEvent(.didSelect(row, dataSource.value[row]))
    }

    func cellIdentifier() -> String {
        return identifier
    }

    func headerIdentifier() -> String {
        return "\(cellIdentifier())_header"
    }

    func footerIdentifier() -> String {
        return "\(cellIdentifier())_footer"
    }

    public func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ListBoxCell<Data, CellEvent>
        let data = dataSource.value[indexPath.row]
        if cell == nil {
            let state = State((indexPath.row, data))
            let event = SimpleIO<CellEvent>()
            cell = ListBoxCell<Data, CellEvent>(id: identifier,
                                                root: cellGenerator(state.asOutput(), event.asInput()),
                                                state: state,
                                                event: event)
            _ = event.outputing { [weak cell] event in
                guard let cell = cell else { return }
                let idx = cell.state.value.0
                let data = cell.state.value.1
                self.onCellEvent(.itemEvent(idx, data, event))
            }
        } else {
            cell?.state.value = (indexPath.row, data)
        }
        return cell!
    }

    private var header: ListHeaderFooter<[Data], CellEvent>?

    private var footer: ListHeaderFooter<[Data], CellEvent>?

    public func header(for _: UITableView, at section: Int) -> UIView? {
        if let header = header {
            header.state.value = (section, dataSource.value)
            return header
        }
        let state = State((section, dataSource.value))
        let event = SimpleIO<CellEvent>()
        guard let headerRoot = headerGenerator(state.asOutput(), event.asInput()) else {
            return nil
        }
        header = ListHeaderFooter<[Data], CellEvent>(id: identifier,
                                                     root: headerRoot,
                                                     state: state,
                                                     event: event)
        _ = event.outputing { [weak self] e in
            guard let self = self, let header = self.header else { return }
            self.onCellEvent(.headerEvent(header.state.value.0, header.state.value.1, e))
        }
        return header!
    }

    public func footer(for _: UITableView, at section: Int) -> UIView? {
        if let footer = footer {
            footer.state.value = (section, dataSource.value)
            return footer
        }
        let state = State((section, dataSource.value))
        let event = SimpleIO<CellEvent>()
        guard let footerRoot = footerGenerator(state.asOutput(), event.asInput()) else {
            return nil
        }
        footer = ListHeaderFooter<[Data], CellEvent>(id: identifier,
                                                     root: footerRoot,
                                                     state: state,
                                                     event: event)
        _ = event.outputing { [weak self] e in
            guard let self = self, let footer = self.footer else { return }
            self.onCellEvent(.footerEvent(footer.state.value.0, footer.state.value.1, e))
        }
        return footer!
    }
    
    private func reload(with data: [Data]) {
        
        guard let box = listBox else {
            dataSource.value = data
            return
        }
        
        guard let diffIdentifier = self.diffIdentifier else {
            dataSource.value = data
            listBox?.reload()
            return
        }
        
        let diff = Diff(src: dataSource.value.map({ diffIdentifier($0) }), dest: data.map({ diffIdentifier($0) }))
        diff.check()
        
        if diff.isDifferent(), let section = box.viewState.value.firstIndex(where: { $0 === self }) {
            
            dataSource.value = data
            box.beginUpdates()
            if !diff.insert.isEmpty {
                box.insertRows(at: diff.insert.map({ IndexPath(row: $0.to, section: section)}), with: .automatic)
            }
            if !diff.delete.isEmpty {
                box.deleteRows(at: diff.delete.map({ IndexPath(row: $0.from, section: section)}), with: .automatic)
            }
            diff.move.forEach { (c) in
                box.moveRow(at: IndexPath(row: c.from, section: section), to: IndexPath(row: c.to, section: section))
            }
            box.endUpdates()
        }
    }

    private class ListBoxCell<Data, E>: UITableViewCell {
        var root: UIView
        var state: State<(Int, Data)>
        var event: SimpleIO<E>

        required init(id: String, root: UIView, state: State<(Int, Data)>, event: SimpleIO<E>) {
            self.root = root
            self.state = state
            self.event = event
            super.init(style: .value1, reuseIdentifier: id)
            contentView.addSubview(root)
            backgroundColor = .clear
            contentView.backgroundColor = .clear
        }

        required init?(coder _: NSCoder) {
            fatalError()
        }

        override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
            return root.sizeThatFits(targetSize)
        }
    }

    public class EmptyView: UIView {
        public override func sizeThatFits(_: CGSize) -> CGSize {
            return CGSize(width: 0, height: 0.1)
        }
    }

    private class ListHeaderFooter<D, E>: UITableViewHeaderFooterView {
        var root: UIView
        var state: State<(Int, D)>
        var event: SimpleIO<E>

        required init(id: String, root: UIView, state: State<(Int, D)>, event: SimpleIO<E>) {
            self.root = root
            self.state = state
            self.event = event
            super.init(reuseIdentifier: id)
            contentView.addSubview(root)
            backgroundColor = .clear
            contentView.backgroundColor = .clear
        }

        required init?(coder _: NSCoder) {
            fatalError()
        }

        override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
            return root.sizeThatFits(targetSize)
        }
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

extension PYProxyChain: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let target = target(with: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))) as? UITableViewDataSource else {
            return 0
        }
        return target.tableView(tableView, numberOfRowsInSection: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let target = target(with: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))) as? UITableViewDataSource else {
            return UITableViewCell()
        }
        return target.tableView(tableView, cellForRowAt: indexPath)
    }
}
