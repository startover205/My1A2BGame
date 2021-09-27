//
//  RewardAdViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/9/27.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest

public final class RewardAdViewController {
}

class RewardAdViewControllerTests: XCTestCase {
    func test_init_doesNotMessageHostViewController() {
        let (_, hostVC) = makeSUT()
        
        XCTAssertTrue(hostVC.capturedPresentations.isEmpty)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RewardAdViewController, UIViewControllerPresentationSpy) {
        let hostVC = UIViewControllerPresentationSpy()
        let sut = RewardAdViewController()
        
        trackForMemoryLeaks(hostVC, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, hostVC)
    }
    
    private final class UIViewControllerPresentationSpy: UIViewController {
        private(set) var capturedPresentations = [(vc: UIViewController, animated: Bool)]()
        private(set) var capturedCompletions = [(() -> Void)?]()
        
        override func present(_ vc: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
            capturedPresentations.append((vc, animated))
            capturedCompletions.append(completion)
        }
    }
}
