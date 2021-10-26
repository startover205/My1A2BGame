//
//  FAQViewController+TestHelpers.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/26.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation
import UIKit
import My1A2BGame

extension FAQViewController {
    func numberOfRenderedQuestionViews() -> Int {
        tableView.numberOfSections
    }
    
    func numberOfRenderedAnswerViews() -> Int {
        numberOfRenderedQuestionViews()
    }

    func heightForQuestion(at section: Int) -> CGFloat? {
        tableView.delegate?.tableView?(tableView, heightForRowAt: IndexPath(row: questionRow, section: section))
    }
    
    func heightForAnswer(at section: Int) -> CGFloat? {
        tableView.delegate?.tableView?(tableView, heightForRowAt: IndexPath(row: answerRow, section: section))
    }
    
    func questionView(at section: Int) -> UITableViewCell? {
        tableView.cellForRow(at: IndexPath(row: questionRow, section: section))
    }
    
    func simulateTappingQuestion(at section: Int) {
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: questionRow, section: section))
    }
    
    func foldingIndicatorView(at section: Int) -> UIView? {
        questionView(at: section)?.accessoryView
    }
    
    private var questionRow: Int { 0 }
    
    private var answerRow: Int { 1 }
}
