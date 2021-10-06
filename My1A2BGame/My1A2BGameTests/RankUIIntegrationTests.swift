//
//  RankUIIntegrationTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/2.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import Mastermind
import My1A2BGame

class RankUIIntegrationTests: XCTestCase {
    func test_loadRecordsActions_requestsRecordsFromLoader() {
        let basicRecordLoader = RecordLoaderSpy(stub: [])
        let advancedRecordLoader = RecordLoaderSpy(stub: [])
        let sut = makeSUT(requestRecords: basicRecordLoader, requestAdvancedRecords: advancedRecordLoader)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(basicRecordLoader.loadCallCount, 0, "Expect no loading requests after view is loaded")
        
        sut.viewWillAppear(false)
        XCTAssertEqual(basicRecordLoader.loadCallCount, 1, "Expect a loading request on will view appear")
        
        sut.viewWillAppear(false)
        XCTAssertEqual(basicRecordLoader.loadCallCount, 2, "Expect another loading request on will view appear")
        
        sut.simulateChangeSegmentIndex(to: 0)
        XCTAssertEqual(basicRecordLoader.loadCallCount, 2, "Expect no loading requests on tapping the current segment")
        
        sut.simulateChangeSegmentIndex(to: 1)
        XCTAssertEqual(advancedRecordLoader.loadCallCount, 1, "Expect a loading request on tapping other segments")
        
        sut.viewWillAppear(false)
        XCTAssertEqual(advancedRecordLoader.loadCallCount, 2, "Expect another loading request on will view appear")
        
        sut.simulateChangeSegmentIndex(to: 0)
        XCTAssertEqual(basicRecordLoader.loadCallCount, 3, "Expect a loading request on tapping other segments")
    }
    
    func test_loadRecordsCompletion_rendersSuccessfullyLoadedRecords() {
        let placeholder = CellViewModel(name: "-----", guessCount: "--", guessTime: "--:--:--")
        let record0 = makeRecord(name: "a name", guessCount: 10, guessTime: 300)
        let record1 = makeRecord(name: "another name", guessCount: 13, guessTime: 123.3)
        let record2 = makeRecord(name: "a name", guessCount: 1, guessTime: 5.1)
        let recordLoader = RecordLoaderSpy(stub: [])
        let sut = makeSUT(requestRecords: recordLoader)
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [placeholder])

        sut.viewWillAppear(false)
        assertThat(sut, isRendering: [placeholder])

        recordLoader.stub = [record0, record1]
        sut.viewWillAppear(false)
        assertThat(sut, isRendering: [record0.toModel(guessTime: "00:05:00"), record1.toModel(guessTime: "00:02:03")])

        recordLoader.stub = [record0, record1, record2]
        sut.viewWillAppear(false)
        assertThat(sut, isRendering: [record0.toModel(guessTime: "00:05:00"), record1.toModel(guessTime: "00:02:03"), record2.toModel(guessTime: "00:00:05")])

        recordLoader.stub = [record0]
        sut.viewWillAppear(false)
        assertThat(sut, isRendering: [record0.toModel(guessTime: "00:05:00")])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(requestRecords: RecordLoader = RecordLoaderSpy(stub: []), requestAdvancedRecords: RecordLoader = RecordLoaderSpy(stub: []), file: StaticString = #filePath, line: UInt = #line) -> RankViewController {
        
        let sut = RankUIComposer.rankComposedWith(requestRecords: requestRecords, requestAdvancedRecords: requestAdvancedRecords)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assertThat(_ sut: RankViewController, isRendering records: [CellViewModel], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedRecordViews() == records.count else {
            return XCTFail("Expected \(records.count) records, got \(sut.numberOfRenderedRecordViews()) instead.", file: file, line: line)
        }
        
        records.enumerated().forEach { index, record in
            assertThat(sut, hasViewConfiguredFor: record, at: index)
        }
    }

    private func assertThat(_ sut: RankViewController, hasViewConfiguredFor record: CellViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let cell = sut.tableView.dataSource?.tableView(sut.tableView, cellForRowAt: IndexPath(row: index, section: 0)) as? RankTableViewCell
        XCTAssertEqual(cell?.nameLabel.text, record.name, "Expected `name` to be \(record.name) for image view at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell?.timesLabel.text, record.guessCount, "Expected `guessCount` to be \(record.guessCount) for image view at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell?.spentTimeLabel.text, record.guessTime, "Expected `guessTime` to be \(record.guessTime) for image view at index (\(index))", file: file, line: line)
    }

    private func makeRecord(name: String, guessCount: Int, guessTime: TimeInterval) -> PlayerRecord {
        .init(playerName: name, guessCount: guessCount, guessTime: guessTime, timestamp: Date())
    }
    
    private final class RecordMock: User {
        var date: Date
        var guessTimes: Int16
        var name: String
        var spentTime: Double
        
        init(date: Date, guessTimes: Int16, name: String, spentTime: Double) {
            self.date = date
            self.guessTimes = guessTimes
            self.name = name
            self.spentTime = spentTime
        }
    }
    
    private final class RecordLoaderSpy: RecordLoader {
        var stub: [PlayerRecord]
        private(set) var loadCallCount = 0
        
        init(stub: [PlayerRecord]) {
            self.stub = stub
        }
        
        func load() throws -> [PlayerRecord] {
            loadCallCount += 1
            return stub
        }
        
        func validate(score: Score) -> Bool {
            true
        }
        
        func insertNewRecord(_ record: PlayerRecord) throws {
        }
    }
}

private extension RankViewController {
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func numberOfRenderedRecordViews() -> Int {
        numberOfRows(in: recordsSection)
    }
    
    func simulateChangeSegmentIndex(to index: Int) {
        let currentIndex = gameTypeSegmentedControl.selectedSegmentIndex
        gameTypeSegmentedControl.selectedSegmentIndex = index
        if index != currentIndex {
            gameTypeSegmentedControl.sendActions(for: .valueChanged)
        }
    }
    
    private var recordsSection: Int { 0 }
}


private struct CellViewModel {
    let name: String
    let guessCount: String
    let guessTime: String
}

private extension User {
    func toModel(guessTime: String) -> CellViewModel {
        CellViewModel(name: name, guessCount: guessTimes.description, guessTime: guessTime)
    }
}

private extension PlayerRecord {
    func toModel(guessTime: String) -> CellViewModel {
        CellViewModel(name: playerName, guessCount: guessCount.description, guessTime: guessTime)
    }
}
