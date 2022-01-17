//
//  AlertAdCountdownControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2022/1/7.
//  Copyright © 2022 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class AlertAdCountdownControllerTests: XCTestCase {
    
    func test_loadView_configureAlertAppearance() {
        let sut = makeSUT(
            title: "a title",
            message: "a message",
            cancelAction: "dismiss action"
        )
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.alertTitle(), "a title", "alert title")
        XCTAssertEqual(sut.alertMessage(), "a message", "alert message")
        XCTAssertEqual(sut.cancelAction(), "dismiss action", "dismiss action")
    }
    
    func test_doesNotGetRetainedAfterShown() {
        let sut = makeSUT()
        
        sut.simulateViewAppear()
    }
    
    // MARK: - Helpers
    
    private func makeSUT(title: String = "", message: String? = nil, cancelAction: String = "", countDownTime: Double = 5.0, onConfirm: (() -> Void)? = nil, onCancel: (() -> Void)? = nil, file: StaticString = #filePath, line: UInt = #line) -> AlertAdCountdownController {
        let sut = AlertAdCountdownController(title: title, message: message, cancelAction: cancelAction, countDownTime: countDownTime, onConfirm: onConfirm, onCancel: onCancel)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }

}
