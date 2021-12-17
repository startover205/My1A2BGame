//
//  ProductLoader.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/12/17.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import StoreKit

public class ProductLoader: NSObject {
    private let makeRequest: (Set<String>) -> SKProductsRequest
    private let getProductIDs: () -> Set<String>
    private var loadingRequest: (request: SKProductsRequest, completion: ([SKProduct]) -> Void)?
    
    public init(makeRequest: @escaping (Set<String>) -> SKProductsRequest, getProductIDs: @escaping () -> Set<String>) {
        self.makeRequest = makeRequest
        self.getProductIDs = getProductIDs
    }
    
    public func load(completion: @escaping ([SKProduct]) -> Void) {
        let productIDs = getProductIDs()
        guard !productIDs.isEmpty else {
            completion([])
            return
        }
        
        let request = makeRequest(productIDs)
        request.delegate = self
        loadingRequest = (request, completion)
        
        request.start()
    }
}

extension ProductLoader: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        loadingRequest?.completion(response.products)
    }
}
