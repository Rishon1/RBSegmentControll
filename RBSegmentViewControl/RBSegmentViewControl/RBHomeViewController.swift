//
//  RBHomeViewController.swift
//  RBSegmentViewControl
//
//  Created by Rishon on 2022/5/3.
//

import UIKit

public let kScreenWidth = UIScreen.main.bounds.width
public let kScreenHeight = UIScreen.main.bounds.height



class RBHomeViewController: UIViewController {

    fileprivate var canScroll: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "首页"
        view.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: UIDevice.rb_navigationFullHeight(), width: kScreenWidth, height: CellHeight)
        addRefreshHeaderView()
        NotificationCenter.default.addObserver(self, selector: #selector(changeScrollStatus(notification:)), name: NSNotification.Name(rbNotificationScrollTop), object: nil)
    }
    
    @objc func changeScrollStatus(notification: Notification) {
        canScroll = true
        tableView.isScrollEnabled = true
    }
    
    lazy var tableView: RBSegmentBaseTableView = {
        let  tableView = RBSegmentBaseTableView(frame: view.bounds, style: .grouped)
        tableView.backgroundColor = .clear
        
        tableView.register(RBSegmentTableViewCell.classForCoder(), forCellReuseIdentifier: "rbTabViewCell")
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "UITableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private lazy var pageTabBar: RBPageControlBar = {
        let pageTabBar = RBPageControlBar(frame: CGRect.zero)
        pageTabBar.dataSource = self
        pageTabBar.delegate = self
        return pageTabBar
    }()
    
    
    lazy var dataSource: [String] = {
        let data = ["1231", "232", "3435"]
        return data
    }()
}

// MARK: -  RBPageContainerDelegate, RBPageContainerDataSource
extension RBHomeViewController: RBPageControlBarDataSource, RBPageControlBarDelegate {
    
    func controlNumberOfItems(in pageTabBar: RBPageControlBar) -> Int {
        return dataSource.count
    }
    
    func defaultSelectedControlIndex(in pageTabBar: RBPageControlBar) -> Int {
        return 0
    }
    
    func currentPageIndicatorTintColorForItem(in pageTabBar: RBPageControlBar) -> UIColor {
        return .yellow
    }

    func transitionAnimationType(in pageTabBar: RBPageControlBar) -> RBPageControlBarItemTransitionAnimationType {
        return .smoothness
    }
}
extension RBHomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    fileprivate func addRefreshHeaderView() {
        let header = ESRefreshHeaderAnimator(frame: CGRect.zero)
        
        header.loadingDescription = "正在加載中"
        header.pullToRefreshDescription = "下拉加載更多"
        header.releaseToRefreshDescription = "鬆開刷新"
        tableView.es.addPullToRefresh(animator: header) { [weak self] in
            NSLog("来咯~~~~~~~")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self!.tableView.es.stopPullToRefresh()
            }
        }
        tableView.refreshIdentifier = "recordHome"
        tableView.expiredTimeInterval = 5.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return pageTabBar
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "rbTabViewCell") as! RBSegmentTableViewCell
        cell.ownerVc = self
        cell.updateData(dataSource: self.dataSource)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if !canScroll {
            tableView.contentOffset = CGPoint.zero
        }
        
        if scrollView.contentOffset.y >= 0{
            if canScroll {
                tableView.contentOffset = CGPoint.zero
                canScroll = false
                children.forEach {
                    let vc = ($0 as! RBSegmentViewController)
                    vc.vcCanScroll = true
                }
            }
        }
    }
    
}

extension RBHomeViewController: RBSegmentPageContentViewDelegate {
    
    /// 开始滑动
    /// - Parameter contentView: 菜单视图
    func contentViewWillBeginDragging(_ contentView: RBSegmentPageContentView) {
        
    }
    
    /// 滑动调用
    /// - Parameters:
    ///   - contentView: 菜单视图
    ///   - startIndex: 开始索引
    ///   - endIndex: 结束索引
    ///   - progress: 滑动进度
    func contentViewDidScroll(_ contentView: RBSegmentPageContentView, startIndex: Int, endIndex: Int, progress: CGFloat) {
        tableView.isScrollEnabled = false
    }
    
    /// 结束滑动
    /// - Parameters:
    ///   - contentView: 菜单视图
    ///   - startIndex: 开始索引
    ///   - endIndex: 结束索引
    func contentViewDidEndDecelerating(_ contentView: RBSegmentPageContentView, startIndex: Int, endIndex: Int) {
        pageTabBar.currentPage = endIndex
    }
    
    /// 结束滑动
    /// - Parameter contentView: 菜单视图
    func contentViewDidEndDragging(_ contentView: RBSegmentPageContentView) {
        tableView.isScrollEnabled = true
    }
}
