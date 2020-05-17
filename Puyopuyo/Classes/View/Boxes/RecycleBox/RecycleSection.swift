//
//  RecycleSection.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/12.
//

import Foundation

public class RecycleSection<Section, Data>: BasicRecycleSection<Section> {
    public typealias ItemContext = RecycleContext<Data, UICollectionView>

    public init(
        id: String,
        insets: UIEdgeInsets? = nil,
        lineSpacing: CGFloat? = nil,
        itemSpacing: CGFloat? = nil,
        sectionData: Section,
        list: SimpleOutput<[Data]>,
        differ: ((Data) -> String)? = nil,
        _cell: @escaping RecycleViewGenerator<Data>,
        _cellConfig: ((UICollectionViewCell) -> Void)? = nil,
        _header: RecycleViewGenerator<Section>? = nil,
        _footer: RecycleViewGenerator<Section>? = nil,
        _didSelect: ((ItemContext) -> Void)? = nil
    ) {
        let state = State([IRecycleItem]())
        super.init(id: id, insets: insets, lineSpacing: lineSpacing, itemSpacing: itemSpacing, data: sectionData, items: state.asOutput(), _header: _header, _footer: _footer)

        _ = list.map { datas in
            datas.map { data in
                BasicRecycleItem<Data>(
                    id: "\(self.getSectionId())_buildin_item",
                    data: data,
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

public typealias ListRecycleSection<Data> = RecycleSection<Void, Data>

public extension RecycleSection where Section == Void {
    convenience init(
        id: String,
        insets: UIEdgeInsets? = nil,
        lineSpacing: CGFloat? = nil,
        itemSpacing: CGFloat? = nil,
        list: SimpleOutput<[Data]>,
        differ: ((Data) -> String)? = nil,
        _cell: @escaping RecycleViewGenerator<Data>,
        _cellConfig: ((UICollectionViewCell) -> Void)? = nil,
        _header: RecycleViewGenerator<Section>? = nil,
        _footer: RecycleViewGenerator<Section>? = nil,
        _didSelect: ((ItemContext) -> Void)? = nil
    ) {
        self.init(
            id: id,
            insets: insets,
            lineSpacing: lineSpacing,
            itemSpacing: itemSpacing,
            sectionData: (),
            list: list,
            differ: differ,
            _cell: _cell,
            _cellConfig: _cellConfig,
            _header: _header,
            _footer: _footer,
            _didSelect: _didSelect
        )
    }
}
