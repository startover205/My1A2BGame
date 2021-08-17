//
//  WinViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/5.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame
import Mastermind

class WinViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_rendersGuessCount_guess1() {
        let (sut, _, _) = makeSUT(guessCount: 1)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.guessCountMessage, "You guessed 1 time")
    }
    
    func test_viewDidLoad_rendersGuessCount_guess2() {
        let (sut, _, _) = makeSUT(guessCount: 2)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.guessCountMessage, "You guessed 2 times")
    }
    
    func test_viewDidLoad_rendersWinMessageAccordingToDigitCount() {
        let digitCount = 3
        let (sut, _, _) = makeSUT(digitCount: digitCount)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.winMessage, winMessageFor(digitCount: digitCount))
    }
    
    func test_viewDidLoad_reqeustLoaderValidatePlayerRecord() {
        let guessCount = 3
        let guessTime = 10.0
        let (sut, loader, _) = makeSUT(guessCount: guessCount, spentTime: guessTime)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.receivedMessages, [.validate(guessCount, guessTime)])
    }
    
    func test_viewDidLoad_rendersBreakRecordViewsIfBreakRecord() {
        let (sut, loader, _) = makeSUT()
        
        loader.completeValidation(with: true)
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.showingBreakRecordView)
    }
    
    func test_viewDidLoad_doesNotRendersNewRecordViewsIfRecordNotBroken() {
        let (sut, loader, _) = makeSUT()
        
        loader.completeValidation(with: false)
        sut.loadViewIfNeeded()
        
        XCTAssertFalse(sut.showingBreakRecordView)
    }
    
    func test_viewDidLoad_doesNotAskForReviewWhenUserHasNotWonThreeTimes() {
        var reviewCallCount = 0
        let (sut, _, _) = makeSUT() { _ in
            reviewCallCount += 1
        }
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(reviewCallCount, 0)
    }
    
    func test_viewDidLoad_doesNotAskForReviewWhenUserHasAlreadyBeenPrompt() {
        var reviewCallCount = 0
        let (sut, _, userDefaults) = makeSUT() { _ in
            reviewCallCount += 1
        }
        
        userDefaults.recordUserHasWonThreeTimes()
        userDefaults.recordUserHasAlreadyBeenPromptForReview(for: currentAppVersion())

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(reviewCallCount, 0)
    }
    
    func test_viewDidLoad_asksForReviewWhenUserHasWonThreeTimesAndNotBeenPromptForCurrentVersion() {
        var reviewCallCount = 0
        let (sut, _, userDefaults) = makeSUT(askForReview: { _ in
            reviewCallCount += 1
        })
        
        userDefaults.recordUserHasWonThreeTimes()
        userDefaults.recordUserHasAlreadyBeenPromptForReview(for: "any unmatched version")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(reviewCallCount, 1)
    }
    
    func test_viewDidAppear_showsEmojiAnimationOnFirstTime() {
        let (sut, _, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        var capturedTransform = sut.emojiViewTransform
        
        sut.viewDidAppear(true)
        
        XCTAssertNotEqual(sut.emojiViewTransform, capturedTransform, "Expect emoji view transform changed after view did appear")
        
        capturedTransform = sut.emojiViewTransform
        sut.viewDidAppear(true)
        
        XCTAssertEqual(sut.emojiViewTransform, capturedTransform, "Expect emoji view transform does not change when the view appeared the second time")
    }
    
    func test_viewDidAppear_showsFireworkAnimationOnFirstTime() {
        var fireworkCallCount = 0
        let (sut, _, _) = makeSUT(showFireworkAnimation: { _ in
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
        let (sut, _, _) = makeSUT()
        let hostVC = UIViewControllerSpy()
        let shareController = ShareViewController(hostViewController: hostVC, guessCount: { [unowned sut] in sut.guessCount })
        sut.shareViewController = shareController

        sut.loadViewIfNeeded()

        sut.simulateUserInitiatedShareAction()
        
        XCTAssertEqual(hostVC.presentCallCount, 1)
        
        sut.simulateUserInitiatedShareAction()
        
        XCTAssertEqual(hostVC.presentCallCount, 2)
    }
    
    private final class UIViewControllerSpy: UIViewController {
        var presentCallCount = 0
        
        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            presentCallCount += 1
        }
    }
    
    func test_breakRecord_confirmButtonEnabledOnlyWhenUserEnteredName() {
        let (sut, _, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertFalse(sut.confirmBtn.isEnabled, "expect confirm button to be not enabled after view did load")
        
        sut.simulateUserEnterPlayerName(name: "any name")
        
        XCTAssertTrue(sut.confirmBtn.isEnabled, "expect confirm button to be enabled after user entered name")
        
        sut.simulateUserEnterPlayerName(name: "")
        
        XCTAssertFalse(sut.confirmBtn.isEnabled, "expect confirm button to be not enabled after user clear name input")
    }
    
    func test_breakRecord_addPlayerRecordToStore() {
        let guessCount = 2
        let guessTime = 20.0
        let playerName = "a name"
        let (sut, loader, _) = makeSUT(guessCount: guessCount, spentTime: guessTime)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.receivedMessages, [.validate(guessCount, guessTime)], "Expect no save message added after view load")
        
        sut.confirmBtn.sendActions(for: .touchUpInside)
        XCTAssertEqual(loader.receivedMessages, [.validate(guessCount, guessTime)], "Expect no save message added after view load")

        sut.simulateUserEnterPlayerName(name: "a name")
        sut.confirmBtn.sendActions(for: .touchUpInside)
        XCTAssertEqual(loader.receivedMessages.count, 2)
        XCTAssertEqual(loader.receivedMessages.first, .validate(guessCount, guessTime))
        if case let .save(record) = loader.receivedMessages.last {
            XCTAssertEqual(record.playerName, playerName)
            XCTAssertEqual(record.guessCount, guessCount)
            XCTAssertEqual(record.guessTime, guessTime)
        } else {
            XCTFail("Expect save message when use press confirm button with player name entered, got \(loader.receivedMessages) instead")
        }
    }
    
    // MARK: Helpers
    
    private func makeSUT(digitCount: Int = 4, guessCount: Int = 1, spentTime: TimeInterval = 60.0, showFireworkAnimation: @escaping (UIView) -> Void = { _ in }, askForReview: @escaping (WinViewController.ReviewCompletion) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> (WinViewController, RecordLoaderSpy, UserDefaults) {
        let loader = RecordLoaderSpy()
        let userDefaults = UserDefaultsMock()
        let storyboard = UIStoryboard(name: "Game", bundle: .init(for: WinViewController.self))
        let sut = storyboard.instantiateViewController(withIdentifier: "WinViewController") as! WinViewController
        sut.digitCount = digitCount
        sut.guessCount = guessCount
        sut.spentTime = spentTime
        sut.recordLoader = loader
        sut.userDefaults = userDefaults
        sut.askForReview = askForReview
        sut.showFireworkAnimation = showFireworkAnimation
        
        trackForMemoryLeaks(userDefaults, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader, userDefaults)
    }
    
    private func currentAppVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
    
    private func winMessageFor(digitCount: Int) -> String { "\(digitCount)A0B!! You won!!" }
    
    private final class RecordLoaderSpy: RecordLoader {
        enum Message: Equatable {
            case load
            case validate(_ guessCount: Int, _ guessTime: TimeInterval)
            case save(_ record: PlayerRecord)
        }
        
        private var loadResult: Result<[PlayerRecord], Error>?
        private var validationResult: Bool?
        
        private(set) var receivedMessages = [Message]()
        
        func load() throws -> [PlayerRecord] {
            receivedMessages.append(.load)
            return try loadResult?.get() ?? []
        }
        
        func validate(score: Score) -> Bool {
            receivedMessages.append(.validate(score.guessCount, score.guessTime))
            return validationResult ?? false
        }

        func insertNewRecord(_ record: PlayerRecord) throws {
            receivedMessages.append(.save(record))
        }
        
        func completeValidation(with result: Bool) {
            validationResult = result
        }
        
        func completeRetrieval(with records: [PlayerRecord]) {
            loadResult = .success(records)
        }
    }
}

private extension WinViewController {
    var guessCountMessage: String? { guessCountLabel.text }
    
    var winMessage: String? { winLabel.text }
    
    var showingBreakRecordView: Bool { newRecordStackView.alpha != 0 }
    
    var emojiViewTransform: CGAffineTransform? { emojiLabel.transform }
    
    var sublayerCount: Int { view.layer.sublayers?.count ?? 0 }
    
    func simulateUserInitiatedShareAction() {
        guard let button = navigationItem.rightBarButtonItem else { return }
        
        _ = button.target?.perform(button.action, with: nil)
    }
    
    func simulateUserEnterPlayerName(name: String?) {
        let oldText = nameTextField.text ?? ""
        let newText = name ?? ""
        nameTextField.text = newText
        _ = nameTextField.delegate?.textField?(nameTextField, shouldChangeCharactersIn: NSRange(oldText) ?? NSRange(), replacementString: newText)
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
