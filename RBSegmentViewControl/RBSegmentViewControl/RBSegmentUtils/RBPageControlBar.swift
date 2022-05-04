//
//  RBPageControlBar.swift
//  HXPageViewController
//
//  Created by rb on 2022/4/29.
//  Copyright © 2022 WHX. All rights reserved.
//

import UIKit

@objc public enum RBPageControlBarItemTransitionAnimationType: Int {
    /// 无动画
    case none
    /// 平滑的
    case smoothness
}

// MARK: -  行为代理
@objc public protocol RBPageControlBarDelegate: AnyObject {
    
    /// 选中index的回调
    ///
    /// - Parameters:
    ///   - pageTabBar: RBPageControlBar
    ///   - index: 当前index
    @objc optional func pageControlBar(_ pageTabBar: RBPageControlBar, didSelectedItemAt index: Int)

    /// 正在滚动的回调
    ///
    /// - Parameters:
    ///   - pageTabBar: RBPageControlBar
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - percent: 进度
    @objc optional func pageControlBar(_ pageTabBar: RBPageControlBar, didScrollItem fromIndex: Int, toIndex: Int, percent: CGFloat)
    
}

// MARK: -  数据源代理
@objc public protocol RBPageControlBarDataSource: AnyObject {

    /// 选项数目
    ///
    /// - Parameter pageTabBar: pageContainer
    /// - Returns: 选项数目
    func controlNumberOfItems(in pageTabBar: RBPageControlBar) -> Int
    
    /// 默认选中位置，默认为0
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 默认选中位置
    @objc optional func defaultSelectedControlIndex(in pageTabBar: RBPageControlBar) -> Int
    
    /// 高亮颜色，默认为黑色
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 高亮颜色
    @objc optional func currentPageIndicatorTintColorForItem(in pageTabBar: RBPageControlBar) -> UIColor
    
    /// 切换动画，默认为none
    ///
    /// - Parameter pageTabBar: pageTabBar
    /// - Returns: 切换动画
    @objc optional func transitionAnimationType(in pageTabBar: RBPageControlBar) -> RBPageControlBarItemTransitionAnimationType
    
}

open class RBPageControlBar: UIPageControl {
    // MARK: -  Properties
    
    /// 关联的内容scrollView
    open weak var contentScrollView: UIScrollView? {
        didSet {
            if contentScrollView != oldValue {
                setupContentScrollObserver()
            }
        }
    }
    
    /// 回调代理
    open weak var delegate: RBPageControlBarDelegate?
    
    /// 数据源代理
    open weak var dataSource: RBPageControlBarDataSource? {
        didSet {
            self.currentPage = currentSelectIndex()
            numberOfPages = numberOfItems()
            currentPageIndicatorTintColor = colorForIndicatorView()
        }
    }
    
    /// 内容视图滚动监听者
    private var scrollObserver: NSKeyValueObservation?
    
    /// 最近的contentOffset
    private var lastContentOffset: CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .black
        numberOfPages = 2
        currentPage = 0
        currentPageIndicatorTintColor = .red
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            scrollObserver = nil
        } else {
            setupContentScrollObserver()
        }
    }
}


// MARK: -  UI
extension RBPageControlBar {
    
    /// 指示器的颜色
    ///
    /// - Returns: 指示器的颜色
    private func colorForIndicatorView() -> UIColor {
        return dataSource?.currentPageIndicatorTintColorForItem?(in: self) ?? .white
    }
    
    /// 获取item数目
    ///
    /// - Returns: item数目
    private func numberOfItems() -> Int {
        return dataSource?.controlNumberOfItems(in: self) ?? 0
    }
    
    /// 当前选中index
    ///
    /// - Returns: item数目
    private func currentSelectIndex() -> Int {
        return dataSource?.defaultSelectedControlIndex?(in: self) ?? 0
    }
    
    /// 切换动画
    ///
    /// - Returns: 切换动画
    private func transitionAnimationType() -> RBPageControlBarItemTransitionAnimationType {
        return dataSource?.transitionAnimationType?(in: self) ?? .none
    }
    
}

// MARK: -  Private Methods
extension RBPageControlBar {
    
    /// 设置内容视图监听者
    private func setupContentScrollObserver() {
        guard let contentScrollView = contentScrollView else { return }
        scrollObserver = contentScrollView.observe(\.contentOffset, options: [.new, .old]) { [weak self] (scrollView, changed) in
            guard let `self` = self,
                let newContentOffset = changed.newValue,
                let oldContentOffset = changed.oldValue else { return }
            let isDragging = scrollView.isTracking || scrollView.isDecelerating
            if newContentOffset != oldContentOffset && isDragging {
                // 设置了新的contentOffset，才做处理
                self.contentSrollViewDidChanged(contentOffset: newContentOffset)
            }
            self.lastContentOffset = newContentOffset
        }
    }
    
    /// 内容视图滚动监听
    ///
    /// - Parameter contentOffset: 偏移
    private func contentSrollViewDidChanged(contentOffset: CGPoint) {
        guard let contentScrollView = contentScrollView else { return }
        let itemCount = numberOfItems()
        let ratio = contentOffset.x / contentScrollView.bounds.width
        if ratio > CGFloat(itemCount - 1) || ratio < 0 {
            /// 如果越界，不做处理
            return
        }
        if (contentOffset.x == 0 && currentPage == 0 && lastContentOffset.x == 0) {
            // 滚动到了最左边，且已经选中了第一个，且之前的contentOffset.x为0，不做处理
            return
        }
        let maxContentOffsetX = contentScrollView.contentSize.width - contentScrollView.bounds.width
        if (contentOffset.x == maxContentOffsetX && currentPage == itemCount - 1 && lastContentOffset.x == maxContentOffsetX) {
            //滚动到了最右边，且已经选中了最后一个，且之前的contentOffset.x为maxContentOffsetX，不做处理
            return
        }
        let currentIndex = Int(ratio)
        let remainderRatio = ratio - CGFloat(currentIndex)
        /// 是否忽略此次滚动处理
        let isIgnoreScroll = lastContentOffset.x == contentOffset.x && currentPage == currentIndex
        if remainderRatio == 0 {
            // 滑动翻页，更新选中状态， 忽略重复的情况
            if !isIgnoreScroll {
                selectedItem(at: currentIndex, shouldHandleContentScrollView: false)
            }
        } else {
            /// 滑动太快，remainderRatio没有变成0，但是已经翻页了
            if (abs(ratio - CGFloat(currentPage)) > 1) {
                var targetIndex = currentIndex
                if (ratio < CGFloat(currentPage)) {
                    targetIndex += 1
                }
                selectedItem(at: targetIndex, shouldHandleContentScrollView: false)
            }
        }
        if !isIgnoreScroll {
            let fromIndex = currentPage
            var toIndex: Int = 0
            var percent: CGFloat = 0
            if currentPage == currentIndex {
                toIndex = currentIndex + 1
                percent = remainderRatio
            } else {
                toIndex = currentIndex
                percent = 1 - remainderRatio
            }
            
            delegate?.pageControlBar?(self, didScrollItem: fromIndex, toIndex: toIndex, percent: percent)
        }
    }
    
    /// 设置选中状态
    ///
    /// - Parameters:
    ///   - index: 位置
    ///   - flag: 是否同步滚动内容视图
    private func selectedItem(at index: Int, shouldHandleContentScrollView flag: Bool) {
        let itemCount = numberOfItems()
        if index > itemCount - 1 || index < 0 {
            /// 如果越界，不做处理
            return
        }
        if currentPage == index {
            /// 如果index没有变化，不做处理
            return
        }
        /// 更新选中状态
        currentPage = index
        /// 回调
        delegate?.pageControlBar?(self, didSelectedItemAt: currentPage)
    }
}
