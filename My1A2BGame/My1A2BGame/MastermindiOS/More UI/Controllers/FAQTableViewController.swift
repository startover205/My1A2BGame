//
//  FAQTableViewController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/3/20.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import UIKit

public struct Question {
    public let content: String
    public let answer: String
    
    public init(content: String, answer: String) {
        self.content = content
        self.answer = answer
    }
}

public final class FAQTableViewController: UITableViewController {
    
    private var sectionOpenStatus: [Int: Bool] = [:]
    private var cachedScrollPosition : CGFloat?
    private var tableModel = [Question(
                                content: "How come sometimes there's no reward ad when we are out of guess chances?",
                                answer: "The reward ad will only show if an ad is loaded completely.")]
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        initSectionOpenStatus()
        
        tableView.reloadData()
    }

    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Force the tableView to stay at scroll position until animation completes
        if cachedScrollPosition != nil {
            tableView.setContentOffset(CGPoint(x: 0, y: cachedScrollPosition!), animated: false)
        }
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int { tableModel.count }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            sectionOpenStatus[indexPath.section] = !sectionOpenStatus[indexPath.section]!
            
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryView?.transform = sectionOpenStatus[indexPath.section]! ? .init(rotationAngle: CGFloat(-Float.pi / 2)) :.identity
            
            cachedScrollPosition = tableView.contentOffset.y
            
            if #available(iOS 11.0, *) {
                tableView.performBatchUpdates(nil, completion: nil)
            } else {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            
            cachedScrollPosition = nil
        }
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let defaultHeight = super.tableView(tableView, heightForRowAt: indexPath)

        guard indexPath.row != 0 else {
           return defaultHeight
        }

        return sectionOpenStatus[indexPath.section]! ? defaultHeight : 0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        let question = tableModel[indexPath.section]
        
        cell.textLabel?.text = indexPath.row == 0 ? question.content : question.answer
        cell.accessoryView = indexPath.row == 0 ? UIImageView(image: #imageLiteral(resourceName: "baseline_keyboard_arrow_left_black_18pt")) : nil
        cell.accessoryView?.transform = sectionOpenStatus[indexPath.section]! ? .init(rotationAngle: CGFloat(-Float.pi / 2)) : .identity

        return cell
    }
}

private extension FAQTableViewController {
    
    func initSectionOpenStatus(){
        for i in 0..<tableModel.count {
            sectionOpenStatus[i] = false
        }
    }
}
