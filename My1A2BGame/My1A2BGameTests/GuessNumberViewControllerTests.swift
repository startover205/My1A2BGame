//
//  GuessNumberViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/6/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame
import Mastermind
import MastermindiOS
import GoogleMobileAds

class GuessNumberViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_helperViewHidden() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.helperView.isHidden)
    }
    
    func test_helperBtnPressed_toggleHelperViewDisplay() {
        let sut = makeSUT(animate: { _, _, completion in
            completion?(true)
        })
        
        sut.helperBtnPressed(sut)
        
        XCTAssertEqual(sut.helperView.isHidden, false)
        
        sut.helperBtnPressed(sut)
        
        XCTAssertEqual(sut.helperView.isHidden, true)
    }
    
    func test_matchNumbers_notifiesHandlerOnWin() {
        var callCount = 0
        let sut = makeSUT { _, _ in
            callCount += 1
        }
        
        sut.initGame()
        
        sut.simulateUserGuessWithCorrectAnswer()
        
        XCTAssertEqual(callCount, 1)
    }
    
    func test_matchNumbers_notifiesLoseHandlerWhenUserHasNoMoreChanceLeft() {
        var onLoseCallCount = 0
        let sut = makeSUT(onLose: {
            onLoseCallCount += 1
        })
        let answer = sut.quizNumbers
        let wrongGuess = Array(answer.reversed())
        
        sut.initGame()
        sut.availableGuess = 2
        
        sut.tryToMatchNumbers(guessTexts: wrongGuess, answerTexts: answer)
        
        XCTAssertEqual(onLoseCallCount, 0, "Expect lose handler not trigger when user has chance")
        
        sut.tryToMatchNumbers(guessTexts: wrongGuess, answerTexts: answer)
        
        XCTAssertEqual(onLoseCallCount, 1, "Expect lose handler triggered when user has no chance left")
    }
    
    // MARK: - Helpers
    func makeSUT(loadView: Bool = true, onWin: @escaping (Int, TimeInterval) -> Void = { _, _ in }, onLose: @escaping () -> Void = {}, animate: @escaping Animate = { _, _, _ in }) -> GuessNumberViewController {
        let sut = GameUIComposer.gameComposedWith(gameVersion: BasicGame(), userDefaults: UserDefaults.standard, adProvider: AdProviderFake(), onWin: onWin, onLose: onLose, animate: animate)
        if loadView {
            sut.loadViewIfNeeded()
        }
        return sut
    }
    
    func triggerRunLoopToSkipNavigationAnimation() {
        RunLoop.current.run(until: Date())
    }
    
    private final class AdProviderFake: AdProvider {
        var rewardAd: GADRewardedAd?
    }
}

private extension GuessNumberViewController {
    func simulateUserGuessWithCorrectAnswer() {
        let answer = quizNumbers
        let guess = answer
        tryToMatchNumbers(guessTexts: guess, answerTexts: answer)
    }
}
