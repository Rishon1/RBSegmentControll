//
//  RBSegmentCollectionView.swift
//  RBSegmentViewControl
//
//  Created by Rishon on 2022/5/3.
//

import UIKit

public let rbNotificationScrollTop = "rbNotificationScrollTop"

class RBSegmentCollectionView: UIView {
    var vcCanScroll:Bool = true
    
    var currentIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
        collectionView.frame = frame
        
    }
    
    func updateData() {
        
        collectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var collectionView: RBSegmentBaseCollectionView = {
        let collectionView = RBSegmentBaseCollectionView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), collectionViewLayout: flowLayout)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "UICollectionViewCell")
        return collectionView
    }()
    
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: kScreenWidth, height: 270)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        return layout
    }()

}


extension RBSegmentCollectionView: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = currentIndex == 0 ? .orange : .red
        }
        else {
            cell.backgroundColor = currentIndex == 0 ? .yellow : .green
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !vcCanScroll {
            scrollView.contentOffset = CGPoint.zero
        }
        
        if scrollView.contentOffset.y <= 0 {
            vcCanScroll = false
            scrollView.contentOffset = CGPoint.zero
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: rbNotificationScrollTop), object: nil)
        }
    }
}
