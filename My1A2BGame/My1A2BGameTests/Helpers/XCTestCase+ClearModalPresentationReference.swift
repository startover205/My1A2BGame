//
//  XCTestCase+ClearModalPresentationReference.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/15.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest

extension XCTestCase {
    func clearModalPresentationReference(_ sut: UIViewController) {
        let exp = expectation(description: "wait for dismiss")
        sut.dismiss(animated: true) {
            exp.fulfill()
        }
        waitForExpectations(timeout: 3)
    }
    
    func executeRunLoopToCleanUpReferences(prolongTime: TimeInterval = 0.0) {
        RunLoop.current.run(until: Date() + prolongTime)
    }
}
