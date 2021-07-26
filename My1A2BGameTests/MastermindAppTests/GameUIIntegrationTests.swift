//
//  GameUIIntegrationTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/7/25.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class GameUIIntegrationTests: XCTestCase {
    func test_gameView_hasTitleForBasicGame() {
        let sut = makeSUT(gameVersion: .basic)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, basicGameTitle)
    }
    func test_gameView_hasTitleForAdvancedGame() {
        let sut = makeSUT(gameVersion: .advanced)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, advancedGameTitle)
    }

    // MARK: Helpers
    
    private func makeSUT(gameVersion: GameVersion, file: StaticString = #filePath, line: UInt = #line) -> GuessNumberViewController {
        let sut = GameUIComposer.makeGameUI(gameVersion: gameVersion)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private var basicGameTitle: String { "Basic" }
    
    private var advancedGameTitle: String { "Advanced" }

}
