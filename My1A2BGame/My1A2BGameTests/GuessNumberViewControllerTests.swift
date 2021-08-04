//
//  GuessNumberViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/6/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame
import MastermindiOS

class GuessNumberViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_helperViewHidden() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.helperView.isHidden)
    }
    
    func test_helperBtnPressed_toggleHelperViewDisplay() {
        let sut = makeSUT()
        
        sut.helperBtnPressed(sut)
        
        XCTAssertEqual(sut.helperView.isHidden, false)
        
        sut.helperBtnPressed(sut)
        
        assert({
            XCTAssertEqual(sut.helperView.isHidden, true)
        }, after: 0.5)
        
    }
    
    func test_matchNumbers_presentWinVCWhenCorrect() {
        let sut = makeSUT()
        let navigation = UINavigationController()
        navigation.setViewControllers([sut], animated: false)
        
        sut.initGame()
        let answer = sut.quizNumbers
        let guess = answer
        sut.tryToMatchNumbers(guessTexts: guess, answerTexts: answer)
        
        triggerRunLoopToSkipNavigationAnimation()
        XCTAssertTrue(navigation.topViewController is WinViewController)
    }
    
    func test_matchNumbers_doesNotPresentLoseVCWhenIncorrectWithAnotherChance() {
        let sut = makeSUT()
        let navigation = UINavigationController()
        navigation.setViewControllers([sut], animated: false)
        
        sut.initGame()
        
        let answer = sut.quizNumbers
        let guess = Array(sut.quizNumbers.reversed())
        sut.tryToMatchNumbers(guessTexts: guess, answerTexts: answer)
        
        triggerRunLoopToSkipNavigationAnimation()
        XCTAssertFalse(navigation.topViewController is LoseViewController)
    }
    
    func test_matchNumbers_presentLoseVCWhenIncorrectWithOneLastChance() {
        let sut = makeSUT()
        let navigation = UINavigationController()
        navigation.setViewControllers([sut], animated: false)
        
        sut.initGame()
        sut.availableGuess = 1
        
        let answer = sut.quizNumbers
        let guess = Array(sut.quizNumbers.reversed())
        sut.tryToMatchNumbers(guessTexts: guess, answerTexts: answer)
        
        triggerRunLoopToSkipNavigationAnimation()
        XCTAssertTrue(navigation.topViewController is LoseViewController)
    }
    
    func test_tryToMatchNumbers_rendersResult() {
        let sut = makeSUT()
        let answer = ["1", "2", "3", "4"]
        let guess1 = ["5", "2", "3", "4"]
        let guess2 = ["5", "6", "3", "4"]
        let resultView = sut.lastGuessLabel
        
        XCTAssertEqual(resultView?.text, "", "expected no text after loading")
        
        sut.tryToMatchNumbers(guessTexts: guess1, answerTexts: answer)
        XCTAssertEqual(resultView?.text, "5234          3A0B\n", "expected latest result after matching")
        
        sut.tryToMatchNumbers(guessTexts: guess2, answerTexts: answer)
        XCTAssertEqual(resultView?.text, "5634          2A0B\n", "expected latest result after matching")
    }
    
    // MARK: - Helpers
    func makeSUT(loadView: Bool = true) -> GuessNumberViewController {
        let sut = GameUIComposer.makeGameUI(gameVersion: BasicGame(), userDefaults: UserDefaults.standard)
        if loadView {
            sut.loadViewIfNeeded()
        }
        return sut
    }
    
    func triggerRunLoopToSkipNavigationAnimation() {
        RunLoop.current.run(until: Date())
    }
    
    func assert(_ completion: @escaping () -> Void, after seconds: TimeInterval) {
        let exp = expectation(description: "wait until animation complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: seconds + 1.0)
    }
}
