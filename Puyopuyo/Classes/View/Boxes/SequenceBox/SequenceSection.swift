//
//  ListSection.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/18.
//

import Foundation

public class SequenceSection<Section, Data>: BasicSequenceSection<Section> {
    public init(
        id: String? = nil,
        selectionStyle: UITableViewCell.SelectionStyle = .default,
        rowHeight: CGFloat? = nil,
        headerHeight: CGFloat? = nil,
        footerHeight: CGFloat? = nil,
        data: Section,
        dataSource: SimpleOutput<[Data]>,
        differ: ((Data) -> String)? = nil,
        _cell: @escaping SequenceViewGenerator<Data>,
        _cellConfig: ((UITableViewCell) -> Void)? = nil,
        _header: SequenceViewGenerator<Section>? = nil,
        _footer: SequenceViewGenerator<Section>? = nil,
        _didSelect: ((RecycleContext<Data, UITableView>) -> Void)? = nil,
        function: StaticString = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        let state = SimpleIO<[ISequenceItem]>()
        super.init(id: id, headerHeight: headerHeight, footerHeight: footerHeight, data: data, rows: state.asOutput(), _header: _header, _footer: _footer, function: function, line: line, column: column)

        let itemId = getSectionId() + "buildin_item"
        dataSource
            .map { datas -> [ISequenceItem] in
                datas.map {
                    BasicSequenceItem<Data>(
                        id: itemId,
                        selectionStyle: selectionStyle,
                        rowHeight: rowHeight,
                        data: $0,
                        differ: differ,
                        _cell: _cell,
                        _cellConfig: _cellConfig,
                        _didSelect: _didSelect,
                        function: function,
                        line: line,
                        column: column
                    )
                }
            }
            .send(to: state)
            .unbind(by: bag)
    }
}

public typealias DataSequenceSection<Data> = SequenceSection<Void, Data>

public extension SequenceSection where Section == Void {
    convenience init(
        id: String? = nil,
        selectionStyle: UITableViewCell.SelectionStyle = .default,
        rowHeight: CGFloat? = nil,
        headerHeight: CGFloat? = nil,
        footerHeight: CGFloat? = nil,
        dataSource: SimpleOutput<[Data]>,
        differ: ((Data) -> String)? = nil,
        _cell: @escaping SequenceViewGenerator<Data>,
        _cellConfig: ((UITableViewCell) -> Void)? = nil,
        _header: SequenceViewGenerator<Section>? = nil,
        _footer: SequenceViewGenerator<Section>? = nil,
        _didSelect: ((RecycleContext<Data, UITableView>) -> Void)? = nil,
        function: StaticString = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        self.init(
            id: id,
            selectionStyle: selectionStyle,
            rowHeight: rowHeight,
            headerHeight: headerHeight,
            footerHeight: footerHeight,
            data: (),
            dataSource: dataSource,
            differ: differ,
            _cell: _cell,
            _cellConfig: _cellConfig,
            _header: _header,
            _footer: _footer,
            _didSelect: _didSelect,
            function: function,
            line: line,
            column: column
        )
    }
}
