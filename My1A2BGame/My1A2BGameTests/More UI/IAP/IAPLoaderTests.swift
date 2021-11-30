//
//  IAPLoaderTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/12.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKitTest
import My1A2BGame

class IAPLoaderTests: XCTestCase {
    
    func test_load_deliversEmptyResultOnEmptyProductIDs() {
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for load")
        
        sut.load(productIDs: []) { products in
            XCTAssertTrue(products.isEmpty)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    @available(iOS 14.0, *)
    func test_load_deliversProductsOnLoadingSuccesfully() throws {
        let sut = makeSUT()
        try createLocalTestSession()
        
        let exp = expectation(description: "wait for load")
        
        sut.load(productIDs: allProductIDs()) { products in
            XCTAssertEqual(Set(products.model()), Set(allProducts()))
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> IAPProductLoader {
        let sut = IAPProductLoader()
        
        return sut
    }
}

private func allProductIDs() -> [String] {
    ["remove_bottom_ad"]
}

private func allProducts() -> [My1A2BGame.Product] {
    [.init(name: "Remove Bottom Ad", price: "$0.99")]
}

private extension Array where Element == SKProduct {
    func model() -> [My1A2BGame.Product] {
        map { Product(name: $0.localizedTitle, price: $0.localizedPrice) }
    }
}

private extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
