//
//  IAPLoaderTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/12.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKit
import StoreKitTest

final class IAPLoader: NSObject {
    private let canMakePayments: () -> Bool
    private var loadingRequest: (request: SKProductsRequest, completion:  (Result<[Product], Error>) -> Void)?
    
    enum Error: Swift.Error {
        case canNotMakePayment
    }
    
    init(canMakePayments: @escaping () -> Bool) {
        self.canMakePayments = canMakePayments
    }
    
    func load(productIDs: [String], completion: @escaping (Result<[Product], Error>) -> Void) {
        guard canMakePayments() else {
            completion(.failure(.canNotMakePayment))
            return
        }
        
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        loadingRequest = (request, completion)
        
        request.start()
    }
}

extension IAPLoader: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        loadingRequest?.completion(.success(response.products.model()))
    }
}

private extension Array where Element == SKProduct {
    func model() -> [Product] {
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
    
    @available(iOS 14.0, *)
    func test_load_deliversProductsOnLoadingSuccesfully() throws {
        let loader = makeSUT()
        let session = try SKTestSession(configurationFileNamed: "NonConsumable")
        session.disableDialogs = true
        session.clearTransactions()
        
        let exp = expectation(description: "wait for load")
        
        loader.load(productIDs: allProductIDs()) { result in
            switch result {
            case let .success(products):
                XCTAssertEqual(Set(products), Set(allProducts()))
            default:
                XCTFail("Expect success case")
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

private func allProductIDs() -> [String] {
    ["remove_bottom_ad"]
}

private func allProducts() -> [Product] {
    [.init(name: "Remove Bottom Ad", price: "$0.99")]
}
