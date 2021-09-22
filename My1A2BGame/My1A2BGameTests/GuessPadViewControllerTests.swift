//
//  GuessPadViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/9/20.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import UIKit
import MastermindiOS

class GuessPadViewControllerTests: XCTestCase {
    func test_finishInput_messagesDelegateAfterDimissal() {
        let hostViewController = UIViewControllerSpy()
        let (sut, delegate) = makeSUT(hostViewController: hostViewController)
        
        sut.simulateFinishInput()
        
        XCTAssertEqual(delegate.messageCallCount, 0)
        
        hostViewController.capturedDismissal?.completion?()
        
        XCTAssertEqual(delegate.messageCallCount, 1)
    }
    
    // MARK: Helpers
    
    private func makeSUT(hostViewController: UIViewController) -> (NumberInputViewController, GuessPadDelegateSpy) {
        let bundle = Bundle(for: NumberInputViewController.self)
        let controller = UIStoryboard(name: "Game", bundle: bundle).instantiateViewController(withIdentifier: "NumberInputViewController") as! NumberInputViewController
        let delegate = GuessPadDelegateSpy()
        controller.delegate = delegate
        let window = UIWindow()
        window.addSubview(hostViewController.view)
        
        let exp = expectation(description: "wait for presentation")
        
        hostViewController.present(controller, animated: false, completion: {
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        
        return (controller, delegate)
    }
    
    private final class UIViewControllerSpy: UIViewController {
        var capturedDismissal: (animated: Bool, completion: (() -> Void)?)?
        
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            capturedDismissal = (flag, completion)
        }
    }
    
    private final class GuessPadDelegateSpy: NumberInputViewControllerDelegate {
        private(set) var messageCallCount = 0
        
        func didFinishEntering(numberTexts: [String]) {
            messageCallCount += 1
        }
    }
}

private extension NumberInputViewController {
    func simulateFinishInput() {
        oneButton.sendActions(for: .touchUpInside)
        twoButton.sendActions(for: .touchUpInside)
        threeButton.sendActions(for: .touchUpInside)
        fourButton.sendActions(for: .touchUpInside)
    }
}
