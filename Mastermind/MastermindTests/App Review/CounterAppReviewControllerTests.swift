//
//  CounterAppReviewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/19.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import Mastermind

class CounterAppReviewControllerTests: XCTestCase {
    
    func test_init_doesNotRequestUserDefaults() {
        let (_, userDefaults) = makeSUT()
        
        XCTAssertEqual(userDefaults.receivedMessages, [])
    }
    
    func test_askForAppReviewIfAppropriate_setProcessCountAddOne() {
        let (sut, userDefaults) = makeSUT()
        
        sut.askForReviewIfAppropriate()
        
        XCTAssertEqual(userDefaults.receivedMessages, [.setProcessCount(1)])
        
        sut.askForReviewIfAppropriate()
        
        XCTAssertEqual(userDefaults.receivedMessages, [.setProcessCount(1), .setProcessCount(2)])
    }
    
    func test_askForAppReviewIfAppropriate_doesNotRequestReviewIfProcessCompleteCountNotEqualOrGreaterThanTargetCount() {
        var reviewCallCount = 0
        let (sut, userDefaults) = makeSUT(askForReview: {
            reviewCallCount += 1
        }, targetProcessCompletedCount: 2)

        userDefaults.completeProcessCompleteCountRetrieval(with: 0)
        sut.askForReviewIfAppropriate()
        XCTAssertEqual(reviewCallCount, 0)
    }
    
    func test_askForAppReviewIfAppropriate_doesNotRequestReviewIfCurrentVersionAlreadyAskedForReview() {
        var reviewCallCount = 0
        let (sut, userDefaults) = makeSUT(askForReview: {
            reviewCallCount += 1
        }, appVersion: "version1")
        
        userDefaults.completeAppVersionRetrieval(with: "version1")
        sut.askForReviewIfAppropriate()
        XCTAssertEqual(reviewCallCount, 0)
    }
    
    func test_askForAppReviewIfAppropriate_requestReviewAndSetCurrentAppVersion_ifProcessCompleteCountEqualTargetCountAndCurrentVersionNotYetAskedForReview() {
        let currentVersion = "version2"
        var reviewCallCount = 0
        let (sut, userDefaults) = makeSUT(askForReview: {
            reviewCallCount += 1
        }, targetProcessCompletedCount: 10, appVersion: currentVersion)
        
        userDefaults.completeProcessCompleteCountRetrieval(with: 9)
        userDefaults.completeAppVersionRetrieval(with: "version1")
        sut.askForReviewIfAppropriate()
        XCTAssertEqual(reviewCallCount, 1, "Expect request review when call count is equal or greater than the target call count")
        XCTAssertTrue(userDefaults.receivedMessages.contains(.setLastPromptAppVersion(currentVersion)), "Expect saving current version on request review")
    }
    
    func test_askForAppReviewIfAppropriate_requestReviewAndSetCurrentAppVersion_ifProcessCompleteCountGreaterThanTargetCountAndCurrentVersionNotYetAskedForReview() {
        let currentVersion = "version2"
        var reviewCallCount = 0
        let (sut, userDefaults) = makeSUT(askForReview: {
            reviewCallCount += 1
        }, targetProcessCompletedCount: 10, appVersion: currentVersion)
        
        userDefaults.completeProcessCompleteCountRetrieval(with: 10)
        userDefaults.completeAppVersionRetrieval(with: "version1")
        sut.askForReviewIfAppropriate()
        XCTAssertEqual(reviewCallCount, 1, "Expect request review when call count is equal or greater than the target call count")
        XCTAssertTrue(userDefaults.receivedMessages.contains(.setLastPromptAppVersion(currentVersion)), "Expect saving current version on request review")
    }
    
    // MARK: Helpers
    
    private func makeSUT(askForReview: @escaping () -> () = { }, targetProcessCompletedCount: Int = 10, appVersion: String = "", file: StaticString = #filePath, line: UInt = #line) -> (CounterAppReviewController, UserDefaultsSpy) {
        let userDefaults = UserDefaultsSpy()
        let sut = CounterAppReviewController(userDefaults: userDefaults, askForReview: askForReview, targetProcessCompletedCount: targetProcessCompletedCount, appVersion: appVersion)
        
        trackForMemoryLeaks(userDefaults, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, userDefaults)
    }
    
    private final class UserDefaultsSpy: UserDefaults {
        enum Message: Equatable {
            case setProcessCount(_ processCount: Int)
            case setLastPromptAppVersion(_ appVersion: String)
        }
        
        private(set) var receivedMessages = [Message]()
        
        private var values = [String: Any]()

        override func object(forKey defaultName: String) -> Any? {
            values[defaultName]
        }
        
        override func set(_ value: Any?, forKey defaultName: String) {
            if let int = value as? Int {
                receivedMessages.append(.setProcessCount(int))
            }

            if let string = value as? String {
                receivedMessages.append(.setLastPromptAppVersion(string))
            }

            values[defaultName] = value
        }
        
        func completeProcessCompleteCountRetrieval(with count: Int) {
            values["processCompleteCount"] = count
        }
        
        func completeAppVersionRetrieval(with version: String) {
            values["lastPromptAppVersion"] = version
        }
    }
}


