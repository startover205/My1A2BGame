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
        let (sut, gameVersion) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, gameVersion.title)
    }
    
    func test_viewComponents_fadeInOnAppear() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        sut.fadeInCompoenents.forEach {
            XCTAssertTrue($0.alpha == 0)
        }
        
        sut.simulateViewAppear()
        
        sut.fadeInCompoenents.forEach {
            XCTAssertTrue($0.alpha != 0)
        }
    }

    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (GuessNumberViewController, GameVersion) {
        let gameVersion = GameVersionSpy()
        let sut = GameUIComposer.makeGameUI(gameVersion: gameVersion)
        
        trackForMemoryLeaks(gameVersion, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, gameVersion)
    }
    
    private var basicGameTitle: String { "Basic" }
    
    private var advancedGameTitle: String { "Advanced" }
    
    private final class GameVersionSpy: GameVersion {
        let digitCount: Int = Int.random(in: 3...6)
        
        let title: String = "a title"
    }

}

private extension GuessNumberViewController {
    var fadeInCompoenents: [UIView] { fadeOutElements }
    
    func simulateViewAppear() {
        self.viewWillAppear(false)
    }
}
