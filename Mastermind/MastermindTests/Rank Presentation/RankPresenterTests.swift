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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RankPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = RankPresenter(rankView: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
 
    private final class ViewSpy: RankView {
        enum Message: Hashable {
            case display(records: [PlayerRecord])
        }
        
        private(set) var receivedMessages = Set<Message>()
        
        func display(_ viewModel: RankViewModel) {
            receivedMessages.insert(.display(records: viewModel.records))
        }
    }
}
