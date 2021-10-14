//
//  RankPresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/10/7.
//

import XCTest
import Mastermind

class RankPresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.receivedMessages.isEmpty)
    }
    
    func test_didLoadRecords_displaysRecords() {
        let records = [anyPlayerRecord().model, anyPlayerRecord().model]
        let (sut, view) = makeSUT()
        
        sut.didLoad(records)
        
        XCTAssertEqual(view.receivedMessages, [.display(records: records)])
    }
    
    func test_didLoadWithError_displaysErrorMessage() {
        let error = anyNSError()
        let (sut, view) = makeSUT()
        
        sut.didLoad(with: error)
        
        XCTAssertEqual(view.receivedMessages, [.display(errorMessage: localized("LOAD_ERROR"), errorDescription: error.localizedDescription)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RankPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = RankPresenter(rankView: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Rank"
        let bundle = Bundle(for: RankPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
 
    private final class ViewSpy: RankView {
        enum Message: Hashable {
            case display(records: [PlayerRecord])
            case display(errorMessage: String, errorDescription: String)
        }
        
        private(set) var receivedMessages = Set<Message>()
        
        func display(_ viewModel: RankViewModel) {
            receivedMessages.insert(.display(records: viewModel.records))
        }
        
        func display(_ viewModel: LoadRankErrorViewModel) {
            receivedMessages.insert(.display(errorMessage: viewModel.message, errorDescription: viewModel.description))
        }
    }
}
