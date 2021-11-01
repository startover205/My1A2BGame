//
//  RankUIIntegrationTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/2.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import Mastermind
import MastermindiOS
import My1A2BGame

class RankUIIntegrationTests: XCTestCase {
    
    func test_rankView_hasRankSelectionView() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.hasRankSelectionView)
    }
    
    func test_rankSelectionView_rendersRankTitles() {
        let anyLoader = RecordLoaderSpy()
        let rank = Rank(title: "a title", loader: anyLoader)
        let anotherRank = Rank(title: "another title", loader: anyLoader)
        let sut = makeSUT(ranks: [rank, anotherRank])
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.selectionTitle(at: 0), "a title", "title at 0 not matching")
        XCTAssertEqual(sut.selectionTitle(at: 1), "another title", "title at 1 not matching")
    }
    
    func test_loadRecordsActions_requestsRecordsFromLoader() {
        let loader = RecordLoaderSpy(stub: [])
        let anotherLoader = RecordLoaderSpy(stub: [])
        let rank = Rank(title: "a title", loader: loader)
        let anotherRank = Rank(title: "another title", loader: anotherLoader)
        let sut = makeSUT(ranks: [rank, anotherRank])
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 0, "Expect no loading requests after view is loaded")
        
        sut.viewWillAppear(false)
        XCTAssertEqual(loader.loadCallCount, 1, "Expect a loading request on will view appear")
        
        sut.viewWillAppear(false)
        XCTAssertEqual(loader.loadCallCount, 2, "Expect another loading request on will view appear")
        
        sut.simulateChangeRankSelection(to: 0)
        XCTAssertEqual(loader.loadCallCount, 2, "Expect no loading requests on tapping the current segment")
        
        sut.simulateChangeRankSelection(to: 1)
        XCTAssertEqual(anotherLoader.loadCallCount, 1, "Expect a loading request on tapping other segments")
        
        sut.viewWillAppear(false)
        XCTAssertEqual(anotherLoader.loadCallCount, 2, "Expect another loading request on will view appear")
        
        sut.simulateChangeRankSelection(to: 0)
        XCTAssertEqual(loader.loadCallCount, 3, "Expect a loading request on tapping other segments")
    }
    
    func test_loadRecordsCompletion_rendersSuccessfullyLoadedRecordsAndPlaceholderForEmptyRecords() {
        let placeholder = RecordViewModel(playerName: "-----", guessCount: "--", guessTime: "--:--:--")
        let record0 = makeRecord(name: "a name", guessCount: 10, guessTime: 300)
        let record1 = makeRecord(name: "another name", guessCount: 13, guessTime: 123.3)
        let record2 = makeRecord(name: "a name", guessCount: 1, guessTime: 5.1)
        let recordLoader = RecordLoaderSpy(stub: [])
        let rank = Rank(title: "a title", loader: recordLoader)
        let sut = makeSUT(ranks: [rank])
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

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
    
    func test_loadRank_rendersErrorMessageOnError() throws {
        let loadError = anyNSError()
        let recordLoader = RecordLoaderSpy(stubbedError: loadError)
        let hostVC = UIViewControllerSpy()
        let rank = Rank(title: "a title", loader: recordLoader)
        let sut = makeSUT(ranks: [rank], hostVC: hostVC)
        
        sut.loadViewIfNeeded()
        sut.viewWillAppear(false)
        
        let alert = try XCTUnwrap(hostVC.capturedPresentations.first?.vc as? UIAlertController)
        XCTAssertEqual(alert.title, RankPresenter.loadError)
        XCTAssertEqual(alert.message, loadError.localizedDescription)
        XCTAssertEqual(alert.actions.first?.title, RankPresenter.loadErrorMessageDismissAction)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(ranks: [Rank] = [], hostVC: UIViewController = UIViewControllerSpy(), file: StaticString = #filePath, line: UInt = #line) -> RankViewController {
        let sut = RankUIComposer.rankComposedWith(ranks: ranks,
                                                  alertHost: hostVC)
        
        trackForMemoryLeaks(hostVC, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assertThat(_ sut: RankViewController, isRendering records: [RecordViewModel], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedRecordViews() == records.count else {
            return XCTFail("Expected \(records.count) records, got \(sut.numberOfRenderedRecordViews()) instead.", file: file, line: line)
        }
        
        records.enumerated().forEach { index, record in
            assertThat(sut, hasViewConfiguredFor: record, at: index)
        }
    }

    private func assertThat(_ sut: RankViewController, hasViewConfiguredFor record: RecordViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let cell = sut.tableView.dataSource?.tableView(sut.tableView, cellForRowAt: IndexPath(row: index, section: 0)) as? PlayerRecordCell
        XCTAssertEqual(cell?.playerNameLabel.text, record.playerName, "Expected `name` to be \(record.playerName) for image view at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell?.guessCountLabel.text, record.guessCount, "Expected `guessCount` to be \(record.guessCount) for image view at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell?.guessTimeLabel.text, record.guessTime, "Expected `guessTime` to be \(record.guessTime) for image view at index (\(index))", file: file, line: line)
    }

    private func makeRecord(name: String, guessCount: Int, guessTime: TimeInterval) -> PlayerRecord {
        .init(playerName: name, guessCount: guessCount, guessTime: guessTime, timestamp: Date())
    }
    
    private final class RecordLoaderSpy: RecordLoader {
        var stub: [PlayerRecord]
        private let stubbedError: Error?
        private(set) var loadCallCount = 0
        
        init(stub: [PlayerRecord] = [], stubbedError: Error? = nil) {
            self.stub = stub
            self.stubbedError = stubbedError
        }
        
        func load() throws -> [PlayerRecord] {
            if let error = stubbedError {
                throw error
            }
            
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
    private func rankSelectionView() -> UISegmentedControl? {
        navigationItem.titleView as? UISegmentedControl
    }
    
    func selectionTitle(at index: Int) -> String? {
        rankSelectionView()?.titleForSegment(at: index)
    }
    
    var hasRankSelectionView: Bool {
        rankSelectionView() != nil
    }
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func numberOfRenderedRecordViews() -> Int {
        numberOfRows(in: recordsSection)
    }
    
    func simulateChangeRankSelection(to index: Int) {
        let segmentedControl = rankSelectionView()
        let currentIndex = segmentedControl?.selectedSegmentIndex
        segmentedControl?.selectedSegmentIndex = index
        if index != currentIndex {
            segmentedControl?.sendActions(for: .valueChanged)
        }
    }
    
    private var recordsSection: Int { 0 }
}

private extension PlayerRecord {
    func toModel(guessTime: String) -> RecordViewModel {
        RecordViewModel(playerName: playerName, guessCount: guessCount.description, guessTime: guessTime)
    }
}
