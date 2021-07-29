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
    func test_gameView_hasTitle() {
        GameVersion.allCases.forEach { gameVersion in
            let sut = makeSUT(gameVersion: gameVersion)
            
            sut.loadViewIfNeeded()
            
            XCTAssertEqual(sut.title, gameVersion.title)
        }
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
