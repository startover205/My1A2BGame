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
    func test_gameStart_basic() {
        let sut = makeSUT(gameVersion: BasicGame())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "GAME_START_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "GAME_START_dark")
    }
    
    func test_gameStart_advanced() {
        let sut = makeSUT(gameVersion: AdvancedGame())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "GAME_START_ADVANCED_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "GAME_START_ADVANCED_dark")
    }
    
    func test_gameWithOneLastChance_basic() {
        let sut = makeSUT(gameVersion: BasicGame())
        
        sut.simulateGameWithOneLastChance()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "GAME_WITH_ONE_LAST_CHANCE_BASIC_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "GAME_WITH_ONE_LAST_CHANCE_BASIC_dark")
    }
    
    func test_gameWithOneLastChance_advanced() {
        let sut = makeSUT(gameVersion: AdvancedGame())
        
        sut.simulateGameWithOneLastChance()
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "GAME_WITH_ONE_LAST_CHANCE_ADVANCED_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "GAME_WITH_ONE_LAST_CHANCE_ADVANCED_dark")
    }
    
    // MARK: - Helpers
    
    func makeSUT(gameVersion: GameVersion) -> GuessNumberViewController {
        let controller = UIStoryboard(name: "Game", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(identifier: "GuessViewController") as! GuessNumberViewController
        controller.gameVersion = gameVersion
        controller.loadViewIfNeeded()
        controller.animate = { _, animations, completion in
            animations()
            completion?(true)
        }
        return controller
    }
}

fileprivate extension GuessNumberViewController {
    func  simulateGameWithOneLastChance() {
        let answer = quizNumbers
        let wrongAnswer: [String] = quizNumbers.reversed()
        let maxChances = gameVersion.maxGuessCount
            
        for _ in 0..<maxChances-1 {
            self.tryToMatchNumbers(guessTexts: wrongAnswer, answerTexts: answer)
        }
    }
}
