//
//  FAQTableViewController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/3/20.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import UIKit

class FAQTableViewController: UITableViewController {
    
    var sectionOpenStatus: [Int: Bool] = [:]
    var cachedScrollPosition : CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSectionOpenStatus()
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Force the tableView to stay at scroll position until animation completes
        if cachedScrollPosition != nil {
            tableView.setContentOffset(CGPoint(x: 0, y: cachedScrollPosition!), animated: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            sectionOpenStatus[indexPath.section] = !sectionOpenStatus[indexPath.section]!
            
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryView?.transform = sectionOpenStatus[indexPath.section]! ? .init(rotationAngle: CGFloat(-Float.pi / 2)) :.identity
            
            self.cachedScrollPosition = self.tableView.contentOffset.y
            
            if #available(iOS 11.0, *) {
                tableView.performBatchUpdates(nil, completion: nil)
            } else {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            
            self.cachedScrollPosition = nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let defaultHeight = super.tableView(tableView, heightForRowAt: indexPath)

        guard indexPath.row != 0 else {
           return defaultHeight
        }

        return sectionOpenStatus[indexPath.section]! ? defaultHeight : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.accessoryView = indexPath.row == 0 ? UIImageView(image: #imageLiteral(resourceName: "baseline_keyboard_arrow_left_black_18pt")) : nil
        cell.accessoryView?.transform = sectionOpenStatus[indexPath.section]! ? .init(rotationAngle: CGFloat(-Float.pi / 2)) :.identity

        return cell
    }
}

private extension FAQTableViewController {
    
    func initSectionOpenStatus(){
        for i in 0..<tableView.numberOfSections {
            sectionOpenStatus[i] = false
        }
    }
}