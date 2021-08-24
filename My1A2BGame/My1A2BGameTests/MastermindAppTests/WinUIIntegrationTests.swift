//
//  WinViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/5.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import Mastermind
import MastermindiOS
import My1A2BGame

class WinUIIntegrationTests: XCTestCase {
    
    func test_loadView_rendersGuessCountMessageAccordingToGuessCount() {
        let guessCount = 1
        let (sut, _) = makeSUT(guessCount: guessCount)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.guessCountMessage, guessCountMessageFor(guessCount: guessCount))
        
        let (anotherSut, _) = makeSUT(guessCount: guessCount+1)
        
        anotherSut.loadViewIfNeeded()
        
        XCTAssertEqual(anotherSut.guessCountMessage, guessCountMessageFor(guessCount: guessCount+1))
    }
    
    func test_loadView_rendersWinMessageAccordingToDigitCount() {
        let digitCount = 3
        let (sut, _) = makeSUT(digitCount: digitCount)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.winMessage, winMessageFor(digitCount: digitCount))
    }
    
    func test_loadView_reqeustLoaderValidatePlayerScore() {
        let guessCount = 3
        let guessTime = 10.0
        let (sut, loader) = makeSUT(guessCount: guessCount, guessTime: guessTime)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.receivedMessages, [.validate(guessCount, guessTime)])
    }
    
    func test_loadView_rendersBreakRecordViewsIfBreakRecord() {
        let (sut, loader) = makeSUT()
        
        loader.completeValidation(with: true)
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.showingSaveRecordViews)
    }
    
    func test_loadView_doesNotRendersNewRecordViewsIfRecordNotBroken() {
        let (sut, loader) = makeSUT()
        
        loader.completeValidation(with: false)
        sut.loadViewIfNeeded()
        
        XCTAssertFalse(sut.showingSaveRecordViews)
    }
    
    func test_emojiAnimation_showsOnTheFirstTimeOnly() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        var capturedTransform = sut.emojiViewTransform
        
        sut.viewDidAppear(true)
        
        XCTAssertNotEqual(sut.emojiViewTransform, capturedTransform, "Expect emoji view transform changed after view did appear")
        
        capturedTransform = sut.emojiViewTransform
        sut.viewDidAppear(true)
        
        XCTAssertEqual(sut.emojiViewTransform, capturedTransform, "Expect emoji view transform does not change when the view appeared the second time")
    }
    
    func test_fireworkAnimation_showsOnTheFirstTimeOnly() {
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
    
    func test_tapOnShareView_canShareContent() {
        let (sut, _) = makeSUT()
        let hostVC = UIViewControllerSpy()
        let shareController = ShareViewController(hostViewController: hostVC, guessCount: { [unowned sut] in sut.guessCount }, appDownloadUrl: "")
        sut.shareViewController = shareController

        sut.loadViewIfNeeded()

        sut.simulateUserInitiatedShareAction()
        
        XCTAssertEqual(hostVC.presentCallCount, 1)
        
        sut.simulateUserInitiatedShareAction()
        
        XCTAssertEqual(hostVC.presentCallCount, 2)
    }

    func test_saveRecordButton_enabledOnlyWhenUserEnteredName() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertFalse(sut.saveReocrdButtonEanbled, "expect confirm button to be not enabled after view did load")
        
        sut.simulateUserEnterPlayerName(name: "any name")
        
        XCTAssertTrue(sut.saveReocrdButtonEanbled, "expect confirm button to be enabled after user entered name")
        
        sut.simulateUserEnterPlayerName(name: "")
        
        XCTAssertFalse(sut.saveReocrdButtonEanbled, "expect confirm button to be not enabled after user clear name input")
    }
    
    func test_saveRecordButton_dismissKeyboardOnButtonPressed() {
        let (sut, _) = makeSUT(trackMemoryLeak: false)
        let window = UIWindow()
        window.addSubview(sut.view)
        
        sut.loadViewIfNeeded()
        sut.simulateKeyboardShowing()
        
        XCTAssertTrue(sut.isKeyboardShowing, "expect keyboard showing when user start to enter player name")
        
        sut.simulateUserEnterPlayerName(name: "any name")
        sut.simulateUserSendInput()
        
        XCTAssertFalse(sut.isKeyboardShowing, "expect keyboard dismiss after user sent out input")
    }
    
    func test_saveRecord_requestStoreToSavePlayerRecord() {
        let playerRecord = anyPlayerRecord()
        let (sut, loader) = makeSUT(guessCount: playerRecord.guessCount, guessTime: playerRecord.guessTime, currentDate: { playerRecord.timestamp })
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.receivedMessages, [.validate(playerRecord.guessCount, playerRecord.guessTime)], "Expect no save message added after view load")
        
        sut.simulateUserSendInput()
        XCTAssertEqual(loader.receivedMessages, [.validate(playerRecord.guessCount, playerRecord.guessTime)], "Expect no save message added after view load")

        sut.simulateUserEnterPlayerName(name: playerRecord.playerName)
        loader.completeSave(with: anyNSError())
        sut.simulateUserSendInput()
        XCTAssertEqual(loader.receivedMessages, [
            .validate(playerRecord.guessCount, playerRecord.guessTime),
                        .save(playerRecord)
        ], "Expect save message when user presses confirm button with player name entered")
        
        loader.completeSaveSuccesfully()
        sut.simulateUserSendInput()
        XCTAssertEqual(loader.receivedMessages, [
                        .validate(playerRecord.guessCount, playerRecord.guessTime),
                        .save(playerRecord),
                        .save(playerRecord)
        ], "Expect another save message when user trys to save again")
    }
    
    func test_saveRecord_hidesSaveRecordViewsAfterSuccessfullySaveRecord() {
        let playerRecord = anyPlayerRecord()
        let (sut, loader) = makeSUT(guessCount: playerRecord.guessCount, guessTime: playerRecord.guessTime, currentDate: { playerRecord.timestamp })
        
        loader.completeValidation(with: true)
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.showingSaveRecordViews)
        
        sut.simulateUserEnterPlayerName(name: playerRecord.playerName)
        
        loader.completeSave(with: anyNSError())
        sut.simulateUserSendInput()
        XCTAssertTrue(sut.showingSaveRecordViews)
        
        loader.completeSaveSuccesfully()
        sut.simulateUserSendInput()
        XCTAssertFalse(sut.showingSaveRecordViews)
    }
    
    func test_tapOnScreen_dismissKeyboard() {
        let (sut, _) = makeSUT(trackMemoryLeak: false)
        let window = UIWindow()
        window.addSubview(sut.view)
        
        sut.loadViewIfNeeded()
        sut.simulateKeyboardShowing()
        
        XCTAssertTrue(sut.isKeyboardShowing)

        sut.simulateOnTapScreen()
        
        XCTAssertFalse(sut.isKeyboardShowing)
    }
    
    // MARK: Helpers
    
    private func makeSUT(digitCount: Int = 4, guessCount: Int = 1, guessTime: TimeInterval = 60.0, currentDate: @escaping () -> Date = Date.init, showFireworkAnimation: @escaping (UIView) -> Void = { _ in }, trackMemoryLeak: Bool = true, file: StaticString = #filePath, line: UInt = #line) -> (WinViewController, RecordLoaderSpy) {
        let loader = RecordLoaderSpy()
        let sut = WinUIComposer.winComposedWith(digitCount: digitCount, recordLoader: loader)
        sut.guessCount = guessCount
        sut.showFireworkAnimation = showFireworkAnimation
        
        let recordViewController = sut.recordViewController!
        recordViewController.hostViewController = sut
        let recordViewModel = RecordViewModel(
            loader: loader,
            guessCount: { guessCount },
            guessTime: { guessTime },
            currentDate: currentDate)
        recordViewController.recordViewModel = recordViewModel
        
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
    
    private func guessCountMessageFor(guessCount: Int) -> String {
        let unit = guessCount == 1 ? "time" : "times"
        return "You guessed \(guessCount) \(unit)"
    }
    
    private final class UIViewControllerSpy: UIViewController {
        var presentCallCount = 0
        
        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            presentCallCount += 1
        }
    }
    
    private final class RecordLoaderSpy: RecordLoader {
        enum Message: Equatable {
            case load
            case validate(_ guessCount: Int, _ guessTime: TimeInterval)
            case save(_ record: PlayerRecord)
        }
        
        private var loadResult: Result<[PlayerRecord], Error>?
        private var validationResult: Bool?
        private var saveResult: Result<Void, Error>?
        
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
            try saveResult?.get()
        }
        
        func completeValidation(with result: Bool) {
            validationResult = result
        }
        
        func completeRetrieval(with records: [PlayerRecord]) {
            loadResult = .success(records)
        }
        
        func completeSave(with error: NSError) {
            saveResult = .failure(error)
        }
        
        func completeSaveSuccesfully() {
            saveResult = .success(())
        }
    }
}

private extension WinViewController {
    var guessCountMessage: String? { guessCountLabel.text }
    
    var winMessage: String? { winLabel.text }
    
    var showingSaveRecordViews: Bool { recordViewController!.containerView.alpha != 0 }
    
    var emojiViewTransform: CGAffineTransform? { emojiLabel.transform }
    
    var sublayerCount: Int { view.layer.sublayers?.count ?? 0 }
    
    var saveReocrdButtonEanbled: Bool { recordViewController!.confirmButton.isEnabled }
    
    var isKeyboardShowing: Bool {
        inputView().isFirstResponder
    }
    
    func inputView() -> UITextField {
        recordViewController.inputTextField
    }
    
    func simulateUserInitiatedShareAction() {
        guard let button = navigationItem.rightBarButtonItem else { return }
        
        _ = button.target?.perform(button.action, with: nil)
    }
    
    func simulateUserEnterPlayerName(name: String?) {
        recordViewController.inputTextField.text = name
        
        recordViewController.inputTextField.sendActions(for: .editingChanged)
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