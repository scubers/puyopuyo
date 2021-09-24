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
        dataSource: Outputs<[Data]>,
        differ: ((Data) -> String)? = nil,
        cell: @escaping SequenceViewGenerator<Data>,
        cellConfig: ((UITableViewCell) -> Void)? = nil,
        header: SequenceViewGenerator<Section>? = nil,
        footer: SequenceViewGenerator<Section>? = nil,
        didSelect: ((RecyclerInfo<Data>) -> Void)? = nil,
        function: StaticString = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        let state = SimpleIO<[ISequenceItem]>()
        super.init(id: id, data: data, items: state.asOutput(), headerHeight: headerHeight, footerHeight: footerHeight, header: header, footer: footer, function: function, line: line, column: column)

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
                        cell: cell,
                        cellConfig: cellConfig,
                        didSelect: didSelect,
                        function: function,
                        line: line,
                        column: column
                    )
                }
            }
            .send(to: state)
            .dispose(by: self)
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
        dataSource: Outputs<[Data]>,
        differ: ((Data) -> String)? = nil,
        cell: @escaping SequenceViewGenerator<Data>,
        cellConfig: ((UITableViewCell) -> Void)? = nil,
        header: SequenceViewGenerator<Section>? = nil,
        footer: SequenceViewGenerator<Section>? = nil,
        didSelect: ((RecyclerInfo<Data>) -> Void)? = nil,
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
            cell: cell,
            cellConfig: cellConfig,
            header: header,
            footer: footer,
            didSelect: didSelect,
            function: function,
            line: line,
            column: column
        )
    }
}
