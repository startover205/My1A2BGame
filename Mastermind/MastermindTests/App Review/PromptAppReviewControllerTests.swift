//
//  PromptAppReviewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/19.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import Mastermind

class PromptAppReviewControllerTests: XCTestCase {
    
    func test_init_doesNotRequestUserDefaults() {
        let (_, userDefaults) = makeSUT()
        
        XCTAssertEqual(userDefaults.receivedMessages, [])
    }
    
    func test_markProcessCompleteOnce_setProcessCountAddOne() {
        let (sut, userDefaults) = makeSUT()
        
        sut.markProcessCompleteOneTime()
        
        XCTAssertEqual(userDefaults.receivedMessages, [.setProcessCount(1)])
        
        sut.markProcessCompleteOneTime()
        
        XCTAssertEqual(userDefaults.receivedMessages, [.setProcessCount(1), .setProcessCount(2)])
    }
    
    func test_askForAppReviewIfAppropriate_setCurrntAppVersionAsLastPromptAppVersion() {
        let appVersion = "version1"
        let (sut, userDefaults) = makeSUT(appVersion: appVersion)
        
        sut.askForAppReviewIfAppropriate()
        
        XCTAssertEqual(userDefaults.receivedMessages, [.setLastPromptAppVersion(appVersion)])
    }
    
    func test_askForAppReviewIfAppropriate_doesNotRequestReviewIfProcessCompleteCountNotEqualOrGreaterThanTargetCount() {
        var reviewCallCount = 0
        let (sut, userDefaults) = makeSUT(askForReview: {
            reviewCallCount += 1
        }, targetProcessCompletedCount: 1)

        userDefaults.completeProcessCompleteCountRetrieval(with: 0)
        sut.askForAppReviewIfAppropriate()
        XCTAssertEqual(reviewCallCount, 0)
    }
    
    func test_askForAppReviewIfAppropriate_doesNotRequestReviewIfCurrentVersionAlreadyAskedForReview() {
        var reviewCallCount = 0
        let (sut, userDefaults) = makeSUT(askForReview: {
            reviewCallCount += 1
        }, appVersion: "version1")
        
        userDefaults.completeAppVersionRetrieval(with: "version1")
        sut.askForAppReviewIfAppropriate()
        XCTAssertEqual(reviewCallCount, 0)
    }
    
    func test_askForAppReviewIfAppropriate_requestReviewIfProcessCompleteCountEqualOrGreaterThanTargetCountAndCurrentVersionNotYetAskedForReview() {
        var reviewCallCount = 0
        let (sut, userDefaults) = makeSUT(askForReview: {
            reviewCallCount += 1
        }, targetProcessCompletedCount: 10, appVersion: "version2")
        
        userDefaults.completeProcessCompleteCountRetrieval(with: 10)
        userDefaults.completeAppVersionRetrieval(with: "version1")
        sut.askForAppReviewIfAppropriate()
        XCTAssertEqual(reviewCallCount, 1)
    }
    
    // MARK: Helpers
    
    private func makeSUT(askForReview: @escaping () -> () = { }, targetProcessCompletedCount: Int = 0, appVersion: String = "", file: StaticString = #filePath, line: UInt = #line) -> (AppReviewController, UserDefaultsSpy) {
        let userDefaults = UserDefaultsSpy()
        let sut = AppReviewController(userDefaults: userDefaults, askForReview: askForReview, targetProcessCompletedCount: targetProcessCompletedCount, appVersion: appVersion)
        
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


