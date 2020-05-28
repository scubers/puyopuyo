//
//  ListSection.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/18.
//

import Foundation

public class SequenceSection<Section, Data>: BasicSequenceSection<Section> {
    public init(id: String,
                selectionStyle: UITableViewCell.SelectionStyle = .default,
                rowHeight: CGFloat? = nil,
                headerHeight: CGFloat? = nil,
                footerHeight: CGFloat? = nil,
                data: Section,
                differ: ((Data) -> String)? = nil,
                dataSource: SimpleOutput<[Data]> = [].asOutput(),
                _cell: @escaping SequenceViewGenerator<Data>,
                _cellConfig: ((UITableViewCell) -> Void)? = nil,
                _header: SequenceViewGenerator<Section>? = nil,
                _footer: SequenceViewGenerator<Section>? = nil,
                _didSelect: ((RecycleContext<Data, UITableView>) -> Void)? = nil) {
        let state = SimpleIO<[ISequenceItem]>()
        super.init(id: id, headerHeight: headerHeight, footerHeight: footerHeight, data: data, rows: state.asOutput(), _header: _header, _footer: _footer)
        dataSource
            .map { datas -> [ISequenceItem] in
                datas.map {
                    BasicSequenceItem<Data>(
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
            .unbind(by: bag)
    }
}

public typealias DataSequenceSection<Data> = SequenceSection<Void, Data>

public extension SequenceSection where Section == Void {
    convenience init(id: String,
                     selectionStyle: UITableViewCell.SelectionStyle = .default,
                     rowHeight: CGFloat? = nil,
                     headerHeight: CGFloat? = nil,
                     footerHeight: CGFloat? = nil,
                     differ: ((Data) -> String)? = nil,
                     dataSource: SimpleOutput<[Data]> = [].asOutput(),
                     _cell: @escaping SequenceViewGenerator<Data>,
                     _cellConfig: ((UITableViewCell) -> Void)? = nil,
                     _header: SequenceViewGenerator<Section>? = nil,
                     _footer: SequenceViewGenerator<Section>? = nil,
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
