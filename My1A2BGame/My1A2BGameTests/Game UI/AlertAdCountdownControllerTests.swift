//
//  AlertAdCountdownControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2022/1/7.
//  Copyright © 2022 Ming-Ta Yang. All rights reserved.
//

import XCTest
import MastermindiOS
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
    
    func test_confirmSelection_notifiesHandler() {
        var callbackCallCount = 0
        let sut = makeSUT(onConfirm: {
            callbackCallCount += 1
        })
        
        sut.loadViewIfNeeded()
        
        sut.simulateUserSelectConfirm()
        XCTAssertEqual(callbackCallCount, 1)
        
        sut.simulateUserSelectConfirm()
        XCTAssertEqual(callbackCallCount, 2)
    }
    
    func test_cancelSelection_notifiesHandler() {
        var callbackCallCount = 0
        let sut = makeSUT(onCancel: {
            callbackCallCount += 1
        })
        
        sut.loadViewIfNeeded()
        
        sut.simulateUserSelectCancel()
        XCTAssertEqual(callbackCallCount, 1)
        
        sut.simulateUserSelectCancel()
        XCTAssertEqual(callbackCallCount, 2)
    }
    
    func test_countdownIndicator_countsFrom0To1OnCountdown() {
        let animator = AnimateSpy()
        let sut = makeSUT(animate: animator.animate)
        
        sut.simulateViewAppear()
        XCTAssertEqual(sut.countDownProgressView.progress, 0, "precondition")
        
        animator.completeAnimations()
        XCTAssertEqual(sut.countDownProgressView.progress, 1)
    }
    
    func test_doesNotGetRetainedAfterShown() {
        let sut = makeSUT()
        
        sut.simulateViewAppear()
    }
    
    // MARK: - Helpers
    
    private func makeSUT(title: String = "", message: String? = nil, cancelAction: String = "", countDownTime: Double = 5.0, onConfirm: (() -> Void)? = nil, onCancel: (() -> Void)? = nil, animate: @escaping Animate = { _, _, _ in }, file: StaticString = #filePath, line: UInt = #line) -> AlertAdCountdownController {
        let sut = AlertAdCountdownController(title: title, message: message, cancelAction: cancelAction, countDownTime: countDownTime, onConfirm: onConfirm, onCancel: onCancel, animate: animate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private final class AnimateSpy {
        private var capturedAnimations: (() -> Void)?
        
        func animate(_ duration: TimeInterval,
                     _ animations: @escaping () -> Void,
                     _ completion: ((Bool) -> Void)?) {
            capturedAnimations = animations
        }
        
        func completeAnimations() {
            capturedAnimations?()
        }
    }
}

private extension AlertAdCountdownController {
    func simulateUserSelectConfirm() {
        confirmButton.sendActions(for: .touchUpInside)
    }
    
    func simulateUserSelectCancel() {
        cancelButton.sendActions(for: .touchUpInside)
    }
}
