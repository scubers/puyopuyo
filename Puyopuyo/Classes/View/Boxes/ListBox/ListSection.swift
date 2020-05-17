//
//  ListSection.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/18.
//

import Foundation

public class ListSection<Section, Data>: BasicListSection<Section> {
    public init(id: String,
                selectionStyle: UITableViewCell.SelectionStyle = .default,
                rowHeight: CGFloat? = nil,
                headerHeight: CGFloat? = nil,
                footerHeight: CGFloat? = nil,
                data: Section,
                differ: ((Data) -> String)? = nil,
                dataSource: SimpleOutput<[Data]> = [].asOutput(),
                _cell: @escaping ListViewGenerator<Data>,
                _cellConfig: ((UITableViewCell) -> Void)? = nil,
                _header: ListViewGenerator<Section>? = nil,
                _footer: ListViewGenerator<Section>? = nil,
                _didSelect: ((RecycleContext<Data, UITableView>) -> Void)? = nil) {
        let state = SimpleIO<[IListRow]>()
        super.init(id: id, headerHeight: headerHeight, footerHeight: footerHeight, data: data, rows: state.asOutput(), _header: _header, _footer: _footer)
        _ = dataSource
            .map { datas -> [IListRow] in
                datas.map {
                    BasicListRow<Data>(
                        id: "\(id)_buildin_row",
                        selectionStyle: selectionStyle,
                        rowHeight: rowHeight,
                        data: $0,
                        differ: differ,
                        _cell: _cell,
                        _cellConfig: _cellConfig,
                        _didSelect: _didSelect
                    )
                }
            }
            .send(to: state)
    }
}

public typealias PureListSection<Data> = ListSection<Void, Data>

public extension ListSection where Section == Void {
    convenience init(id: String,
                     selectionStyle: UITableViewCell.SelectionStyle = .default,
                     rowHeight: CGFloat? = nil,
                     headerHeight: CGFloat? = nil,
                     footerHeight: CGFloat? = nil,
                     differ: ((Data) -> String)? = nil,
                     dataSource: SimpleOutput<[Data]> = [].asOutput(),
                     _cell: @escaping ListViewGenerator<Data>,
                     _cellConfig: ((UITableViewCell) -> Void)? = nil,
                     _header: ListViewGenerator<Section>? = nil,
                     _footer: ListViewGenerator<Section>? = nil,
                     _didSelect: ((RecycleContext<Data, UITableView>) -> Void)? = nil) {
        self.init(
            id: id,
            selectionStyle: selectionStyle,
            rowHeight: rowHeight,
            headerHeight: headerHeight,
            footerHeight: footerHeight,
            data: (),
            differ: differ,
            dataSource: dataSource,
            _cell: _cell,
            _cellConfig: _cellConfig,
            _header: _header,
            _footer: _footer,
            _didSelect: _didSelect
        )
    }
}
