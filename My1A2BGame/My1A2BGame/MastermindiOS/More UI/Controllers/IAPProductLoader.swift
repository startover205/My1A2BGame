//
//  IAPProductLoader.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/11/12.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import StoreKit

public class IAPProductLoader: NSObject {
    private var loadingRequest: (request: SKProductsRequest, completion: ([SKProduct]) -> Void)?
    
    public func load(productIDs: [String], completion: @escaping ([SKProduct]) -> Void) {
        guard !productIDs.isEmpty else {
            completion([])
            return
        }
        
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        loadingRequest = (request, completion)
        
        request.start()
    }
}

extension IAPProductLoader: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        loadingRequest?.completion(response.products)
    }
}
