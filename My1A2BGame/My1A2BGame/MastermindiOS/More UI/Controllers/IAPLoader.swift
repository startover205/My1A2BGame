//
//  IAPLoader.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/11/12.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import StoreKit

public final class IAPLoader: NSObject {
    private let canMakePayments: () -> Bool
    private var loadingRequest: (request: SKProductsRequest, completion: (Result<[SKProduct], Error>) -> Void)?
    
    public enum Error: Swift.Error {
        case canNotMakePayment
    }
    
    public init(canMakePayments: @escaping () -> Bool) {
        self.canMakePayments = canMakePayments
    }
    
    public func load(productIDs: [String], completion: @escaping (Result<[SKProduct], Error>) -> Void) {
        guard canMakePayments() else {
            completion(.failure(.canNotMakePayment))
            return
        }
        
        guard !productIDs.isEmpty else {
            completion(.success([]))
            return
        }
        
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        loadingRequest = (request, completion)
        
        request.start()
    }
}

extension IAPLoader: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        loadingRequest?.completion(.success(response.products))
    }
}
