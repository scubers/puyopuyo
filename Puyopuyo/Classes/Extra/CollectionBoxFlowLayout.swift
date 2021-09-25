//
//  CollectionBoxFlowLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2020/1/9.
//

import UIKit

// private class Context: UICollectionViewFlowLayoutInvalidationContext {}

public class CollectionBoxFlowLayout: UICollectionViewFlowLayout {
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }

    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
    }
}
