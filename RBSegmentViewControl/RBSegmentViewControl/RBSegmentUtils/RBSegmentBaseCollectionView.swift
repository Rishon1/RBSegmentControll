//
//  RBSegmentBaseCollectionView.swift
//  RBSegmentViewControl
//
//  Created by Rishon on 2022/5/3.
//

import UIKit

class RBSegmentBaseCollectionView: UICollectionView {

}

class RBSegmentBaseTableView: UITableView, UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let view = otherGestureRecognizer.view
        if view is RBSegmentBaseCollectionView {
            return true
        }
        return false
    }
}
