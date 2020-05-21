//
//  BasicListSection.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/17.
//

import Foundation

public struct ListContextHolder<D> {
    var creator: () -> RecycleContext<D, UITableView>?
    public func withContext(_ block: (RecycleContext<D, UITableView>) -> Void) {
        if let ctx = creator() {
            block(ctx)
        }
    }
}

public typealias ListViewGenerator<D> = (SimpleOutput<RecycleContext<D, UITableView>>, ListContextHolder<D>) -> UIView?

public class BasicListSection<Data>: IListSection {
    public init(id: String,
                headerHeight: CGFloat? = nil,
                estimatedHeaderHeight _: CGFloat? = nil,
                footerHeight: CGFloat? = nil,
                estimatedFooterHeight _: CGFloat? = nil,
                data: Data,
                rows: SimpleOutput<[IListRow]> = [].asOutput(),
                _header: ListViewGenerator<Data>? = nil,
                _footer: ListViewGenerator<Data>? = nil) {
        self.id = id
        self.headerGen = _header
        self.footerGen = _footer
        self.data = data
        self.headerHeight = headerHeight
        self.footerHeight = footerHeight
        rows.safeBind(to: bag) { [weak self] _, rows in
            self?.reload(rows: rows)
        }
    }
    
    private let bag = NSObject()
    private var headerGen: ListViewGenerator<Data>?
    private var footerGen: ListViewGenerator<Data>?
    private var id: String
    private var headerHeight: CGFloat?
    private var estimatedHeaderHeight: CGFloat?
    private var footerHeight: CGFloat?
    private var estimatedFooterHeight: CGFloat?
    
    private let rowsState = State<[IListRow]>([])
    public var data: Data
    public var index: Int = 0
    
    public weak var listBox: ListBox?
    
    public func getRows() -> [IListRow] {
        rowsState.value
    }
    
    public func headerView() -> UITableViewHeaderFooterView {
        let (view, _) = _get(header: true)
        return view
    }
    
    public func footerView() -> UITableViewHeaderFooterView {
        let (view, _) = _get(footer: true)
        return view
    }
    
    public func getHeaderHeight() -> CGFloat? {
        headerHeight
    }
    
    public func getEstimatedHeaderHeight() -> CGFloat? {
        estimatedHeaderHeight
    }
    
    public func getFooterHeight() -> CGFloat? {
        footerHeight
    }
    
    public func getEstimatedFooterHeight() -> CGFloat? {
        estimatedFooterHeight
    }
    
    private func getContext() -> RecycleContext<Data, UITableView> {
        .init(indexPath: IndexPath(row: 0, section: index), index: index, size: getLayoutableContentSize(), data: data, view: listBox)
    }
    
    private func _get(header: Bool = false, footer: Bool = false) -> (ListHeaderFooter<Data>, UIView?) {
        assert(header || footer)
        let id = header ? getHeaderId() : getFooterId()
        var view = listBox?.dequeueReusableHeaderFooterView(withIdentifier: id) as? ListHeaderFooter<Data>
        if view == nil {
            view = ListHeaderFooter<Data>(id: id)
            if header, let gen = headerGen {
                let holder = ListContextHolder<Data> { [weak self] in
                    if let box = self?.listBox,
                        let sectionIndex = self?.index,
                        let section = box.getSection(at: sectionIndex) as? BasicListSection<Data> {
                        return section.getContext()
                    }
                    return nil
                }
                if let root = gen(view!.state.asOutput(), holder) {
                    view?.root = root
                    view?.contentView.addSubview(root)
                }
            } else if footer, let gen = footerGen {
                let holder = ListContextHolder<Data> { [weak self] in
                    if let box = self?.listBox,
                        let sectionIndex = self?.index,
                        let section = box.getSection(at: sectionIndex) as? BasicListSection<Data> {
                        return section.getContext()
                    }
                    return nil
                }
                if let root = gen(view!.state.asOutput(), holder) {
                    view?.root = root
                    view?.contentView.addSubview(root)
                }
            }
        }
        view?.state.input(value: getContext())
        
        return (view!, view!.root)
    }
    
    private func getSectionId() -> String {
        "\(type(of: self))_\(id)"
    }
    
    private func getHeaderId() -> String {
        "\(getSectionId())_header"
    }
    
    private func getFooterId() -> String {
        "\(getSectionId())_footer"
    }
    
    private func setListRows(_ rows: [IListRow]) {
        rowsState.value = rows
        // 赋值section
        rows.forEach { $0.listSection = self }
    }
    
    private func reload(rows: [IListRow]) {
        // box 还没赋值时，只更新数据源
        guard let box = listBox else {
            setListRows(rows)
            return
        }
        
        // iOS低版本当bounds == zero 进行 增量更新的时候，会出现崩溃，高版本会警告
        guard box.bounds != .zero else {
            setListRows(rows)
            box.reloadData()
            return
        }
        
        guard box.enableDiff else {
            setListRows(rows)
            box.reloadData()
            return
        }
        
        // 需要做diff运算
        let diff = Diff(src: rowsState.value, dest: rows, identifier: { $0.getDiff() })
        diff.check()
        if diff.isDifferent(), let section = box.viewState.value.firstIndex(where: { $0 === self }) {
            setListRows(rows)
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
}

private class ListHeaderFooter<D>: UITableViewHeaderFooterView {
    var root: UIView?
    let state = SimpleIO<RecycleContext<D, UITableView>>()
    
    required init(id: String) {
        super.init(reuseIdentifier: id)
    }
    
    required init?(coder _: NSCoder) {
        fatalError()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
        return root?.sizeThatFits(targetSize) ?? CGSize(width: 0, height: 0.1)
    }
}

private class EmptyView: UITableViewHeaderFooterView {
    public override func sizeThatFits(_: CGSize) -> CGSize {
        return CGSize(width: 0, height: 0.1)
    }
}
