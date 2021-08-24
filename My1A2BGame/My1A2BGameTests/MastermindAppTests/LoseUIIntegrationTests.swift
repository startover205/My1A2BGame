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
    
    func test_emojiAnimation_showsOnFirstTimeAppearOnly() {
        let sut = makeSUT()

        sut.loadViewIfNeeded()

        var capturedTransform = sut.emojiViewTransform

        sut.viewDidAppear(true)

        XCTAssertNotEqual(sut.emojiViewTransform, capturedTransform, "Expect emoji view transform changed after view did appear")

        capturedTransform = sut.emojiViewTransform
        sut.viewDidAppear(true)

        XCTAssertEqual(sut.emojiViewTransform, capturedTransform, "Expect emoji view transform does not change when the view appeared the second time")
    }
    
    // MARK: Helpers
    
    private func makeSUT(rainAnimation: @escaping (_ on: UIView) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> LoseViewController {
        let sut = LoseUIComposer.loseScene()
        sut.rainAnimation = rainAnimation
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension LoseViewController {
    var emojiViewTransform: CGAffineTransform {
        emojiLabel.transform
    }
}
