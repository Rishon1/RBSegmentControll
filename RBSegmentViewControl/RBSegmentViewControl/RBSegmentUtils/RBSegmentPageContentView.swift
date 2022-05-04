//
//  RBSegmentPageContentView.swift
//  RBSegmentViewControl
//
//  Created by Rishon on 2022/5/3.
//  

import UIKit

public let CellHeight = kScreenHeight - UIDevice.rb_navigationFullHeight() - UIDevice.rb_tabBarFullHeight()

/// 协议
@objc protocol RBSegmentPageContentViewDelegate {
    
    /// 开始滑动
    /// - Parameter contentView: 菜单视图
    @objc optional func contentViewWillBeginDragging(_ contentView: RBSegmentPageContentView)
    
    /// 滑动调用
    /// - Parameters:
    ///   - contentView: 菜单视图
    ///   - startIndex: 开始索引
    ///   - endIndex: 结束索引
    ///   - progress: 滑动进度
    @objc optional func contentViewDidScroll(_ contentView: RBSegmentPageContentView, startIndex: Int, endIndex: Int, progress: CGFloat)
    
    /// 结束滑动
    /// - Parameters:
    ///   - contentView: 菜单视图
    ///   - startIndex: 开始索引
    ///   - endIndex: 结束索引
    @objc optional func contentViewDidEndDecelerating(_ contentView: RBSegmentPageContentView, startIndex: Int, endIndex: Int)
    
    /// 结束滑动
    /// - Parameter contentView: 菜单视图
    @objc optional func contentViewDidEndDragging(_ contentView: RBSegmentPageContentView)
    
}

class RBSegmentPageContentView: UIView {
    
    weak var delegate:RBSegmentPageContentViewDelegate?
    
    //设置是否能左右滑动，默认true
    var contentViewCanScroll:Bool = true {
        didSet {
            collectionView.isScrollEnabled = contentViewCanScroll
        }
    }
    
    //设置当前展示的页面索引值，默认 0
    var contentViewCurrentIndex: Int = 0 {
        didSet {
            if contentViewCurrentIndex < 0 || contentViewCurrentIndex > childVcs.count - 1 {
                return
            }
            
            isSelectBtn = true
            
            collectionView.scrollToItem(at: IndexPath(row: contentViewCurrentIndex, section: 0), at: UICollectionView.ScrollPosition(rawValue: 0), animated: false)
        }
    }
    
    weak var parentVc: UIViewController?
    
    fileprivate var childVcs:[UIViewController] = []
    fileprivate var startOffsetX: CGFloat = 0.0
    //是否可以滑动
    fileprivate var isSelectBtn: Bool = false
    
    init(_ frame: CGRect, childVCs:[UIViewController], parentVc:RBHomeViewController) {
        super.init(frame: frame)
        
        self.childVcs = childVCs
        self.parentVc = parentVc
        self.delegate = parentVc
        
        setupSubViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var collectionView: RBSegmentBaseCollectionView = {
        let collectionView = RBSegmentBaseCollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "UICollectionViewCell")
        return collectionView
    }()
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: kScreenWidth, height: CellHeight)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }()
}

extension RBSegmentPageContentView: UICollectionViewDelegate, UICollectionViewDataSource{
    fileprivate func setupSubViews() {
        startOffsetX = 0
        isSelectBtn = false
        addSubview(collectionView)
        childVcs.forEach {
            self.parentVc?.addChild($0)
        }
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let childVc = childVcs[indexPath.row]
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        childVc.view.frame = cell.contentView.bounds
        
        cell.contentView.addSubview(childVc.view)
    }
}

extension RBSegmentPageContentView {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isSelectBtn = false
        startOffsetX = scrollView.contentOffset.x
        
        delegate?.contentViewWillBeginDragging?(self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //未滑动，直接return
        if isSelectBtn {
            return
        }
        
        let scrollViewW = scrollView.bounds.size.width
        let curOffsetX = scrollView.contentOffset.x
        let startIndex = Int(floor(startOffsetX/scrollViewW))
        var endIndex = 0
        var progress = 0.0
        
        //左滑
        if curOffsetX > startOffsetX {
            progress = (curOffsetX - startOffsetX)/scrollViewW
            endIndex = startIndex + 1
            if endIndex > childVcs.count - 1 {
                endIndex = childVcs.count - 1
            }
        }
        //没划过去
        else if curOffsetX == startOffsetX {
            progress = 0
            endIndex = startIndex
        }
        //右滑动
        else {
            progress = (startOffsetX - curOffsetX)/scrollViewW
            endIndex = startIndex - 1
            endIndex = endIndex < 0 ? 0:endIndex
        }
        
        delegate?.contentViewDidScroll?(self, startIndex: startIndex, endIndex: endIndex, progress: progress)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollViewW = scrollView.bounds.size.width
        let curOffsetX = scrollView.contentOffset.x
        let startIndex = Int(floor(startOffsetX/scrollViewW))
        let endIndex = Int(floor(curOffsetX/scrollViewW))
        
        delegate?.contentViewDidEndDecelerating?(self, startIndex: startIndex, endIndex: endIndex)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.contentViewDidEndDragging?(self)
    }
}
