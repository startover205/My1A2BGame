//
//  XCTestCase+IAPTestHelpers.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/11/18.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKitTest

@available(iOS 14.0, *)
extension XCTestCase {
    @discardableResult
    func createLocalTestSession(_ configurationFileNamed: String = "NonConsumable") throws -> SKTestSession {
        let session = try SKTestSession(configurationFileNamed: configurationFileNamed)
        session.disableDialogs = true
        session.clearTransactions()
        
        return session
    }
}
