//
//  CommonQuestionsTableViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/22.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame

class CommonQuestionsTableViewControllerTests: XCTestCase {
    
    func test_loadView_allQuestionsUnfolded() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        for section in 0..<sut.numberOfQuestions() {
            XCTAssertNotEqual(sut.heightForQuestion(at: section), 0.0)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CommonQuestionsTableViewController {
        let sut = CommonQuestionsTableViewController()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension CommonQuestionsTableViewController {
    func numberOfQuestions() -> Int {
        tableView.numberOfSections
    }
    
    func heightForQuestion(at section: Int) -> CGFloat? {
        tableView.delegate?.tableView?(tableView, heightForRowAt: IndexPath(row: questionRow, section: section))
    }
    
    private var questionRow: Int { 0 }
}
