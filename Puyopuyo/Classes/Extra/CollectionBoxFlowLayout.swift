//
//  CollectionBoxFlowLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2020/1/9.
//

import UIKit

private func belowiOS9() -> Bool {
    if #available(iOS 9.0, *) {
        return false
    }
    // 先测试，所有都使用自定义layout控制header悬浮
    return true
}

public protocol CollectionHeaderPinable {
    func setSectionHeaderPin(_ pin: Bool)
}

extension UICollectionViewFlowLayout: CollectionHeaderPinable {
    @objc public func setSectionHeaderPin(_ pin: Bool) {
        if !belowiOS9() {
            if #available(iOS 9.0, *) {
                sectionHeadersPinToVisibleBounds = pin
            }
        }
    }
}

/// 负责处理iOS9以下，header悬浮问题
public class CollectionBoxFlowLayout: UICollectionViewFlowLayout {
    public override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var pinHeader = false
    @objc public override func setSectionHeaderPin(_ pin: Bool) {
        if !belowiOS9() {
            super.setSectionHeaderPin(pin)
        } else {
            pinHeader = pin
        }
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if !belowiOS9() || !pinHeader {
            return super.layoutAttributesForElements(in: rect)
        }
        // UICollectionViewLayoutAttributes：称它为collectionView中的item（包括cell和header、footer这些）的《结构信息》
        var attributesArray: [UICollectionViewLayoutAttributes] = []
        if let superAttributesArray = super.layoutAttributesForElements(in: rect) {
            attributesArray = superAttributesArray
        }

        // 创建存索引的数组，无符号（正整数），无序（不能通过下标取值），不可重复（重复的话会自动过滤）
//        let noneHeaderSections = NSMutableIndexSet()
        var noneHeaderSections = Set<Int>()

        // 遍历superArray，得到一个当前屏幕中所有的section数组
        for attributes in attributesArray {
            // 如果当前的元素分类是一个cell，将cell所在的分区section加入数组，重复的话会自动过滤
            if attributes.representedElementCategory == .cell {
                noneHeaderSections.insert(attributes.indexPath.section)
            }
        }

        // 遍历superArray，将当前屏幕中拥有的header的section从数组中移除，得到一个当前屏幕中没有header的section数组
        // 正常情况下，随着手指往上移，header脱离屏幕会被系统回收而cell尚在，也会触发该方法
        for attributes in attributesArray {
            if let kind = attributes.representedElementKind {
                // 如果当前的元素是一个header，将header所在的section从数组中移除
                if kind == UICollectionView.elementKindSectionHeader {
                    noneHeaderSections.remove(attributes.indexPath.section)
                }
            }
        }

        // 遍历当前屏幕中没有header的section数组
        noneHeaderSections.forEach { section in
            // 取到当前section中第一个item的indexPath
//            let indexPath = NSIndexPath(forRow: 0, inSection: index)
            let indexPath = IndexPath(row: 0, section: section)
            // 获取当前section在正常情况下已经离开屏幕的header结构信息
            if let attributes =
                self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
                // 如果当前分区确实有因为离开屏幕而被系统回收的header，将该header结构信息重新加入到superArray中去
                attributesArray.append(attributes)
            }
        }
        noneHeaderSections.forEach { section in
            let indexPath = IndexPath(row: 0, section: section)
            if let attributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
                attributesArray.append(attributes)
            }
        }

        // 遍历superArray，改变header结构信息中的参数，使它可以在当前section还没完全离开屏幕的时候一直显示
        for attributes in attributesArray {
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                let section = attributes.indexPath.section

                let firstItemIndexPath = IndexPath(row: 0, section: section)

                var numberOfItemsInSection = 0
                // 得到当前header所在分区的cell的数量
                if let number = collectionView?.numberOfItems(inSection: section) {
                    numberOfItemsInSection = number
                }

                // 得到最后一个item的indexPath
                let lastItemIndexPath = IndexPath(row: max(0, numberOfItemsInSection - 1), section: section)

                // 得到第一个item和最后一个item的结构信息
                let firstItemAttributes: UICollectionViewLayoutAttributes!
                let lastItemAttributes: UICollectionViewLayoutAttributes!
                if numberOfItemsInSection > 0 {
                    // cell有值，则获取第一个cell和最后一个cell的结构信息
                    firstItemAttributes = layoutAttributesForItem(at: firstItemIndexPath)
                    lastItemAttributes = layoutAttributesForItem(at: lastItemIndexPath)
                } else {
                    // cell没值,就新建一个UICollectionViewLayoutAttributes
                    firstItemAttributes = UICollectionViewLayoutAttributes()
                    // 然后模拟出在当前分区中的唯一一个cell，cell在header的下面，高度为0，还与header隔着可能存在的sectionInset的top
                    let itemY = attributes.frame.maxY + sectionInset.top
                    firstItemAttributes.frame = CGRect(x: 0, y: itemY, width: 0, height: 0)
                    // 因为只有一个cell，所以最后一个cell等于第一个cell
                    lastItemAttributes = firstItemAttributes
                }

                // 获取当前header的frame
                var rect = attributes.frame

                // 当前的滑动距离 + 因为导航栏产生的偏移量，默认为64（如果app需求不同，需自己设置）
                var offset_Y: CGFloat = 0
                if let y = collectionView?.contentOffset.y {
                    offset_Y = y
                }
//                offset_Y = offset_Y + naviHeight
                offset_Y = offset_Y + (collectionView?.contentInset.top ?? 0)

                // 第一个cell的y值 - 当前header的高度 - 可能存在的sectionInset的top
                let headerY = firstItemAttributes.frame.origin.y - rect.size.height - sectionInset.top

                // 哪个大取哪个，保证header悬停
                // 针对当前header基本上都是offset更加大，针对下一个header则会是headerY大，各自处理
                let maxY = max(offset_Y, headerY)

                // 最后一个cell的y值 + 最后一个cell的高度 + 可能存在的sectionInset的bottom - 当前header的高度
                // 当当前section的footer或者下一个section的header接触到当前header的底部，计算出的headerMissingY即为有效值
                let headerMissingY = lastItemAttributes.frame.maxY + sectionInset.bottom - rect.size.height

                // 给rect的y赋新值，因为在最后消失的临界点要跟谁消失，所以取小
                rect.origin.y = min(maxY, headerMissingY)
                // 给header的结构信息的frame重新赋值
                attributes.frame = rect

                // 如果按照正常情况下,header离开屏幕被系统回收，而header的层次关系又与cell相等，如果不去理会，会出现cell在header上面的情况
                // 通过打印可以知道cell的层次关系zIndex数值为0，我们可以将header的zIndex设置成1，如果不放心，也可以将它设置成非常大
                attributes.zIndex = 1024
            }
        }

        return attributesArray
    }

    public override func shouldInvalidateLayout(forBoundsChange bounds: CGRect) -> Bool {
        if !belowiOS9() {
            return super.shouldInvalidateLayout(forBoundsChange: bounds)
        }
        return true
    }
}
