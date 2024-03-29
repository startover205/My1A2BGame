//
//  FAQViewController.swift
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

public final class FAQViewController: UITableViewController {
    
    private var sectionOpenStatus: [Int: Bool] = [:]
    private var cachedScrollPosition : CGFloat?
    public var tableModel = [Question]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initSectionOpenStatus()
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
            
            tableView.performBatchUpdates(nil, completion: nil)
            
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
        
        let isQuestion = indexPath.row == 0
        let reuseIdentifier = isQuestion ? "QuestionCell" : "AnswerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        let question = tableModel[indexPath.section]
        
        cell.textLabel?.text = isQuestion ? question.content : question.answer
        cell.accessoryView = isQuestion ? UIImageView(image: #imageLiteral(resourceName: "baseline_keyboard_arrow_left_black_18pt")) : nil
        cell.accessoryView?.transform = sectionOpenStatus[indexPath.section]! ? .init(rotationAngle: CGFloat(-Float.pi / 2)) : .identity

        return cell
    }
}

private extension FAQViewController {
    
    func initSectionOpenStatus() {
        for i in 0..<tableModel.count {
            sectionOpenStatus[i] = false
        }
    }
}
