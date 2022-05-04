//
//  RBSegmentViewController.swift
//  RBSegmentViewControl
//
//  Created by Rishon on 2022/5/3.
//

import UIKit

class RBSegmentViewController: UIViewController {

    var vcCanScroll:Bool = false {
        didSet {
            collectionView.vcCanScroll = vcCanScroll
        }
    }
    
    var viewHeight: CGFloat = 0.0
    var currentIndex: Int = 0
    
    required init(_ viewHeight: CGFloat, currentIndex: Int) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewHeight = viewHeight
        self.currentIndex = currentIndex
        
        view.addSubview(collectionView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshWithData()
    }
    
    func refreshWithData() {
    
        collectionView.updateData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    lazy var collectionView: RBSegmentCollectionView = {
        let collectionView = RBSegmentCollectionView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: viewHeight))
        collectionView.currentIndex = currentIndex
        return collectionView
    }()

}
