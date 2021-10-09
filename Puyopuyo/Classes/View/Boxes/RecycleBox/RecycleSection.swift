//
//  RecycleSection.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/12.
//

import Foundation

public typealias DataRecycleSection = ListRecycleSection

public class ListRecycleSection<Data>: BasicRecycleSection<Void> {
    public typealias ItemContext = RecyclerInfo<Data>

    public init(
        id: String? = nil,
        insets: UIEdgeInsets? = nil,
        lineSpacing: CGFloat? = nil,
        itemSpacing: CGFloat? = nil,
        items: Outputs<[Data]>,
        diffableKey: ((Data) -> String)? = nil,
        cell: @escaping RecycleViewGenerator<Data>,
        header: RecycleViewGenerator<Void>? = nil,
        footer: RecycleViewGenerator<Void>? = nil,
        didSelect: ((ItemContext) -> Void)? = nil,
        function: StaticString = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        let state = State([IRecycleItem]())
        super.init(id: id, insets: insets, lineSpacing: lineSpacing, itemSpacing: itemSpacing, data: (), items: state.asOutput(), header: header, footer: footer, function: function, line: line, column: column)

        let itemId = "\(getSectionId())_buildin_item"
        items.map {
            $0.map { data in
                BasicRecycleItem<Data>(
                    id: itemId,
                    data: data,
                    diffableKey: diffableKey,
                    cell: cell,
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

public class SingleItemSection<Data>: ListRecycleSection<Data> {
    public init(
        item: Outputs<Data>,
        cell: @escaping RecycleViewGenerator<Data>,
        header: RecycleViewGenerator<Void>? = nil,
        footer: RecycleViewGenerator<Void>? = nil,
        didSelect: ((ItemContext) -> Void)? = nil,
        function: StaticString = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        super.init(id: nil, insets: nil, lineSpacing: nil, itemSpacing: nil, items: item.map { [$0] }, diffableKey: nil, cell: cell, header: header, footer: footer, didSelect: didSelect, function: function, line: line, column: column)
    }
}
