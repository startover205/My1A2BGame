//
//  RewardAdViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/9/27.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import MastermindiOS

public final class RewardAdViewController {
    private let loader: RewardAdLoader
    private weak var hostViewController: UIViewController?
    
    init(loader: RewardAdLoader, hostViewController: UIViewController) {
        self.loader = loader
        self.hostViewController = hostViewController
    }
    
    func replenishChance(completion: @escaping (Int) -> Void) {
        completion(0)
    }
}

class RewardAdViewControllerTests: XCTestCase {
    func test_init_doesNotMessageHostViewController() {
        let (_, hostVC) = makeSUT()
        
        XCTAssertTrue(hostVC.capturedPresentations.isEmpty)
    }
    
    func test_replenishChance_deliversZeroIfHostVCIsNil() {
        let (sut, _) = makeSUT()
        var capturedChanceCount: Int?
        
        sut.replenishChance { capturedChanceCount = $0 }
        
        XCTAssertEqual(capturedChanceCount, 0)
    }
    
    func test_replenishChance_deliversZeroIfRewardAdUnavailable() {
        let rewardAdLoader = RewardAdLoaderStub(ad: nil)
        let (sut, _) = makeSUT(loader: rewardAdLoader)
        var capturedChanceCount: Int?
        
        sut.replenishChance { capturedChanceCount = $0 }
        
        XCTAssertEqual(capturedChanceCount, 0)
    }
    
    // MARK: Helpers
    
    private func makeSUT(loader: RewardAdLoader = RewardAdLoaderStub.null, file: StaticString = #filePath, line: UInt = #line) -> (RewardAdViewController, UIViewControllerPresentationSpy) {
        let hostVC = UIViewControllerPresentationSpy()
        let sut = RewardAdViewController(loader: loader, hostViewController: hostVC)
        
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
