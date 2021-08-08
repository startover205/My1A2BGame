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
        let store = PlayerStoreSpy()
        let guessCount = 1
        let (sut, _) = makeSUT(guessCount: guessCount,store: store)
        
        store.clearRecords()
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.showingBreakRecordView)
    }
    
    func test_viewDidLoad_doesNotRendersNewRecordViewsIfRecordNotBroken() {
        let store = PlayerStoreSpy()
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
        let (sut, userDefaults) = makeSUT(askForReview: { _ in
            reviewCallCount += 1
        })
        
        userDefaults.recordUserHasWonThreeTimes()
        userDefaults.recordUserHasAlreadyBeenPromptForReview(for: "any unmatched version")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(reviewCallCount, 1)
    }
    
    func test_viewDidAppear_showsEmojiAnimationOnFirstTime() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        var capturedTransform = sut.emojiViewTransform
        
        sut.viewDidAppear(true)
        
        XCTAssertNotEqual(sut.emojiViewTransform, capturedTransform)
        
        capturedTransform = sut.emojiViewTransform
        sut.viewDidAppear(true)
        
        XCTAssertEqual(sut.emojiViewTransform, capturedTransform)
    }
    
    func test_viewDidAppear_showsFireworkAnimationOnFirstTime() {
        var fireworkCallCount = 0
        let (sut, _) = makeSUT(showFireworkAnimation: { _ in
            fireworkCallCount += 1
        })

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(fireworkCallCount, 0, "expect no call until view appear")

        sut.viewDidAppear(true)

        XCTAssertEqual(fireworkCallCount, 1, "expect 1 call after view appear")

        sut.viewDidAppear(true)

        XCTAssertEqual(fireworkCallCount, 1, "expect no more calls after view already appear once")
    }
    
    func test_canShareContent() {
        var shareCallCount = 0
        let (sut, _) = makeSUT(shareResult: {
            shareCallCount += 1
        })

        sut.loadViewIfNeeded()

        sut.simulateUserInitiatedShareAction()
        
        XCTAssertEqual(shareCallCount, 1)
        
        sut.simulateUserInitiatedShareAction()
        
        XCTAssertEqual(shareCallCount, 2)

        executeRunLoopToCleanUpReferences()
    }
    
    func test_breakRecord_addPlayerRecordToStore() {
        let store = PlayerStoreSpy()
        let player = GameWinner(name: "a name", guessTimes: 3, spentTime: 4, winner: nil)
        let (sut, _) = makeSUT(store: store)
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(store.fetchAllObjects().isEmpty, "expect no record added after view load")
        
        sut.confirmBtn.sendActions(for: .touchUpInside)
        
        XCTAssertTrue(store.fetchAllObjects().isEmpty, "expect no record added when user did not enter player name")

        sut.simulateUserEnterPlayerName(name: player.name)
        sut.confirmBtn.sendActions(for: .touchUpInside)

        let recordedPlayer = store.fetchAllObjects().first
        XCTAssertEqual(recordedPlayer?.name, player.name, "expect record added when user entered player name")
    }
    
    // MARK: Helpers
    
    private func makeSUT(guessCount: Int = 1, spentTime: TimeInterval = 60.0, store: WinnerStore? = nil, showFireworkAnimation: @escaping (UIView) -> Void = { _ in }, askForReview: @escaping (WinViewController.ReviewCompletion) -> Void = { _ in }, shareResult: @escaping () -> Void = {  }, file: StaticString = #filePath, line: UInt = #line) -> (WinViewController, UserDefaults) {
        let userDefaults = UserDefaultsMock()
        let storyboard = UIStoryboard(name: "Game", bundle: .init(for: WinViewController.self))
        let sut = storyboard.instantiateViewController(withIdentifier: "WinViewController") as! WinViewController
        sut.guessCount = guessCount
        sut.spentTime = spentTime
        sut.isAdvancedVersion = false
        sut.winnerStore = store
        sut.userDefaults = userDefaults
        sut.askForReview = askForReview
        sut.showFireworkAnimation = showFireworkAnimation
        sut.shareResult = shareResult
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, userDefaults)
    }
    
    private func currentAppVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
}

private final class PlayerStoreSpy: WinnerStore {
    var players = [GameWinner]()
    var stashedPlayers = [GameWinner]()
    
    var totalCount: Int {
        players.count
    }
    
    func fetchAllObjects() -> [GameWinner] {
        players
    }
    
    func createObject() -> GameWinner {
        let player = GameWinner(name: nil, guessTimes: 1, spentTime: 1, winner: nil)
        stashedPlayers.append(player)
        return player
    }
    
    func delete(object: GameWinner) {
        players.removeAll { $0 === object }
    }
    
    func saveContext(completion: SaveDoneHandler?) {
        players.append(contentsOf: stashedPlayers)
        stashedPlayers.removeAll()
        completion?(true)
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
    
    var emojiViewTransform: CGAffineTransform? { emojiLabel.transform }
    
    var sublayerCount: Int { view.layer.sublayers?.count ?? 0 }
    
    func simulateUserInitiatedShareAction() {
        _ = shareBarBtnItem.target?.perform(shareBarBtnItem.action, with: nil)
    }
    
    func simulateUserEnterPlayerName(name: String?) {
        nameTextField.text = name
    }
}

private extension UserDefaults {
    func recordUserHasWonThreeTimes() {
        set(3, forKey: "processCompletedCount")
    }
    
    func recordUserHasAlreadyBeenPromptForReview(for appVersion: String) {
        set(appVersion, forKey: "lastVersionPromptedForReview")
    }
}
