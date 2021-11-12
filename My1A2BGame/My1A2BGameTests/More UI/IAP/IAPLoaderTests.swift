//
//  IAPLoaderTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/12.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKit

final class IAPLoader {
    func load(productIDs: [String], completion: @escaping (Result<[SKProduct], Error>) -> Void) {
        completion(.success([]))
    }
}

class IAPLoaderTests: XCTestCase {
    
    func test_load_deliversEmptyResultOnEmptyProductIDs() {
        let loader = makeSUT()
        
        let exp = expectation(description: "wait for load")
        
        loader.load(productIDs: []) { result in
            switch result {
            case let .success(products):
                XCTAssertTrue(products.isEmpty)
            default:
                XCTFail("Expect success case")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> IAPLoader {
        let sut = IAPLoader()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
