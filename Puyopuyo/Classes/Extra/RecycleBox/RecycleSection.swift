//
//  RecycleSection.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/12.
//

import Foundation

public class RecycleSection<Section, Data>: BasicRecycleSection<Section> {
    public typealias ItemContext = RecyclerInfo<Data>

    public init(
        id: String? = nil,
        insets: UIEdgeInsets? = nil,
        lineSpacing: CGFloat? = nil,
        itemSpacing: CGFloat? = nil,
        sectionData: Section,
        items: Outputs<[Data]>,
        differ: ((Data) -> String)? = nil,
        cell: @escaping RecycleViewGenerator<Data>,
        cellConfig: ((UICollectionViewCell) -> Void)? = nil,
        header: RecycleViewGenerator<Section>? = nil,
        footer: RecycleViewGenerator<Section>? = nil,
        didSelect: ((ItemContext) -> Void)? = nil,
        function: StaticString = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        let state = State([IRecycleItem]())
        super.init(id: id, insets: insets, lineSpacing: lineSpacing, itemSpacing: itemSpacing, data: sectionData, items: state.asOutput(), header: header, footer: footer, function: function, line: line, column: column)

        let itemId = "\(self.getSectionId())_buildin_item"
        items.map {
            $0.map { data in
                BasicRecycleItem<Data>(
                    id: itemId,
                    data: data,
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

public typealias DataRecycleSection<Data> = RecycleSection<Void, Data>

public extension RecycleSection where Section == Void {
    convenience init(
        id: String? = nil,
        insets: UIEdgeInsets? = nil,
        lineSpacing: CGFloat? = nil,
        itemSpacing: CGFloat? = nil,
        items: Outputs<[Data]>,
        differ: ((Data) -> String)? = nil,
        cell: @escaping RecycleViewGenerator<Data>,
        cellConfig: ((UICollectionViewCell) -> Void)? = nil,
        header: RecycleViewGenerator<Section>? = nil,
        footer: RecycleViewGenerator<Section>? = nil,
        didSelect: ((ItemContext) -> Void)? = nil,
        function: StaticString = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        self.init(
            id: id,
            insets: insets,
            lineSpacing: lineSpacing,
            itemSpacing: itemSpacing,
            sectionData: (),
            items: items,
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
