//
//  GameUIIntegrationTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/7/25.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame
import MastermindiOS

class GameUIIntegrationTests: XCTestCase {
    func test_gameView_hasTitle() {
        let gameVersion = GameVersionMock()
        let sut = makeSUT(gameVersion: gameVersion)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, gameVersion.title)
    }
    
    func test_viewComponents_fadeInOnAppear() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        sut.fadeInCompoenents.forEach {
            XCTAssertTrue($0.alpha == 0)
        }
        
        sut.simulateViewAppear()
        
        sut.fadeInCompoenents.forEach {
            XCTAssertTrue($0.alpha != 0)
        }
    }
    
    func test_availableGuess_rendersWithEachGuess() {
        let sut = makeSUT(gameVersion: GameVersionMock(maxGuessCount: 3))

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 3), "expect max guess count once view is loaded")

        sut.simulateUserInitiatedGuess()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 2), "expect guess count minus 1 after user guess")

        sut.simulateUserInitiatedGuess()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 1), "expect guess count minus 1 after user guess")

        sut.simulateUserInitiatedGuess()
        XCTAssertEqual(sut.availableGuessMessage, guessMessageFor(guessCount: 0), "expect guess count minus 1 after user guess")
    }

    // MARK: Helpers
    
    private func makeSUT(gameVersion: GameVersion = GameVersionMock(), file: StaticString = #filePath, line: UInt = #line) -> GuessNumberViewController {
        let sut = GameUIComposer.makeGameUI(gameVersion: gameVersion)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private var basicGameTitle: String { "Basic" }
    
    private var advancedGameTitle: String { "Advanced" }
    
    private final class GameVersionMock: GameVersion {
        let digitCount: Int = 4
        
        let title: String = "a title"
        
        let maxGuessCount: Int
        
        init(maxGuessCount: Int = 5) {
            self.maxGuessCount = maxGuessCount
        }
    }
    
    private func guessMessageFor(guessCount: Int) -> String {
        let chanceString = guessCount == 1 ? "chance" : "chances"
        
        return "\(guessCount) \(chanceString) left" }
}

private extension GuessNumberViewController {
    func simulateViewAppear() { viewWillAppear(false) }
    
    func simulateUserInitiatedGuess() {
        guessButton.sendActions(for: .touchUpInside)
        
        let answer = quizNumbers
        
       let inputVC =  (inputVC.topViewController as! GuessPadViewController)
        inputVC.delegate?.padDidFinishEntering(numberTexts: answer.reversed())
    }
    
    var fadeInCompoenents: [UIView] { fadeOutElements }
    
    var availableGuessMessage: String? { availableGuessLabel.text }
}
