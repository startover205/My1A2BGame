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
    let canMakePayments: () -> Bool
    
    enum Error: Swift.Error {
        case canNotMakePayment
    }
    
    init(canMakePayments: @escaping () -> Bool) {
        self.canMakePayments = canMakePayments
    }
    
    func load(productIDs: [String], completion: @escaping (Result<[SKProduct], Error>) -> Void) {
        guard canMakePayments() else {
            completion(.failure(.canNotMakePayment))
            return
        }
        
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

    func test_load_deliversErrorWhenCanNotMakePayments() {
        let loader = makeSUT(canMakePayments: { false })
        
        let exp = expectation(description: "wait for load")
        
        loader.load(productIDs: []) { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error, IAPLoader.Error.canNotMakePayment)
            default:
                XCTFail("Expect failure case")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers
    
    private func makeSUT(canMakePayments: @escaping () -> Bool = { true }, file: StaticString = #filePath, line: UInt = #line) -> IAPLoader {
        let sut = IAPLoader(canMakePayments: canMakePayments)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
