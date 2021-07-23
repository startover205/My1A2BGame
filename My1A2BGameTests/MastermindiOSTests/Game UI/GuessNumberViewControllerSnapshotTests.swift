//
//  GuessNumberViewControllerSnapshotTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/7/23.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class GuessNumberViewControllerSnapshotTests: XCTestCase {
    func test_gameStart_basic() {
        let sut = makeSUT(advanced: false)
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "GAME_START_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "GAME_START_dark")
    }
    func test_gameStart_advanced() {
        let sut = makeSUT(advanced: true)
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "GAME_START_ADVANCED_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "GAME_START_ADVANCED_dark")
    }
    
    // MARK: - Helpers
    
    func makeSUT(advanced: Bool) -> UIViewController {
        let controller = UIStoryboard(name: "Game", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(identifier: advanced ? "GuessAdvancedViewController" : "GuessViewController") as! GuessNumberViewController
        controller.loadViewIfNeeded()
        controller.availableGuessLabel.isHidden = true
        return controller
    }
}
