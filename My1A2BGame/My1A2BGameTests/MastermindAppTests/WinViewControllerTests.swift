//
//  WinViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/5.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class WinViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_rendersGuessCount_guess1() {
        let sut = makeSUT(guessCount: 1)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.guessCountMessage, "You guessed 1 time")
    }
    
    func test_viewDidLoad_rendersGuessCount_guess2() {
        let sut = makeSUT(guessCount: 2)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.guessCountMessage, "You guessed 2 times")
    }
    
    func test_viewDidLoad_rendersWinMessage_basic() {
        let sut = makeSUT(isAdvancedVersion: false)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.winMessage, "4A0B!! You won!!")
    }
    
    func test_viewDidLoad_rendersWinMessage_advanced() {
        let sut = makeSUT(isAdvancedVersion: true)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.winMessage, "5A0B!! You won!!")
    }
    
    // MARK: Helpers
    
    private func makeSUT(guessCount: Int = 1, spentTime: TimeInterval = 60.0, isAdvancedVersion: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> WinViewController {
        let storyboard = UIStoryboard(name: "Game", bundle: .init(for: WinViewController.self))
        let sut = storyboard.instantiateViewController(withIdentifier: "WinViewController") as! WinViewController
        sut.guessCount = guessCount
        sut.spentTime = spentTime
        sut.isAdvancedVersion = isAdvancedVersion
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }


}

private extension WinViewController {
    var guessCountMessage: String? { guessCountLabel.text }
    
    var winMessage: String? { winLabel.text }
}
