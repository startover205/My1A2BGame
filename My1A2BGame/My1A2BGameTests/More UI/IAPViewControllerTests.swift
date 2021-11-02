//
//  IAPViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/27.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame

class IAPViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_configuresRestorePurchaseButton() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.restorePurchaseButton.isEnabled)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> IAPViewController {
        let sut = UIStoryboard(name: "More", bundle: .init(for: IAPViewController.self)).instantiateViewController(withIdentifier: "IAPViewController") as! IAPViewController
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
