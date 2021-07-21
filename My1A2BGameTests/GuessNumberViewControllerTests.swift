//
//  GuessNumberViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/6/1.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame

class GuessNumberViewControllerTests: XCTestCase {
    func test_viewDidLoad_fadeOutElmentsAreOpaque() {
        makeSUT().fadeOutElements.forEach {
            XCTAssertTrue($0.alpha == 0)
        }
    }
    
    func test_viewDidLoad_navigiationControllerDelegateIsSelf() {
        
        let navigation = UINavigationController()
        
        let sut = makeSUT(loadView: false)
        
        navigation.setViewControllers([sut], animated: false)

        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.navigationController?.delegate === sut)
    }
    
    func test_initGame_availableGuessLabelIsShowingMaxPlayChancesAndLabelColor() {
        let sut = makeSUT()
        let format = NSLocalizedString("You can still guess %d times", comment: "")
        let text = String.localizedStringWithFormat(format, Constants.maxPlayChances)
        
        XCTAssertEqual(sut.availableGuessLabel.text, text)
        XCTAssertEqual(sut.availableGuessLabel.textColor, UIColor.label)
    }
    
    func test_viewWillAppear_fadeOutElmentsAreVisible() {
        let sut = makeSUT()

        sut.viewWillAppear(false)
        
        sut.fadeOutElements.forEach {
            XCTAssertEqual($0.alpha, 1)
        }
    }
    
    func test_viewWillAppear_voiceSwitchStatusAccordingToUserDefaultSetting() {
        let sut = makeSUT()
        UserDefaults.standard.setValue(true, forKey: UserDefaults.Key.voicePromptsSwitch)
        
        sut.viewWillAppear(false)
        
        XCTAssertEqual(sut.voiceSwitch.isOn, true)

        UserDefaults.standard.setValue(false, forKey: UserDefaults.Key.voicePromptsSwitch)
        
        sut.viewWillAppear(false)

        XCTAssertEqual(sut.voiceSwitch.isOn, false)
    }
    
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
        expect({
            XCTAssertEqual(sut.helperView.isHidden, true)
        }, after: 1.0)
    }
    
    func test_restart_fadeOutElementsAreOpaque() {
        let sut = makeSUT()
        
        sut.restartBtnPressed(sut)
        
        sut.fadeOutElements.forEach {
            XCTAssertEqual($0.alpha, 0)
        }
    }
    
    func test_guessBtnPressed_presentNumberPanel() {
        let sut = makeSUT()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = sut
        
        sut.availableGuess = 10
        sut.guessBtnPressed(sut)
        
        expect({
            XCTAssertTrue((sut.presentedViewController as? UINavigationController)?.topViewController is GuessPadViewController)
        }, after: 2.0)
    }
    
    func test_voicePromptSwitchToggle_boundToUserDefaultsValue() {
        let sut = makeSUT()
        let userDefaultKey = UserDefaults.Key.voicePromptsSwitch
        UserDefaults.standard.set(true, forKey: userDefaultKey)
        
        sut.voiceSwitch.isOn = false
        sut.changeVoicePromptsSwitchState(UISwitch())
        
        XCTAssertEqual(UserDefaults.standard.bool(forKey: userDefaultKey), sut.voiceSwitch.isOn)
        
        sut.voiceSwitch.isOn = true
        sut.changeVoicePromptsSwitchState(UISwitch())
        XCTAssertEqual(UserDefaults.standard.bool(forKey: userDefaultKey), sut.voiceSwitch.isOn)
    }
    
    func test_initGame_availableGuessIsAtMax() {
        let sut = makeSUT()
        
        sut.initGame()
        
        XCTAssertEqual(sut.availableGuess, Constants.maxPlayChances)
    }
    
    func test_matchNumbers_presentWinVCWhenCorrect() {
        let sut = makeSUT()
        let navigation = UINavigationController()
        navigation.setViewControllers([sut], animated: false)
        
        sut.initGame()
        let answers = sut.quizNumbers
        sut.tryToMatchNumbers(answerTexts: answers)
        
        expect({
            XCTAssertTrue(navigation.topViewController is WinViewController)
        }, after: 1.0)
    }
    
    func test_matchNumbers_doesNotPresentLoseVCWhenIncorrectWithAnotherChance() {
        let sut = makeSUT()
        let navigation = UINavigationController()
        navigation.setViewControllers([sut], animated: false)
        
        sut.initGame()
        
        let answers = Array(sut.quizNumbers.reversed())
        sut.tryToMatchNumbers(answerTexts: answers)
        
        expect({
            XCTAssertFalse(navigation.topViewController is LoseViewController)
        }, after: 1.0)
    }
    
    func test_matchNumbers_presentLoseVCWhenIncorrectWithOneLastChance() {
        let sut = makeSUT()
        let navigation = UINavigationController()
        navigation.setViewControllers([sut], animated: false)
        
        sut.initGame()
        sut.availableGuess = 1

        let answers = Array(sut.quizNumbers.reversed())
        sut.tryToMatchNumbers(answerTexts: answers)
        
        expect({
            XCTAssertTrue(navigation.topViewController is LoseViewController)
        }, after: 1.0)
    }
    
    func test_changeAvailableGuess_updateAvailableGuessLabelAccordingly() {
        let sut = makeSUT()
        
        sut.availableGuess = 2
        
        XCTAssertEqual(sut.availableGuessLabel.text?.contains(sut.availableGuess.description), true)
        
        sut.availableGuess = 5
        
        XCTAssertEqual(sut.availableGuessLabel.text?.contains(sut.availableGuess.description), true)
    }
    
    // MARK: - Helpers
    func makeSUT(loadView: Bool = true) -> GuessNumberViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        let sut = storyboard.instantiateViewController(withIdentifier: "GuessViewController") as! GuessNumberViewController
        sut.evaluate = MastermindEvaluator.evaluate(_:with:)
        if loadView {
            sut.loadViewIfNeeded()
        }
        return sut
    }
    
    func expect(_ completion: @escaping () -> Void, after seconds: TimeInterval) {
        let exp = expectation(description: "wait until presentation/animation complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: seconds + 1.0)
    }
}
