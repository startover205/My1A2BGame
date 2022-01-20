//
//  CountdownAlertControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2022/1/7.
//  Copyright © 2022 Ming-Ta Yang. All rights reserved.
//

import XCTest
import MastermindiOS

class CountdownAlertControllerTests: XCTestCase {
    
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
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.ountdownProgressView.progress, 0, "precondition")

        sut.simulateViewAppear()
        XCTAssertEqual(sut.ountdownProgressView.progress, 1)
    }
    
    func test_countdownIndicator_setsCountdownTimeAsAnimationDuration() {
        let animator = AnimateSpy()
        let sut = makeSUT(countdownTime: 10, animate: animator.animate)
        
        sut.simulateViewAppear()
        
        XCTAssertEqual(animator.capturedAnimationDuration, 10)
    }

    func test_countdown_triggersCancelHandlerUponTimeUp() {
        var callbackCallCount = 0
        let sut = makeSUT(countdownTime: 0.1, onCancel: {
            callbackCallCount += 1
        })

        sut.loadViewIfNeeded()
        waitForCountdown(duration: 0.11)

        XCTAssertEqual(callbackCallCount, 0, "Expect handler not called because countdown starts after view shown")

        sut.simulateViewAppear()
        waitForCountdown(duration: 0.11)

        XCTAssertEqual(callbackCallCount, 1, "Expect handler called after countdown passes")
    }

    func test_doesNotGetRetainedAfterShown() {
        let sut = makeSUT()
        
        sut.simulateViewAppear()
    }
    
    // MARK: - Helpers
    
    private func makeSUT(title: String = "", message: String? = nil, cancelAction: String = "", countdownTime: Double = 5.0, onConfirm: (() -> Void)? = nil, onCancel: (() -> Void)? = nil, animate: @escaping Animate = { _, _, _ in }, file: StaticString = #filePath, line: UInt = #line) -> CountdownAlertController {
        let sut = CountdownAlertController(title: title, message: message, cancelAction: cancelAction, countdownTime: countdownTime, onConfirm: onConfirm, onCancel: onCancel, animate: animate)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func waitForCountdown(duration: TimeInterval) {
        let exp = expectation(description: "wait for countdown")
        exp.isInverted = true
        wait(for: [exp], timeout: duration)
    }
    
    private final class AnimateSpy {
        private(set) var capturedAnimationDuration: TimeInterval?
        
        func animate(_ duration: TimeInterval,
                     _ animations: @escaping () -> Void,
                     _ completion: ((Bool) -> Void)?) {
            capturedAnimationDuration = duration
        }
    }
}

private extension CountdownAlertController {
    func simulateUserSelectConfirm() {
        confirmButton.simulateTap()
    }
    
    func simulateUserSelectCancel() {
        cancelButton.simulateTap()
    }
}
