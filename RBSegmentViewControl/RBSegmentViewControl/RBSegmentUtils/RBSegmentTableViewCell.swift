//
//  RBSegmentTableViewCell.swift
//  RBSegmentViewControl
//
//  Created by Rishon on 2022/5/3.
//

import UIKit

class RBSegmentTableViewCell: UITableViewCell {

    var ownerVc:RBHomeViewController?
    
    var cellCanScroll:Bool = false {
        didSet {
            viewControllers?.forEach({
                $0.vcCanScroll = cellCanScroll
            })
        }
    }
    
    var viewControllers:[RBSegmentViewController]?
    
    var pageContentView: RBSegmentPageContentView?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateData( dataSource: [Any]) {
        var vcs:[RBSegmentViewController] = []
        for i in 0...dataSource.count {
            let vc = RBSegmentViewController(CellHeight - 20, currentIndex: i)
            vcs.append(vc)
        }
        viewControllers = vcs
        
        pageContentView = RBSegmentPageContentView(CGRect(x: 0, y: 0, width: kScreenWidth, height: CellHeight), childVCs: vcs, parentVc: ownerVc!)
        contentView.addSubview(pageContentView!)
        
    }
    
}
