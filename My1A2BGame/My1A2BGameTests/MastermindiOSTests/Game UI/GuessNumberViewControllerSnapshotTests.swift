//
//  GuessNumberViewControllerSnapshotTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/7/23.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame

class GuessNumberViewControllerSnapshotTests: XCTestCase {
    func test_gameStart() {
        let sut = makeSUT()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "GAME_START_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "GAME_START_dark")
    }
    
    func test_gameStart_advanced() {
        let sut = makeSUT(gameVersion: .advanced)
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "GAME_START_advanced_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "GAME_START_advanced_dark")
    }
    
    func test_gameWithHelperShown() {
        let sut = makeSUT()
        
        sut.simulateTurnOnHelper()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "GAME_HELPER_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "GAME_HELPER_dark")
    }
    
    func test_gameWithOneWrongGuess() {
        let sut = makeSUT()
        
        sut.simulateGameWithOneGuess()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "GAME_ONE_GUESS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "GAME_ONE_GUESS_dark")
    }
    
    func test_gameWithTwoWrongGuesses() {
        let sut = makeSUT()
        
        sut.simulateGameWithTwoGuess()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "GAME_TWO_GUESS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "GAME_TWO_GUESS_dark")
    }
    
    func test_gameWithResult() {
        let sut = makeSUT()
        
        sut.simulateGameEnd()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "GAME_RESULT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "GAME_RESULT_dark")
    }
    
    // MARK: - Helpers
    
    func makeSUT(gameVersion: GameVersion = .basic) -> GuessNumberViewController {
        let controller = UIStoryboard(name: "Game", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(identifier: "GuessViewController") as! GuessNumberViewController
        controller.quizLabelViewController.answer = gameVersion.makeSecret()
        let animate: Animate = { _, animations, completion in
            animations()
            completion?(true)
        }
        controller.animate = animate
        controller.guessCompletion = { _ in
            (nil, false)
        }
        
        controller.loadViewIfNeeded()
        controller.helperViewController.animate = animate
        
        controller.availableGuess = 10
        
        return controller
    }
}

private extension GameVersion {
    func makeSecret() -> [Int] {
        var digits = [Int]()
        for i in 0..<digitCount {
            digits.append(i)
        }
        return digits
    }
}

private extension GuessNumberViewController {
    func simulateGameWithOneGuess() {
        hintViewController.hintLabel.isHidden = false
        hintViewController.hintLabel.text = "3210          0A4B"
    }
    
    func simulateGameWithTwoGuess() {
        hintViewController.hintLabel.isHidden = false
        hintViewController.hintLabel.text = "3210          0A4B"
        hintViewController.hintTextView.text = "\n3210          0A4B"
    }
    
    func simulateGameEnd() {
        configureViewsForGameResult()
    }
    
    func simulateTurnOnHelper() {
        helperViewController.helperBtnPressed(self)
    }
}
