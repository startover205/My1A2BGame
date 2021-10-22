//
//  FAQTableViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/22.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import UIKit
@testable import My1A2BGame

class FAQTableViewControllerTests: XCTestCase {
    
    func test_loadView_allQuestionsUnfolded() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        for section in 0..<sut.numberOfQuestions() {
            XCTAssertNotEqual(sut.heightForQuestion(at: section), 0.0)
        }
    }
    
    func test_loadView_allAnswersFolded() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        for section in 0..<sut.numberOfAnswers() {
            XCTAssertEqual(sut.heightForAnswer(at: section), 0.0)
        }
    }
    
    func test_loadView_rendersQuestionWithFoldingIndicator() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        for section in 0..<sut.numberOfQuestions() {
            let imageView = try? XCTUnwrap(sut.question(at: section)?.accessoryView as? UIImageView)
            XCTAssertEqual(imageView?.image?.pngData(), UIImage(named: "baseline_keyboard_arrow_left_black_18pt")?.pngData())
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FAQTableViewController {
        let sut = UIStoryboard(name: "More", bundle: .main).instantiateViewController(withIdentifier: "FAQTableViewController") as! FAQTableViewController
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension FAQTableViewController {
    func numberOfQuestions() -> Int {
        tableView.numberOfSections
    }
    
    func numberOfAnswers() -> Int {
        numberOfQuestions()
    }
    
    func heightForQuestion(at section: Int) -> CGFloat? {
        tableView.delegate?.tableView?(tableView, heightForRowAt: IndexPath(row: questionRow, section: section))
    }
    
    func heightForAnswer(at section: Int) -> CGFloat? {
        tableView.delegate?.tableView?(tableView, heightForRowAt: IndexPath(row: answerRow, section: section))
    }
    
    func question(at section: Int) -> UITableViewCell? {
        tableView.cellForRow(at: IndexPath(row: questionRow, section: section))
    }
    
    private var questionRow: Int { 0 }
    
    private var answerRow: Int { 1 }
}
