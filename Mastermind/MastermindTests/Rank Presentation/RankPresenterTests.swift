//
//  RankPresenterTests.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/10/7.
//

import XCTest
import Mastermind

public final class RankPresenter {
    let view: Any
    
    init(view: Any) {
        self.view = view
    }
}

class RankPresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.receivedMessages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RankPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = RankPresenter(view: view)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
 
    private final class ViewSpy {
        enum Message: Hashable {
            
        }
        
        private(set) var receivedMessages = Set<Message>()
    }
}
