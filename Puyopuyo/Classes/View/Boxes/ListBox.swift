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
    Stateful,
    Delegatable,
    DataSourceable,
    UITableViewDelegate,
    UITableViewDataSource {
    public let viewState = State<[ListBoxSection]>([])
    public var wrapContent = false

    fileprivate var heightCache = [IndexPath: CGFloat]()

    private var headerView: UIView!
    private var footerView: UIView!

    public init(style: UITableView.Style = .plain,
                separatorStyle: UITableViewCell.SeparatorStyle = .singleLine,
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

        viewState.value = sections
        dataSource = dataSourceProxy
        delegate = delegateProxy
        estimatedRowHeight = 60
        estimatedSectionHeaderHeight = 10
        estimatedSectionFooterHeight = 10
        rowHeight = UITableView.automaticDimension
        sectionHeaderHeight = UITableView.automaticDimension
        sectionFooterHeight = UITableView.automaticDimension

        viewState.safeBind(to: self) { this, sections in
            sections.forEach { s in
                s.listBox = this
            }
            this.reload()
        }

        // 监听tableView变化，动态改变ListBox大小
        py_observing(for: #keyPath(UITableView.contentSize))
            .safeBind(to: self) { (this, size: CGSize?) in
                if this.wrapContent {
                    this.attach().size(.fill, size?.height ?? 0)
                }
            }
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

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.contentView.backgroundColor = backgroundColor
        delegateProxy.backup?.value?.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.contentView.backgroundColor = backgroundColor
        delegateProxy.backup?.value?.tableView?(tableView, willDisplayFooterView: view, forSection: section)
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
    private var selectionStyle: UITableViewCell.SelectionStyle
    public init(identifier: String,
                selectionStyle: UITableViewCell.SelectionStyle = .default,
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
        self.selectionStyle = selectionStyle
        diffIdentifier = _diffIdentifier
        _ = dataSource.outputing { [weak self] data in
            self?.reload(with: data)
        }
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
        return "\(identifier)_\(Data.self)_\(CellEvent.self)"
    }

    func headerIdentifier() -> String {
        return "\(cellIdentifier())_header"
    }

    func footerIdentifier() -> String {
        return "\(cellIdentifier())_footer"
    }

    public func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let id = cellIdentifier()
        var cell = tableView.dequeueReusableCell(withIdentifier: id) as? ListBoxCell<Data, CellEvent>
        let data = dataSource.value[indexPath.row]
        if cell == nil {
            let state = State((indexPath.row, data))
            let event = SimpleIO<CellEvent>()
            cell = ListBoxCell<Data, CellEvent>(id: id,
                                                root: cellGenerator(state.asOutput(), event.asInput()),
                                                state: state,
                                                event: event)
        } else {
            cell?.state.value = (indexPath.row, data)
        }
        cell?.onEvent = { [weak cell, weak self] event in
            guard let cell = cell, let self = self else { return }
            let idx = cell.state.value.0
            let data = cell.state.value.1
            self.onCellEvent(.itemEvent(idx, data, event))
        }
        cell?.selectionStyle = selectionStyle
        return cell!
    }

    public func header(for tableView: UITableView, at section: Int) -> UIView? {
        let id = headerIdentifier()
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: id) as? ListHeaderFooter<[Data], CellEvent>

        if view == nil {
            let state = State((section, dataSource.value))
            let event = SimpleIO<CellEvent>()
            guard let root = headerGenerator(state.asOutput(), event.asInput()) else {
                return nil
            }
            view = ListHeaderFooter<[Data], CellEvent>(id: id,
                                                       root: root,
                                                       state: state,
                                                       event: event)
        } else {
            view?.state.value = (section, dataSource.value)
        }

        view?.backgroundView?.backgroundColor = tableView.backgroundColor
        view?.onEvent = { [weak self, weak view] e in
            guard let self = self, let header = view else { return }
            self.onCellEvent(.headerEvent(header.state.value.0, header.state.value.1, e))
        }

        return view!
    }

    public func footer(for tableView: UITableView, at section: Int) -> UIView? {
        let id = footerIdentifier()
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: id) as? ListHeaderFooter<[Data], CellEvent>

        if view == nil {
            let state = State((section, dataSource.value))
            let event = SimpleIO<CellEvent>()
            guard let root = footerGenerator(state.asOutput(), event.asInput()) else {
                return nil
            }
            view = ListHeaderFooter<[Data], CellEvent>(id: id,
                                                       root: root,
                                                       state: state,
                                                       event: event)
        } else {
            view?.state.value = (section, dataSource.value)
        }
        view?.backgroundView?.backgroundColor = tableView.backgroundColor
        view?.onEvent = { [weak self, weak view] e in
            guard let self = self, let header = view else { return }
            self.onCellEvent(.footerEvent(header.state.value.0, header.state.value.1, e))
        }

        return view!
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

        listBox?.heightCache.removeAll()

        let diff = Diff(src: dataSource.value, dest: data, identifier: diffIdentifier)
        diff.check()

        if diff.isDifferent(), let section = box.viewState.value.firstIndex(where: { $0 === self }) {
            dataSource.value = data
            box.beginUpdates()
            if !diff.insert.isEmpty {
                box.insertRows(at: diff.insert.map { IndexPath(row: $0.to, section: section) }, with: .automatic)
            }
            if !diff.delete.isEmpty {
                box.deleteRows(at: diff.delete.map { IndexPath(row: $0.from, section: section) }, with: .automatic)
            }
            diff.move.forEach { c in
                box.moveRow(at: IndexPath(row: c.from, section: section), to: IndexPath(row: c.to, section: section))
            }
            box.endUpdates()

            if !diff.stay.isEmpty {
                box.beginUpdates()
                box.reloadRows(at: diff.stay.map { IndexPath(row: $0.from, section: section) }, with: .none)
                box.endUpdates()
            }
        }
    }

    private class ListBoxCell<Data, E>: UITableViewCell {
        var root: UIView
        let state: State<(Int, Data)>
        let event: SimpleIO<E>
        var onEvent: (E) -> Void = { _ in }

        required init(id: String, root: UIView, state: State<(Int, Data)>, event: SimpleIO<E>) {
            self.root = root
            self.state = state
            self.event = event
            super.init(style: .value1, reuseIdentifier: id)
            contentView.addSubview(root)
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            _ = event.outputing { [weak self] in
                self?.onEvent($0)
            }
        }

        required init?(coder _: NSCoder) {
            fatalError()
        }

        override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
            var size = root.sizeThatFits(targetSize)
            size.height += (root.py_measure.margin.top + root.py_measure.margin.bottom)
            return size
        }
    }

    public class EmptyView: UIView {
        public override func sizeThatFits(_: CGSize) -> CGSize {
            return CGSize(width: 0, height: 0.1)
        }
    }

    private class ListHeaderFooter<D, E>: UITableViewHeaderFooterView {
        var root: UIView
        let state: State<(Int, D)>
        let event: SimpleIO<E>
        var onEvent: (E) -> Void = { _ in }

        required init(id: String, root: UIView, state: State<(Int, D)>, event: SimpleIO<E>) {
            self.root = root
            self.state = state
            self.event = event
            super.init(reuseIdentifier: id)
            contentView.addSubview(root)
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            let v = UIView()
            v.backgroundColor = .clear
            backgroundView = v
            _ = event.outputing { [weak self] in
                self?.onEvent($0)
            }
        }

        required init?(coder _: NSCoder) {
            fatalError()
        }

        override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
            return root.sizeThatFits(targetSize)
        }
    }

    deinit {
        print("ListSection deinit!!!")
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
