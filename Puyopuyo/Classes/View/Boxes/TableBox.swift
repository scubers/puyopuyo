//
//  TableBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/22.
//

import UIKit

public protocol TableBoxSection: class {
    var tableBox: TableBox? { get set }
    func numberOfRows() -> Int
    func didSelect(row: Int)
    func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    func header(for tableView: UITableView, at section: Int) -> UIView?
    func footer(for tableView: UITableView, at section: Int) -> UIView?
}

/**
 封装TableView的重用机制。
 TableBox的大小不能为包裹，因为内部UITableView需要一个明确的大小。
 */
public class TableBox: UITableView,
    Stateful,
    Delegatable,
    DataSourceable,
    UITableViewDelegate,
    UITableViewDataSource {
    public let viewState = State<[TableBoxSection]>([])
    public var wrapContent = false

    fileprivate var heightCache = [IndexPath: CGFloat]()

    private var headerView: UIView!
    private var footerView: UIView!

    public init(style: UITableView.Style = .plain,
                separatorStyle: UITableViewCell.SeparatorStyle = .singleLine,
                sections: [TableBoxSection] = [],
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
                s.tableBox = this
            }
            this.reload()
        }

        // 监听tableView变化，动态改变TableBox大小
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

//    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        (view as? UITableViewHeaderFooterView)?.contentView.backgroundColor = backgroundColor
//        delegateProxy.backup?.value?.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
//    }
//
//    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
//        (view as? UITableViewHeaderFooterView)?.contentView.backgroundColor = backgroundColor
//        delegateProxy.backup?.value?.tableView?(tableView, willDisplayFooterView: view, forSection: section)
//    }
}

public class TableSection<Data, Cell: UIView, CellEvent>: TableBoxSection {
    public weak var tableBox: TableBox?

    public let dataSource = State<[Data]>([])

    private let object = NSObject()

    public typealias HeaderFooterGenerator<Data, CellEvent> = (SimpleOutput<Data>, SimpleInput<CellEvent>) -> UIView?
    var headerGenerator: HeaderFooterGenerator<RecycleContext<[Data], UITableView>, CellEvent>
    var footerGenerator: HeaderFooterGenerator<RecycleContext<[Data], UITableView>, CellEvent>

    public typealias CellGenerator<Data, Cell, CellEvent> = (SimpleOutput<Data>, SimpleInput<CellEvent>) -> Cell
    var cellGenerator: CellGenerator<RecycleContext<Data, UITableView>, Cell, CellEvent>

    public typealias CellUpdater<Data, Cell> = (UITableViewCell, Cell, RecycleContext<Data, UITableView>) -> Void
    var cellUpdater: CellUpdater<Data, Cell>

    public typealias OnCellEvent<Event> = (Event) -> Void
    var onCellEvent: OnCellEvent<Event>

    public typealias OnBoxEvent = (EventContext) -> Void
    var onBoxEvent: OnBoxEvent

    public var identifier: String
    private var diffIdentifier: ((Data) -> String)?
    private var selectionStyle: UITableViewCell.SelectionStyle
    private var dataIds = [String]()
    public init(identifier: String,
                selectionStyle: UITableViewCell.SelectionStyle = .default,
                dataSource: SimpleOutput<[Data]>,
                _diffIdentifier: ((Data) -> String)? = nil,
                _cell: @escaping CellGenerator<RecycleContext<Data, UITableView>, Cell, CellEvent>,
                _cellUpdater: @escaping CellUpdater<Data, Cell> = { _, _, _ in },
                _header: @escaping HeaderFooterGenerator<RecycleContext<[Data], UITableView>, CellEvent> = { _, _ in EmptyView() },
                _footer: @escaping HeaderFooterGenerator<RecycleContext<[Data], UITableView>, CellEvent> = { _, _ in EmptyView() },
                _event: @escaping OnCellEvent<Event> = { _ in },
                _onEvent: @escaping OnBoxEvent = { _ in }) {
        self.identifier = identifier
        cellGenerator = _cell
        cellUpdater = _cellUpdater
        headerGenerator = _header
        footerGenerator = _footer
        onCellEvent = _event
        onBoxEvent = _onEvent
        self.selectionStyle = selectionStyle
        diffIdentifier = _diffIdentifier
        dataSource.safeBind(to: object) { [weak self] _, data in
            self?.reload(with: data)
        }
    }

    public enum Event {
        case didSelect(Int, Data)
        case headerEvent(Int, [Data], CellEvent)
        case footerEvent(Int, [Data], CellEvent)
        case itemEvent(Int, Data, CellEvent)
    }

    public struct EventContext {
        public enum Event {
            case didSelect
            case headerEvent
            case footerEvent
            case itemEvent(CellEvent)
        }

        public var event: Event
        public var recycleCtx: RecycleContext<Data, UITableView>
    }

    public func numberOfRows() -> Int {
        return dataSource.value.count
    }

    public func didSelect(row: Int) {
        trigger(event: .didSelect, idx: row)
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

    func trigger(event: EventContext.Event, idx: Int) {
        guard let ctx = getEventContext(event: event, index: idx) else { return }
        onBoxEvent(ctx)
    }

    func getEventContext(event: EventContext.Event, index: Int) -> EventContext? {
        guard let tv = tableBox else { return nil }
        return EventContext(event: event, recycleCtx: .init(index: index, size: getLayoutableContentSize(tv), data: dataSource.value[index], view: tableBox))
    }

    private func getLayoutableContentSize(_ cv: UITableView) -> CGSize {
        let width = cv.bounds.size.width - cv.contentInset.left - cv.contentInset.right
        let height = cv.bounds.size.height - cv.contentInset.top - cv.contentInset.bottom
        return CGSize(width: width, height: height)
    }

    public func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let id = cellIdentifier()
        var cell = tableView.dequeueReusableCell(withIdentifier: id) as? TableBoxCell<Data, CellEvent>
        let data = dataSource.value[indexPath.row]
        let ctx = RecycleContext(index: indexPath.row, size: getLayoutableContentSize(tableView), data: data, view: tableView)
        if cell == nil {
            let state = State(ctx)
            let event = SimpleIO<CellEvent>()
            cell = TableBoxCell<Data, CellEvent>(id: id,
                                                 root: cellGenerator(state.asOutput(), event.asInput()),
                                                 state: state,
                                                 event: event)
        } else {
            cell?.state.value = ctx
        }
        cell?.selectionStyle = selectionStyle
        cell?.onEvent = { [weak self, weak cell] event in
            guard let cell = cell, let self = self, let index = self.tableBox?.indexPath(for: cell) else { return }
//            let idx = cell.state.value.index
            let idx = index.row
            let data = cell.state.value.data
            if let ctx = self.getEventContext(event: .itemEvent(event), index: idx) {
                self.onBoxEvent(ctx)
            }
            self.onCellEvent(.itemEvent(idx, data, event))
        }

        if let cell = cell, let view = cell.root as? Cell {
            cellUpdater(cell, view, ctx)
        }

        return cell!
    }

    public func header(for tableView: UITableView, at section: Int) -> UIView? {
        let id = headerIdentifier()
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: id) as? TableHeaderFooter<[Data], CellEvent>

        if view == nil {
            let state = State(RecycleContext(index: section, size: getLayoutableContentSize(tableView), data: dataSource.value, view: tableView))
            let event = SimpleIO<CellEvent>()
            guard let root = headerGenerator(state.asOutput(), event.asInput()) else {
                return nil
            }
            view = TableHeaderFooter<[Data], CellEvent>(id: id,
                                                        root: root,
                                                        state: state,
                                                        event: event)
        } else {
            view?.state.value = RecycleContext(index: section, size: getLayoutableContentSize(tableView), data: dataSource.value, view: tableView)
        }

        view?.backgroundView?.backgroundColor = tableView.backgroundColor
        view?.onEvent = { [weak self, weak view] e in
            guard let self = self, let header = view else { return }
            self.trigger(event: .headerEvent, idx: header.state.value.index)
            self.onCellEvent(.headerEvent(header.state.value.index, header.state.value.data, e))
        }

        return view!
    }

    public func footer(for tableView: UITableView, at section: Int) -> UIView? {
        let id = footerIdentifier()
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: id) as? TableHeaderFooter<[Data], CellEvent>

        if view == nil {
            let state = State(RecycleContext(index: section, size: getLayoutableContentSize(tableView), data: dataSource.value, view: tableView))
            let event = SimpleIO<CellEvent>()
            guard let root = footerGenerator(state.asOutput(), event.asInput()) else {
                return nil
            }
            view = TableHeaderFooter<[Data], CellEvent>(id: id,
                                                        root: root,
                                                        state: state,
                                                        event: event)
        } else {
            view?.state.value = RecycleContext(index: section, size: getLayoutableContentSize(tableView), data: dataSource.value, view: tableView)
        }
        view?.backgroundView?.backgroundColor = tableView.backgroundColor
        view?.onEvent = { [weak self, weak view] e in
            guard let self = self, let header = view else { return }
            self.trigger(event: .footerEvent, idx: header.state.value.index)
            self.onCellEvent(.footerEvent(header.state.value.index, header.state.value.data, e))
        }

        return view!
    }

    private func setDataSource(_ data: [Data]) {
        dataSource.value = data
        if let diffing = diffIdentifier {
            dataIds = data.map { diffing($0) }
        }
    }

    private func reload(with data: [Data]) {
        guard let box = tableBox else {
            setDataSource(data)
            return
        }

        guard box.bounds != .zero else {
            setDataSource(data)
            box.reload()
            return
        }

        guard let diffIdentifier = self.diffIdentifier else {
            setDataSource(data)
            box.reload()
            return
        }

        box.heightCache.removeAll()

        let newDataIds = data.map { diffIdentifier($0) }

        let diff = Diff(src: dataIds, dest: newDataIds, identifier: { $0 })
        diff.check()

        if diff.isDifferent(), let section = box.viewState.value.firstIndex(where: { $0 === self }) {
            setDataSource(data)
            func animations() {
                if !diff.delete.isEmpty {
                    box.deleteRows(at: diff.delete.map { IndexPath(row: $0.from, section: section) }, with: .automatic)
                }
                if !diff.insert.isEmpty {
                    box.insertRows(at: diff.insert.map { IndexPath(row: $0.to, section: section) }, with: .automatic)
                }
                diff.move.forEach { c in
                    box.moveRow(at: IndexPath(row: c.from, section: section), to: IndexPath(row: c.to, section: section))
                }
            }
            if #available(iOS 11.0, *) {
                box.performBatchUpdates({
                    animations()
                }, completion: nil)
            } else {
                box.beginUpdates()
                animations()
                box.endUpdates()
            }
        }
    }

    private class TableBoxCell<Data, E>: UITableViewCell {
        var root: UIView
        let state: State<RecycleContext<Data, UITableView>>
        let event: SimpleIO<E>
        var onEvent: (E) -> Void = { _ in }

        required init(id: String, root: UIView, state: State<RecycleContext<Data, UITableView>>, event: SimpleIO<E>) {
            self.root = root
            self.state = state
            self.event = event
            super.init(style: .value1, reuseIdentifier: id)
            contentView.addSubview(root)
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            event.safeBind(to: self) { (this, e) in
                this.onEvent(e)
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

    private class TableHeaderFooter<D, E>: UITableViewHeaderFooterView {
        var root: UIView
        let state: State<RecycleContext<D, UITableView>>
        let event: SimpleIO<E>
        var onEvent: (E) -> Void = { _ in }

        required init(id: String, root: UIView, state: State<RecycleContext<D, UITableView>>, event: SimpleIO<E>) {
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
            event.safeBind(to: self) { (this, e) in
                this.onEvent(e)
            }
        }

        required init?(coder _: NSCoder) {
            fatalError()
        }

        override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
            return root.sizeThatFits(targetSize)
        }
    }

    deinit {}
}

public extension Puyo where T: TableBox {
    @discardableResult
    func wrapContent(_: Bool = true) -> Self {
        view.wrapContent = true
        view.py_setNeedsLayout()
        return self
    }

    @discardableResult
    func reload<O: Outputing>(_ when: O) -> Self where O.OutputType: Any {
        when.safeBind(to: view) { v, _ in
            v.reloadData()
        }
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
