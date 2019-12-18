//
//  TableBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/16.
//

import UIKit

public protocol TableBoxDelegatable {
    func setDelegate(_ delegate: UITableViewDelegate, retained: Bool)
    func setDataSource(_ dataSource: UITableViewDataSource, retained: Bool)
}

public class TableBox<Data, Cell: UIView, CellEvent>:
    ZBox,
    StatefulView,
    EventableView,
    TableBoxDelegatable,
    UITableViewDataSource,
    UITableViewDelegate {
    public struct Event {
        public enum EventType {
            case cellEvent(CellEvent)
            case cellSelect
        }

        public var eventType: EventType
        public var data: Data
        public var indexPath: IndexPath
    }

    private var heightCache = [IndexPath: CGFloat]()

    public var viewState = State<[[Data]]>([])

    public var eventProducer = SimpleIO<Event>()

    public private(set) var tableView: UITableView

    private var delegateProxy: DelegateProxy<UITableViewDelegate>! {
        didSet {
            tableView.delegate = delegateProxy
        }
    }
    private var dataSourceProxy: DelegateProxy<UITableViewDataSource>! {
        didSet {
            tableView.dataSource = dataSourceProxy
        }
    }
    
    public func setDelegate(_ delegate: UITableViewDelegate, retained: Bool) {
        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: RetainWrapper(value: delegate, retained: retained))
    }
    
    public func setDataSource(_ dataSource: UITableViewDataSource, retained: Bool) {
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: RetainWrapper(value: dataSource, retained: retained))
    }

    public typealias CellGenerator<Data, Cell, CellEvent> = (SimpleOutput<(Data, IndexPath)>, SimpleInput<CellEvent>) -> Cell
    var cellGenerator: CellGenerator<Data, Cell, CellEvent>

    public required init(tableView: @escaping BoxGenerator<UITableView> = { UITableView() },
                         cell: @escaping CellGenerator<Data, Cell, CellEvent>,
                         header: BoxGenerator<UIView>? = nil,
                         footer: BoxGenerator<UIView>? = nil) {
        self.tableView = tableView()
        cellGenerator = cell
        super.init(frame: .zero)

        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)
        
        self.tableView.delegate = delegateProxy
        self.tableView.dataSource = dataSourceProxy

        self.tableView.attach(self).size(.fill, .fill)
        let headerView = ZBox().attach {
            header?().attach($0)
        }
        .size(.fill, .wrap)
        .isSelfPositionControl(false)
        .view

        let footerView = ZBox().attach {
            footer?().attach($0)
        }
        .isSelfPositionControl(false)
        .size(.fill, .wrap)
        .view

        self.tableView.tableHeaderView = headerView
        self.tableView.tableFooterView = footerView
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableView.automaticDimension
        viewState.safeBind(to: self) { s, _ in
            s.heightCache.removeAll()
            var height = headerView.sizeThatFits(CGSize(width: s.tableView.bounds.width, height: 0)).height
            s.tableView.tableHeaderView?.frame.size.height = height

            s.tableView.reloadData()

            height = headerView.sizeThatFits(CGSize(width: s.tableView.bounds.width, height: 0)).height
            s.tableView.tableFooterView?.frame.size.height = height
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }

    public func numberOfSections(in _: UITableView) -> Int {
        return viewState.value.count
    }

    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewState.value[section].count
    }

    let cellId = "BoxCell"
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? BoxCell<Data, CellEvent>
        let data = viewState.value[indexPath.section][indexPath.row]
        if cell == nil {
            let state = State((data, indexPath))
            let event = SimpleIO<CellEvent>()
            cell = BoxCell<Data, CellEvent>(id: cellId,
                                            root: cellGenerator(state.asOutput(), event.asInput()),
                                            state: state,
                                            event: event)

            event.safeBind(to: self) { [weak cell] s, e in
                guard let idx = cell?.state.value.1 else { return }
                let data = s.viewState.value[idx.section][idx.row]
                s.eventProducer.input(value: .init(eventType: .cellEvent(e), data: data, indexPath: idx))
            }
        } else {
            cell?.state.value = (data, indexPath)
        }
        return cell!
    }

    public func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heightCache[indexPath] {
            return height
        }
        return UITableView.automaticDimension
    }

    public func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightCache[indexPath] = cell.bounds.height
        delegateProxy.backup?.value?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        eventProducer.input(value: .init(eventType: .cellSelect, data: viewState.value[indexPath.section][indexPath.row], indexPath: indexPath))
        delegateProxy.backup?.value?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    private class BoxCell<T, E>: UITableViewCell {
        var root: UIView
        var state: State<(T, IndexPath)>
        var event: SimpleIO<E>

        required init(id: String, root: UIView, state: State<(T, IndexPath)>, event: SimpleIO<E>) {
            self.root = root
            self.state = state
            self.event = event
            super.init(style: .value1, reuseIdentifier: id)
            contentView.addSubview(root)
        }

        required init?(coder _: NSCoder) {
            fatalError()
        }

        override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
            return root.sizeThatFits(targetSize)
        }
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

extension Puyo where T: TableBoxDelegatable {

    @discardableResult
    public func setDelegate(_ delegate: UITableViewDelegate, retained: Bool = false) -> Self {
        view.setDelegate(delegate, retained: retained)
        return self
    }
    
    @discardableResult
    public func setDataSource(_ dataSource: UITableViewDataSource, retained: Bool = false) -> Self {
        view.setDataSource(dataSource, retained: retained)
        return self
    }
}
