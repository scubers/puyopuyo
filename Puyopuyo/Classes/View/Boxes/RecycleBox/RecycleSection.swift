//
//  RecycleSection.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/5/12.
//

import Foundation

public class RecycleSection<Section, Data, SectionEvent, ItemEvent>: BasicRecycleSection<Section, SectionEvent> {
    public typealias SectionContext = RecycleContext<Section, UICollectionView>
    public typealias ItemContext = RecycleContext<Data, UICollectionView>

    public init(
        id: String,
        insets: UIEdgeInsets? = nil,
        lineSpacing: CGFloat? = nil,
        itemSpacing: CGFloat? = nil,
        sectionData: Section,
        list: SimpleOutput<[Data]>,
        differ: ((Data) -> String)? = nil,
        _cell: @escaping RecycleViewGenerator<ItemContext, ItemEvent>,
        _header: RecycleViewGenerator<SectionContext, SectionEvent>? = nil,
        _footer: RecycleViewGenerator<SectionContext, SectionEvent>? = nil,
        _sectionEvent: ((SectionEvent, SectionContext) -> Void)? = nil,
        _itemEvent: ((ItemEvent, ItemContext) -> Void)? = nil
    ) {
        let state = State([IRecycleItem]())
        super.init(id: id, insets: insets, lineSpacing: lineSpacing, itemSpacing: itemSpacing, data: sectionData, items: state.asOutput(), _header: _header, _footer: _footer, _event: _sectionEvent)

        _ = list.map { datas in
            datas.map { data in
                BasicRecycleItem<Data, ItemEvent>(id: "\(self.getSectionId())_buildin_item", data: data, _cell: _cell)
            }
        }
        .send(to: state)
    }
}

public typealias ListRecycleSection<Data, ItemEvent> = RecycleSection<Void, Data, Void, ItemEvent>

public extension RecycleSection where Section == Void, SectionEvent == Void {
    convenience init(
        id: String,
        insets: UIEdgeInsets? = nil,
        lineSpacing: CGFloat? = nil,
        itemSpacing: CGFloat? = nil,
        list: SimpleOutput<[Data]>,
        differ: ((Data) -> String)? = nil,
        _cell: @escaping RecycleViewGenerator<ItemContext, ItemEvent>,
        _header: RecycleViewGenerator<SectionContext, SectionEvent>? = nil,
        _footer: RecycleViewGenerator<SectionContext, SectionEvent>? = nil,
        _itemEvent: ((ItemEvent, ItemContext) -> Void)? = nil
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
            _header: _header,
            _footer: _footer,
            _sectionEvent: nil,
            _itemEvent: _itemEvent
        )
    }
}
//
//public class ListRecycleSection<Data, SectionEvent, ItemEvent>: RecycleSection<Any?, Data, SectionEvent, ItemEvent> {
//    public typealias SectionContext = RecycleContext<Any, UICollectionView>
//    public typealias ItemContext = RecycleContext<Data, UICollectionView>
//
//    public init(
//        id: String,
//        insets: UIEdgeInsets? = nil,
//        lineSpacing: CGFloat? = nil,
//        itemSpacing: CGFloat? = nil,
//        list: SimpleOutput<[Data]>,
//        differ: ((Data) -> String)? = nil,
//        _cell: @escaping RecycleViewGenerator<ItemContext, ItemEvent>,
//        _header: RecycleViewGenerator<SectionContext, SectionEvent>? = nil,
//        _footer: RecycleViewGenerator<SectionContext, SectionEvent>? = nil,
//        _sectionEvent: ((SectionEvent, SectionContext) -> Void)? = nil,
//        _itemEvent: ((ItemEvent, ItemContext) -> Void)? = nil
//    ) {
//        let state = State([IRecycleItem]())
////        super.init(id: id, insets: insets, lineSpacing: lineSpacing, itemSpacing: itemSpacing, data: nil, items: state.asOutput(), _header: _header, _footer: _footer, _event: _sectionEvent)
//
//        _ = list.map { datas in
//            datas.map { data in
//                BasicRecycleItem<Data, ItemEvent>(id: "\(self.getSectionId())_buildin_item", data: data, _cell: _cell)
//            }
//        }
//        .send(to: state)
//    }}
