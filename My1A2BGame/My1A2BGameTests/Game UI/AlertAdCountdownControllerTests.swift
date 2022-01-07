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
    
    func test_doesNotGetRetainedAfterPresented() {
        let hostVC = UIViewController()
        let window = UIWindow()
        window.addSubview(hostVC.view)
        let sut = makeSUT()
        
        hostVC.present(sut, animated: false)
        
        clearModalPresentationReference(hostVC)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(title: String = "", message: String? = nil, cancelMessage: String = "", countDownTime: Double = 5.0, confirmHandler: (() -> Void)? = nil, cancelHandler: (() -> Void)? = nil, file: StaticString = #filePath, line: UInt = #line) -> AlertAdCountdownController {
        let sut = AlertAdCountdownController(title: title, message: message, cancelMessage: cancelMessage, countDownTime: countDownTime, confirmHandler: confirmHandler, cancelHandler: cancelHandler)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }

}
