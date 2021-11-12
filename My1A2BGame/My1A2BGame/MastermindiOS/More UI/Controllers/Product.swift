//
//  Product.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/11/12.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

public struct Product: Hashable {
    public let name: String
    public let price: String
    
    public  init(name: String, price: String) {
        self.name = name
        self.price = price
    }
}
