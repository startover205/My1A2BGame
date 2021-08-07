//
//  WinViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/5.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class WinViewControllerBasicGameTests: XCTestCase {
    
    func test_viewDidLoad_rendersGuessCount_guess1() {
        let (sut, _) = makeSUT(guessCount: 1)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.guessCountMessage, "You guessed 1 time")
    }
    
    func test_viewDidLoad_rendersGuessCount_guess2() {
        let (sut, _) = makeSUT(guessCount: 2)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.guessCountMessage, "You guessed 2 times")
    }
    
    func test_viewDidLoad_rendersWinMessage() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.winMessage, "4A0B!! You won!!")
    }
    
    func test_viewDidLoad_rendersBreakRecordViewsIfBreakRecord() {
        let store = PlayerStore()
        let guessCount = 1
        let (sut, _) = makeSUT(guessCount: guessCount,store: store)
        
        store.clearRecords()
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.showingBreakRecordView)
    }
    
    func test_viewDidLoad_doesNotRendersNewRecordViewsIfRecordNotBroken() {
        let store = PlayerStore()
        let guessCount = 20
        let (sut, _) = makeSUT(guessCount: guessCount, store: store)
        let existingTopRecords = Array(repeating: GameWinner(name: nil, guessTimes: 1, spentTime: 0, winner: Winner()), count: 10)
        
        store.addRecords(existingTopRecords)
        sut.loadViewIfNeeded()
        
        XCTAssertFalse(sut.showingBreakRecordView)
    }
    
    func test_viewDidLoad_doesNotAskForReviewWhenUserHasNotWonThreeTimes() {
        var reviewCallCount = 0
        let (sut, _) = makeSUT() { _ in
            reviewCallCount += 1
        }
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(reviewCallCount, 0)
    }
    
    func test_viewDidLoad_doesNotAskForReviewWhenUserHasAlreadyBeenPrompt() {
        var reviewCallCount = 0
        let (sut, userDefaults) = makeSUT() { _ in
            reviewCallCount += 1
        }
        
        userDefaults.recordUserHasWonThreeTimes()
        userDefaults.recordUserHasAlreadyBeenPromptForReview(for: currentAppVersion())

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(reviewCallCount, 0)
    }
    
    func test_viewDidLoad_asksForReviewWhenUserHasWonThreeTimesAndNotBeenPromptForCurrentVersion() {
        var reviewCallCount = 0
        let (sut, userDefaults) = makeSUT() { _ in
            reviewCallCount += 1
        }
        
        userDefaults.recordUserHasWonThreeTimes()
        userDefaults.recordUserHasAlreadyBeenPromptForReview(for: "any unmatched version")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(reviewCallCount, 1)
    }
    
    // MARK: Helpers
    
    private func makeSUT(guessCount: Int = 1, spentTime: TimeInterval = 60.0, store: WinnerStore? = nil, askForReview: @escaping (WinViewController.ReviewCompletion) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> (WinViewController, UserDefaults) {
        let userDefaults = UserDefaultsMock()
        let storyboard = UIStoryboard(name: "Game", bundle: .init(for: WinViewController.self))
        let sut = storyboard.instantiateViewController(withIdentifier: "WinViewController") as! WinViewController
        sut.guessCount = guessCount
        sut.spentTime = spentTime
        sut.isAdvancedVersion = false
        sut.winnerStore = store
        sut.userDefaults = userDefaults
        sut.askForReview = askForReview
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, userDefaults)
    }
    
    private func currentAppVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    private final class UserDefaultsMock: UserDefaults {
        private var values = [String: Any]()

        override func object(forKey defaultName: String) -> Any? {
            values[defaultName]
        }
        
        override func set(_ value: Any?, forKey defaultName: String) {
            values[defaultName] = value
        }
    }
}

private final class PlayerStore: WinnerStore {
    var players = [GameWinner]()
    
    var totalCount: Int {
        players.count
    }
    
    func fetchAllObjects() -> [GameWinner] {
        players
    }
    
    func createObject() -> GameWinner {
        GameWinner(name: nil, guessTimes: 1, spentTime: 1, winner: Winner())
    }
    
    func delete(object: GameWinner) {
        players.removeAll { $0 === object }
    }
    
    func saveContext(completion: SaveDoneHandler?) {
    }
    
    func clearRecords() {
        players.removeAll()
    }
    
    func addRecords(_ records: [GameWinner]) {
        players.append(contentsOf: records)
    }
}

private extension WinViewController {
    var guessCountMessage: String? { guessCountLabel.text }
    
    var winMessage: String? { winLabel.text }
    
    var showingBreakRecordView: Bool { newRecordStackView.alpha != 0 }
}

private extension UserDefaults {
    func recordUserHasWonThreeTimes() {
        set(3, forKey: "processCompletedCount")
    }
    
    func recordUserHasAlreadyBeenPromptForReview(for appVersion: String) {
        set(appVersion, forKey: "lastVersionPromptedForReview")
    }
}
