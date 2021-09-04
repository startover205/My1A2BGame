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
    
    // MARK: - Helpers
    
    func makeSUT(gameVersion: GameVersion = .basic) -> GuessNumberViewController {
        let controller = UIStoryboard(name: "Game", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(identifier: "GuessViewController") as! GuessNumberViewController
        controller.quizLabelViewController.answer = gameVersion.makeSecret()
        controller.animate = { _, animations, completion in
            animations()
            completion?(true)
        }
        controller.guessCompletion = { _ in
            (nil, false)
        }

        controller.loadViewIfNeeded()
        
        controller.availableGuessLabel.text = "10 chances left"
        
        return controller
    }
}

private extension GameVersion {
    func makeSecret() -> [Int] { Array(repeating: 1, count: digitCount) }
}
