//
//  WinViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/5.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class WinViewControllerBasicGameTests: XCTestCase {
    
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
    
    func test_viewDidLoad_rendersWinMessage() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.winMessage, "4A0B!! You won!!")
    }
    
    func test_viewDidload_rendersBreakRecordViewsIfBreakRecord() {
        let store = PlayerStore()
        let guessCount = 1
        let sut = makeSUT(guessCount: guessCount,store: store)
        
        store.clearRecords()
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.showingBreakRecordView)
    }
    
    func test_viewDidload_doesNotRendersNewRecordViewsIfRecordNotBroken() {
        let store = PlayerStore()
        let guessCount = 20
        let sut = makeSUT(guessCount: guessCount, store: store)
        let existingTopRecords = Array(repeating: GameWinner(name: nil, guessTimes: 1, spentTime: 0, winner: Winner()), count: 10)
        
        store.addRecords(existingTopRecords)
        sut.loadViewIfNeeded()
        
        XCTAssertFalse(sut.showingBreakRecordView)
    }
    
    // MARK: Helpers
    
    private func makeSUT(guessCount: Int = 1, spentTime: TimeInterval = 60.0, store: WinnerStore? = nil, file: StaticString = #filePath, line: UInt = #line) -> WinViewController {
        let storyboard = UIStoryboard(name: "Game", bundle: .init(for: WinViewController.self))
        let sut = storyboard.instantiateViewController(withIdentifier: "WinViewController") as! WinViewController
        sut.guessCount = guessCount
        sut.spentTime = spentTime
        sut.isAdvancedVersion = false
        sut.winnerStore = store
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private final class PlayerStore: WinnerStore {
        var players = [GameWinner]()
        
        var totalCount: Int {
            players.count
        }
        
        func fetchAllObjects() -> [GameWinner] {
            players
        }
        
        func createObject() -> GameWinner {
            GameWinner(name: nil, guessTimes: 1, spentTime: 1, winner: Winner())
        }
        
        func delete(object: GameWinner) {
            players.removeAll { $0 === object }
        }
        
        func saveContext(completion: SaveDoneHandler?) {
        }
        
        func clearRecords() {
            players.removeAll()
        }
        
        func addRecords(_ records: [GameWinner]) {
            players.append(contentsOf: records)
        }
    }
}

private extension WinViewController {
    var guessCountMessage: String? { guessCountLabel.text }
    
    var winMessage: String? { winLabel.text }
    
    var showingBreakRecordView: Bool { newRecordStackView.alpha != 0 }
}
