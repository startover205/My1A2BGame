//
//  RewardAdViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/9/27.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import MastermindiOS
import My1A2BGame

class RewardAdViewControllerTests: XCTestCase {
    func test_init_doesNotMessageHostViewController() {
        let (_, hostVC) = makeSUT()
        
        XCTAssertTrue(hostVC.capturedPresentations.isEmpty)
    }
    
    func test_init_requestsAdFromAdLoader() {
        let adLoader = RewardAdLoaderSpy()
        let (_, _) = makeSUT(loader: adLoader)
        
        XCTAssertEqual(adLoader.receivedMessages, [.load])
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

    func test_replenishChance_requestHostViewControllerToPresentAlertWithProperContentAnimatedlyIfRewardAdAvailable() throws {
        let rewardAdLoader = RewardAdLoaderStub(ad: RewardAdSpy())
        let (sut, hostVC) = makeSUT(loader: rewardAdLoader, rewardChanceCount: 10)

        sut.replenishChance { _ in }

        XCTAssertEqual(hostVC.capturedPresentations.count, 1, "Expect exactly one presentation")
        XCTAssertEqual(hostVC.capturedPresentations.first?.animated, true, "Expect presenation is animated")
        let alert = try XCTUnwrap(hostVC.capturedPresentations.first?.vc as? AlertAdCountdownController, "Expect alert to be desired type")

        XCTAssertEqual(alert.alertTitle, RewardAdPresenter.alertTitle, "alert title")
        XCTAssertEqual(alert.message, String.localizedStringWithFormat(RewardAdPresenter.alertMessageFormat, 10), "alert message")
        XCTAssertEqual(alert.cancelMessage, RewardAdPresenter.alertCancelTitle, "alert cancel title")
        XCTAssertEqual(alert.countDownTime, RewardAdPresenter.alertCountDownTime, "alert count down time")
    }

    func test_replenishChance_deliversZeroOnCancelAlert() throws {
        let rewardAdLoader = RewardAdLoaderStub(ad: RewardAdSpy())
        let (sut, hostVC) = makeSUT(loader: rewardAdLoader)
        var capturedChanceCount: Int?
        
        sut.replenishChance { capturedChanceCount = $0 }

        let alert = try XCTUnwrap(hostVC.capturedPresentations.first?.vc as? AlertAdCountdownController, "Expect alert to be desired type")
        alert.cancelHandler?()
        
        XCTAssertEqual(capturedChanceCount, 0, "captureed chance count")
    }
    
    func test_replenishChance_displaysRewardAdAndReplenishOnDisplayCompletionWhenUserConfirmsAlert() throws {
        let ad = RewardAdSpy()
        let rewardAdLoader = RewardAdLoaderStub(ad: ad)
        let (sut, hostVC) = makeSUT(loader: rewardAdLoader, rewardChanceCount: 5)
        var capturedChanceCount: Int?
        
        sut.replenishChance { capturedChanceCount = $0 }
        XCTAssertTrue(ad.capturedPresentations.isEmpty, "Expect ad presententation not used before comfirm alert")
        
        try hostVC.simulateConfirmDisplayingAd()
        XCTAssertEqual(ad.capturedPresentations.first?.vc, hostVC, "Expect ad presents using host view controller")
        XCTAssertNil(capturedChanceCount, "Expect replenish completion not called before ad presentation completes")
        
        ad.capturedPresentations.first?.handler()
        
        XCTAssertEqual(capturedChanceCount, 5, "Expect replenishing after ad presentation completes")
    }
    
    func test_replenishChance_requestsAnotherAdAfterAdPresentation() throws {
        let adLoader = RewardAdLoaderSpy()
        let ad = RewardAdSpy()
        let (sut, hostVC) = makeSUT(loader: adLoader)
        adLoader.completeLoading(with: ad)
        
        sut.replenishChance(completion: { _ in })
        XCTAssertEqual(adLoader.receivedMessages, [.load], "precondition")
        
        try hostVC.simulateConfirmDisplayingAd()
        XCTAssertEqual(adLoader.receivedMessages, [.load, .load])
    }
    
    func test_replenishChanceTwice_displayesTheLatestLoadedAdForEachTime() throws {
        let adLoader = RewardAdLoaderSpy()
        let ad1 = RewardAdSpy()
        let ad2 = RewardAdSpy()
        let (sut, hostVC) = makeSUT(loader: adLoader)
        adLoader.completeLoading(with: ad1, at: 0)
        
        sut.replenishChance(completion: { _ in })
        try hostVC.simulateConfirmDisplayingAd()
        XCTAssertEqual(ad1.capturedPresentations.count, 1, "Expect presenting the first loaded ad")
        XCTAssertEqual(ad2.capturedPresentations.count, 0, "Expect ad not presented because it's not loaded yet")
        
        adLoader.completeLoading(with: ad2, at: 1)

        sut.replenishChance(completion: { _ in })
        try hostVC.simulateConfirmDisplayingAd()
        XCTAssertEqual(ad1.capturedPresentations.count, 1, "Expect presentation count not increased since it's already presented")
        XCTAssertEqual(ad2.capturedPresentations.count, 1, "Expect presenting the second loaded ad")
    }

    func test_displayAd_doesNotDeallocateAdUntilAdRewardGiven() throws {
        let adLoader = RewardAdLoaderSpy()
        var ad: RewardAdSpy? = RewardAdSpy()
        let (sut, hostVC) = makeSUT(loader: adLoader)
        adLoader.completeLoading(with: ad!, at: 0)
        weak var weakAd = ad
        ad = nil

        sut.replenishChance(completion: { _ in })
        try hostVC.simulateConfirmDisplayingAd()
        adLoader.completeLoading(with: RewardAdSpy(), at: 1)
        XCTAssertNotNil(weakAd, "Expect ad not deallocated because the reward has not yet been given")

        weakAd?.completeGivingReward()
        XCTAssertNil(weakAd, "Expect ad deallocated now the ad has been displayed and the reward has been given")
    }
    
    // MARK: Helpers
    
    private func makeSUT(loader: RewardAdLoader = RewardAdLoaderStub.null, rewardChanceCount: Int = 0, file: StaticString = #filePath, line: UInt = #line) -> (RewardAdViewController, UIViewControllerPresentationSpy) {
        let hostVC = UIViewControllerPresentationSpy()
        let sut = RewardAdViewController(loader: loader, rewardChanceCount: rewardChanceCount, hostViewController: hostVC)
        
        trackForMemoryLeaks(hostVC, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        if let loader = loader as? RewardAdLoaderStub {
            trackForMemoryLeaks(loader, file: file, line: line)
        }
        
        return (sut, hostVC)
    }
    
    private final class UIViewControllerPresentationSpy: UIViewController {
        private(set) var capturedPresentations = [(vc: UIViewController, animated: Bool)]()
        private(set) var capturedCompletions = [(() -> Void)?]()
        
        override func present(_ vc: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
            capturedPresentations.append((vc, animated))
            capturedCompletions.append(completion)
        }
        
        func simulateConfirmDisplayingAd(file: StaticString = #filePath, line: UInt = #line) throws {
            let alert = try XCTUnwrap(capturedPresentations.removeLast().vc as? AlertAdCountdownController, "Expect alert to be the desired type", file: file, line: line)
            
            alert.confirmHandler?()
        }
    }
    
    private final class RewardAdLoaderSpy: RewardAdLoader {
        enum Message: Equatable {
            case load
        }
        
        private(set) var receivedMessages = [Message]()
        private(set) var capturedCompletions = [(RewardAdLoader.Result) -> Void]()
        
        func load(completion: @escaping (RewardAdLoader.Result) -> Void) {
            receivedMessages.append(.load)
            capturedCompletions.append(completion)
        }
        
        func completeLoading(with ad: RewardAd, at index: Int = 0) {
            capturedCompletions[index](.success(ad))
        }
    }
    
    private final class RewardAdSpy: RewardAd {
        private(set) var capturedPresentations = [(vc: UIViewController, handler: () -> Void)]()

        func present(fromRootViewController rootViewController: UIViewController, userDidEarnRewardHandler: @escaping () -> Void) {
            capturedPresentations.append((rootViewController, userDidEarnRewardHandler))
        }
        
        func completeGivingReward() {
            capturedPresentations.last?.handler()
        }
    }
}
