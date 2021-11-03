//
//  IAPViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/27.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import StoreKitTest
@testable import My1A2BGame

@available(iOS 14.0, *)
class IAPViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_configuresRestorePurchaseButton() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.restorePurchaseButton.isEnabled)
    }
    
    func test_loadProductCompletion_rendersSuccessfullyLoadedProducts() throws {
        let sut = makeSUT()
        let session = try SKTestSession(configurationFileNamed: "NonConsumable")
        session.disableDialogs = true
        session.clearTransactions()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.numberOfRenderedProducts(), 0, "Expect empty list upon view load")
        
        let exp = expectation(description: "wait for product loading")
        exp.isInverted = true
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(sut.numberOfRenderedProducts(), 1, "Expect rendered products after loading")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> IAPViewController {
        let sut = UIStoryboard(name: "More", bundle: .init(for: IAPViewController.self)).instantiateViewController(withIdentifier: "IAPViewController") as! IAPViewController
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension IAPViewController {
    func numberOfRenderedProducts() -> Int {
        tableView.numberOfRows(inSection: productSection)
    }
    
    private var productSection: Int { 0 }
}
