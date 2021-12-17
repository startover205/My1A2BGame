//
//  ProductLoaderTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/12/17.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKit
import My1A2BGame

class ProductLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestProduct() {
        let _ = makeSUT(makeRequest: { _ in
            XCTFail("Should not make request upon creation")
            return SKProductsRequest()
        })
    }
    
    func test_load_doesNotRequestProductOnEmptyProductIDs() {
        let sut = makeSUT(
            makeRequest: { _ in
                XCTFail("Should not make request when productIDs are empty")
                return SKProductsRequest()
            },
            getProductIDs: { [] })
        
        sut.load { _ in }
    }
    
    func test_load_deliversEmptyResultOnEmptyProductIDs() {
        let sut = makeSUT(getProductIDs: { [] })
        let exp = expectation(description: "wait for request")
        
        var result = [SKProduct]()
        sut.load { product in
            result.append(contentsOf: product)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        XCTAssertTrue(result.isEmpty)
    }
    
    @available(iOS 14.0, *)
    func test_load_deliversEmptyResultOnInvalidProductIDs() throws {
        try createLocalTestSession()
        let sut = makeSUT(getProductIDs: { ["an invalid ID", "another invalid ID"] })
        let exp = expectation(description: "wait for request")
        
        var result = [SKProduct]()
        sut.load { product in
            result.append(contentsOf: product)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        XCTAssertTrue(result.isEmpty)
        
        waitForRefereceRemoval()
    }
    
    func test_load_requestProductOnNonEmptyProductIDs() throws {
        var capturedProductIDs: Set<String>?
        let productIDs: Set<String> = ["an ID", "another ID"]
        let sut = makeSUT(makeRequest: {
            capturedProductIDs = $0
            return SKProductsRequest()
        }, getProductIDs: { productIDs })
        
        sut.load { _ in }
        
        XCTAssertEqual(capturedProductIDs, productIDs)
    }
    
    @available(iOS 14.0, *)
    func test_load_deliversOnlyValidProductsOnNonEmptyProductIDs() throws {
        let sut = makeSUT(makeRequest: SKProductsRequest.init, getProductIDs: { [validProductID(), "an invalid ID"] })
        try createLocalTestSession()
        let exp = expectation(description: "wait for request")
        
        var result = [SKProduct]()
        sut.load {
            result.append(contentsOf: $0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(result.count, 1, "count")
        XCTAssertEqual(result.first?.productIdentifier, validProductID(), "product ID")
        
        waitForRefereceRemoval()
    }
    
    @available(iOS 14.0, *)
    func test_loadTwice_deliversOnlyLatestResult() throws {
        var isFirstTime = true
        let getProductIDs: () -> Set<String> = {
            if isFirstTime {
                isFirstTime = false
                return [validProductID()]
            } else {
                return ["an invalid ID"]
            }
        }
        let sut = makeSUT(makeRequest: SKProductsRequest.init, getProductIDs: getProductIDs)
        try createLocalTestSession()
        let exp = expectation(description: "wait for request")
        
        var result = [SKProduct]()
        sut.load { _ in
            XCTFail("Expect the first call not responded")
        }
        sut.load {
            result.append(contentsOf: $0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertTrue(result.isEmpty)
        
        waitForRefereceRemoval()
    }
    
    // MARK: - Helpers
    
    private func makeSUT(makeRequest: @escaping (Set<String>) -> SKProductsRequest = { _ in SKProductsRequest() }, getProductIDs: @escaping () ->  Set<String> = { [] }, file: StaticString = #filePath, line: UInt = #line) -> ProductLoader {
        let sut = ProductLoader(makeRequest: makeRequest, getProductIDs: getProductIDs)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func waitForRefereceRemoval() {
        let exp = expectation(description: "wait for reference removal")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.01)
    }
}

private func validProductID() -> String { "remove_bottom_ad" }
