//
//  WinViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/5.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame
import Mastermind

class WinViewControllerTests: XCTestCase {
    
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
    
    func test_viewDidLoad_rendersWinMessageAccordingToDigitCount() {
        let digitCount = 3
        let (sut, _) = makeSUT(digitCount: digitCount)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.winMessage, winMessageFor(digitCount: digitCount))
    }
    
    func test_viewDidLoad_reqeustLoaderValidatePlayerRecord() {
        let guessCount = 3
        let guessTime = 10.0
        let (sut, loader) = makeSUT(guessCount: guessCount, spentTime: guessTime)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.receivedMessages, [.validate(guessCount, guessTime)])
    }
    
    func test_viewDidLoad_rendersBreakRecordViewsIfBreakRecord() {
        let (sut, loader) = makeSUT()
        
        loader.completeValidation(with: true)
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.showingBreakRecordView)
    }
    
    func test_viewDidLoad_doesNotRendersNewRecordViewsIfRecordNotBroken() {
        let (sut, loader) = makeSUT()
        
        loader.completeValidation(with: false)
        sut.loadViewIfNeeded()
        
        XCTAssertFalse(sut.showingBreakRecordView)
    }
    
    func test_viewDidAppear_showsEmojiAnimationOnFirstTime() {
        let (sut, _) = makeSUT()
        
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
        let (sut, _) = makeSUT()
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
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertFalse(sut.confirmButtonEanbled, "expect confirm button to be not enabled after view did load")
        
        sut.simulateUserEnterPlayerName(name: "any name")
        
        XCTAssertTrue(sut.confirmButtonEanbled, "expect confirm button to be enabled after user entered name")
        
        sut.simulateUserEnterPlayerName(name: "")
        
        XCTAssertFalse(sut.confirmButtonEanbled, "expect confirm button to be not enabled after user clear name input")
    }
    
    func test_breakRecord_addPlayerRecordToStore() {
        let playerName = "a name"
        let guessCount = 2
        let guessTime = 20.0
        let timestamp = Date()
        let (sut, loader) = makeSUT(guessCount: guessCount, spentTime: guessTime, currentDate: { timestamp })
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.receivedMessages, [.validate(guessCount, guessTime)], "Expect no save message added after view load")
        
        sut.simulateUserSendInput()
        XCTAssertEqual(loader.receivedMessages, [.validate(guessCount, guessTime)], "Expect no save message added after view load")

        sut.simulateUserEnterPlayerName(name: playerName)
        sut.simulateUserSendInput()
        XCTAssertEqual(loader.receivedMessages, [.validate(guessCount, guessTime), .save(PlayerRecord(playerName: playerName, guessCount: guessCount, guessTime: guessTime, timestamp: timestamp))], "Expect save message when use press confirm button with player name entered")
    }
    
    func test_tapScreen_dismissKeyboard() {
        let (sut, _) = makeSUT(trackMemoryLeak: false)
        let window = UIWindow()
        window.addSubview(sut.view)
        
        sut.loadViewIfNeeded()
        sut.simulateKeyboardShowing()
        
        XCTAssertTrue(sut.inputView().isFirstResponder)

        sut.simulateOnTapScreen()
        
        XCTAssertFalse(sut.inputView().isFirstResponder)
    }
    
    // MARK: Helpers
    
    private func makeSUT(digitCount: Int = 4, guessCount: Int = 1, spentTime: TimeInterval = 60.0, currentDate: @escaping () -> Date = Date.init, showFireworkAnimation: @escaping (UIView) -> Void = { _ in }, trackMemoryLeak: Bool = true, file: StaticString = #filePath, line: UInt = #line) -> (WinViewController, RecordLoaderSpy) {
        let loader = RecordLoaderSpy()
        let storyboard = UIStoryboard(name: "Game", bundle: .init(for: WinViewController.self))
        let sut = storyboard.instantiateViewController(withIdentifier: "WinViewController") as! WinViewController
        sut.digitCount = digitCount
        sut.guessCount = guessCount
        sut.showFireworkAnimation = showFireworkAnimation
        
        let recordViewController = sut.recordViewController!
        recordViewController.hostViewController = sut
        recordViewController.guessCount = { guessCount }
        recordViewController.spentTime = { spentTime }
        recordViewController.currentDate = currentDate
        recordViewController.loader = loader
        
        if trackMemoryLeak {
            trackForMemoryLeaks(loader, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
        }
        
        return (sut, loader)
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
    
    var showingBreakRecordView: Bool { recordViewController!.containerView.alpha != 0 }
    
    var emojiViewTransform: CGAffineTransform? { emojiLabel.transform }
    
    var sublayerCount: Int { view.layer.sublayers?.count ?? 0 }
    
    var confirmButtonEanbled: Bool { recordViewController!.confirmButton.isEnabled }
    
    func inputView() -> UITextField {
        recordViewController.inputTextField
    }
    
    func simulateUserInitiatedShareAction() {
        guard let button = navigationItem.rightBarButtonItem else { return }
        
        _ = button.target?.perform(button.action, with: nil)
    }
    
    func simulateUserEnterPlayerName(name: String?) {
        guard let inputTextField = recordViewController?.inputTextField else { return }
        let oldText = inputTextField.text ?? ""
        let newText = name ?? ""
        inputTextField.text = newText
        _ = inputTextField.delegate?.textField?(inputTextField, shouldChangeCharactersIn: NSRange(oldText) ?? NSRange(), replacementString: newText)
    }
    
    func simulateUserSendInput() {
        recordViewController?.confirmButton.sendActions(for: .touchUpInside)
    }
    
    func simulateKeyboardShowing() {
        recordViewController.inputTextField.becomeFirstResponder()
    }
    
    func simulateOnTapScreen() {
        recordViewController.didTapScreen(self)
    }
    
    func simulateUserTapReturn() {
        recordViewController.inputTextField.sendActions(for: .editingDidEndOnExit)
    }
}
