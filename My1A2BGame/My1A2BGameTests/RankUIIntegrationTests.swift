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
    func test_viewWillAppear_requestRefresh() {
        var refreshCallCount = 0
        let sut = makeSUT(requestRecords: {
            refreshCallCount += 1
            return []
        })
        
        sut.loadViewIfNeeded()
        sut.viewWillAppear(false)
        
        XCTAssertEqual(refreshCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(requestRecords: @escaping () -> [User] = { [] }, requestAdvancedRecords: @escaping () -> [User] = { []},   file: StaticString = #filePath, line: UInt = #line) -> RankViewController {
        let sut = RankUIComposer.rankComposedWith(requestRecords: requestRecords, requestAdvancedRecords: requestAdvancedRecords)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
