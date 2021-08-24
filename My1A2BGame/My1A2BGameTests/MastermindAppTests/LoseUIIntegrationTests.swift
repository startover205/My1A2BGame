//
//  LoseUIIntegrationTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/24.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class LoseUIIntegrationTests: XCTestCase {
    func test_rainAnimation_showsOnLoadView() {
        var rainAnimationCallCount = 0
        let sut = makeSUT { _ in
            rainAnimationCallCount += 1
        }
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(rainAnimationCallCount, 1)
    }
    
    // MARK: Helpers
    
    private func makeSUT(rainAnimation: @escaping (_ on: UIView) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> LoseViewController {
        let sut = LoseUIComposer.loseScene()
        sut.rainAnimation = rainAnimation
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
