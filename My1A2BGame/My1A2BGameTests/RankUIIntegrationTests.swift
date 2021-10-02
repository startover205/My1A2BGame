//
//  RankUIIntegrationTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/2.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class RankUIIntegrationTests: XCTestCase {
    func test_loadRecordsActions_requestsRecordsFromLoader() {
        var loadRecordCallCount = 0
        var loadAdvancedRecordCallCount = 0
        let sut = makeSUT(requestRecords: {
            loadRecordCallCount += 1
            return []
        }, requestAdvancedRecords: {
            loadAdvancedRecordCallCount += 1
            return []
        })
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loadRecordCallCount, 0, "Expect no loading requests after view is loaded")
        
        sut.viewWillAppear(false)
        XCTAssertEqual(loadRecordCallCount, 1, "Expect a loading request on will view appear")
        
        sut.viewWillAppear(false)
        XCTAssertEqual(loadRecordCallCount, 2, "Expect another loading request on will view appear")
        
        sut.simulateChangeSegmentIndex(to: 0)
        XCTAssertEqual(loadRecordCallCount, 2, "Expect no loading requests on tapping the current segment")
        
        sut.simulateChangeSegmentIndex(to: 1)
        XCTAssertEqual(loadAdvancedRecordCallCount, 1, "Expect a loading request on tapping other segments")
        
        sut.viewWillAppear(false)
        XCTAssertEqual(loadAdvancedRecordCallCount, 2, "Expect another loading request on will view appear")
        
        sut.simulateChangeSegmentIndex(to: 0)
        XCTAssertEqual(loadRecordCallCount, 3, "Expect a loading request on tapping other segments")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(requestRecords: @escaping () -> [User] = { [] }, requestAdvancedRecords: @escaping () -> [User] = { []},   file: StaticString = #filePath, line: UInt = #line) -> RankViewController {
        let sut = RankUIComposer.rankComposedWith(requestRecords: requestRecords, requestAdvancedRecords: requestAdvancedRecords)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension RankViewController {
    func simulateChangeSegmentIndex(to index: Int) {
        let currentIndex = gameTypeSegmentedControl.selectedSegmentIndex
        gameTypeSegmentedControl.selectedSegmentIndex = index
        if index != currentIndex {
            gameTypeSegmentedControl.sendActions(for: .valueChanged)
        }
    }
}
