//
//  RewardAdViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/9/27.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import MastermindiOS
@testable import My1A2BGame

class RewardAdIntegrationTests: XCTestCase {
    
    func test_init_doesNotMessageHostViewController() {
        let (_, hostVC) = makeSUT()
        
        XCTAssertNil(hostVC.presentedViewController)
    }
    
    func test_init_requestsAdFromAdLoader() {
        let adLoader = RewardAdLoaderSpy()
        let (_, _) = makeSUT(loader: adLoader)
        
        XCTAssertEqual(adLoader.receivedMessages, [.load])
    }
    
    func test_loadAd_retriesAsyncOnLoadError() {
        let (sut, loader, asyncAfter) = makeSUT()
        _ = sut
        let loadError = anyNSError()
        
        loader.completeLoading(with: loadError, at: 0)
        XCTAssertEqual(loader.receivedMessages, [.load], "Expect no retry until async task executes")
        
        asyncAfter.completeAsyncTask(at: 0)
        XCTAssertEqual(loader.receivedMessages, [.load, .load], "Expect another load when async task executes")
    }
    
    func test_loadAd_retriesDelayExponentiallyWithJitterOnLoadError() throws {
        let (sut, loader, asyncAfter) = makeSUT()
        _ = sut
        let loadError = anyNSError()

        loader.completeLoading(with: loadError, at: 0)
        let firstDelay = Float(try XCTUnwrap(asyncAfter.capturedDelays.last))
        XCTAssertEqual(firstDelay, 2, accuracy: 1.0)

        asyncAfter.completeAsyncTask(at: 0)
        loader.completeLoading(with: loadError, at: 1)

        let secondDelay = Float(try XCTUnwrap(asyncAfter.capturedDelays.last))
        XCTAssertEqual(secondDelay, 4, accuracy: 1.0)
        
        asyncAfter.completeAsyncTask(at: 1)
        loader.completeLoading(with: loadError, at: 2)
        
        let thirdDelay = Float(try XCTUnwrap(asyncAfter.capturedDelays.last))
        XCTAssertEqual(thirdDelay, 8, accuracy: 1.0)
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

    func test_replenishChance_requestHostViewControllerToPresentAlertWithProperContentIfRewardAdAvailable() throws {
        let rewardAdLoader = RewardAdLoaderStub(ad: RewardAdSpy())
        let (sut, hostVC) = makeSUT(loader: rewardAdLoader, rewardChanceCount: 10)

        sut.replenishChance { _ in }

        let alert = try XCTUnwrap(hostVC.presentedViewController as? CountdownAlertController, "Expect alert to be desired type")
        
        alert.loadViewIfNeeded()

        XCTAssertEqual(alert.alertTitle(), RewardAdPresenter.alertTitle, "alert title")
        XCTAssertEqual(alert.alertMessage(), String.localizedStringWithFormat(RewardAdPresenter.alertMessageFormat, 10), "alert message")
        XCTAssertEqual(alert.cancelAction(), RewardAdPresenter.alertCancelTitle, "alert cancel title")
    }

    func test_replenishChance_deliversZeroOnCancelAlert() throws {
        let rewardAdLoader = RewardAdLoaderStub(ad: RewardAdSpy())
        let (sut, hostVC) = makeSUT(loader: rewardAdLoader)
        var capturedChanceCount: Int?
        
        sut.replenishChance { capturedChanceCount = $0 }

        let alert = try XCTUnwrap(hostVC.presentedViewController as? CountdownAlertController, "Expect alert to be desired type")
        alert.loadViewIfNeeded()
        alert.simulateUserDismissAlert()
        
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
    
    func test_replenishChance_doesNotRequestsAnotherAdIfUserChooseNotToReplenish() throws {
        let adLoader = RewardAdLoaderSpy()
        let ad = RewardAdSpy()
        let (sut, hostVC) = makeSUT(loader: adLoader)
        adLoader.completeLoading(with: ad)
        
        sut.replenishChance(completion: { _ in })
        XCTAssertEqual(adLoader.receivedMessages, [.load], "precondition")
        
        try hostVC.simulateCancelDisplayingAd()
        XCTAssertEqual(adLoader.receivedMessages, [.load], "Expect no new load request when loaded ad not used")
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
    
    func test_replenishChance_dismissAdAlertAfterCountdownTimePasses() throws {
        let asyncWorker = AsyncAfterSpy()
        let (sut, hostVC) = makeSUT(loader: RewardAdLoaderStub(ad: RewardAdSpy()), asyncAfter: asyncWorker.asyncAfter)

        sut.replenishChance(completion: { _ in })

        let alert = try XCTUnwrap(hostVC.presentedViewController as? CountdownAlertController)
        alert.simulateViewAppear()
        
        asyncWorker.completeAsyncTask()
        
        XCTAssertNil(hostVC.presentedViewController)
    }
    
    func test_replenishChance_dismissAdAlertAfterConfirmShowingAd() throws {
        let (sut, hostVC) = makeSUT(loader: RewardAdLoaderStub(ad: RewardAdSpy()))

        sut.replenishChance(completion: { _ in })
        
        try hostVC.simulateConfirmDisplayingAd()

        XCTAssertNil(hostVC.presentedViewController)
    }
    
    func test_replenishChance_dismissAdAlertAfterCancelShowingAd() throws {
        let (sut, hostVC) = makeSUT(loader: RewardAdLoaderStub(ad: RewardAdSpy()))

        sut.replenishChance(completion: { _ in })
        
        try hostVC.simulateCancelDisplayingAd()

        XCTAssertNil(hostVC.presentedViewController)
    }

    func test_displayAd_doesNotDeallocateAdUntilAdRewardGiven() throws {
        let adLoader = RewardAdLoaderSpy()
        var ad: RewardAdSpy? = RewardAdSpy()
        var (sut, hostVC): (RewardAdViewController?, UIViewControllerSpy?)
        weak var weakAd = ad
        
        try autoreleasepool {
            (sut, hostVC) = makeSUT(loader: adLoader)
            adLoader.completeLoading(with: ad!, at: 0)
            ad = nil

            sut?.replenishChance(completion: { _ in })
            try hostVC?.simulateConfirmDisplayingAd()
            adLoader.completeLoading(with: RewardAdSpy(), at: 1)
            XCTAssertNotNil(weakAd, "Expect ad not deallocated because the reward has not yet been given")

            weakAd?.completeGivingReward()
        }
      
        XCTAssertNil(weakAd, "Expect ad deallocated now the ad has been displayed and the reward has been given")
    }
    
    // MARK: Helpers
    
    private func makeSUT(loader: RewardAdLoader = RewardAdLoaderStub.null, rewardChanceCount: Int = 0, asyncAfter: @escaping AsyncAfter = { _, _ in }, file: StaticString = #filePath, line: UInt = #line) -> (RewardAdViewController, UIViewControllerSpy) {
        let hostVC = UIViewControllerSpy()
        let sut = RewardAdControllerComposer.rewardAdComposedWith(
            loader: loader,
            rewardChanceCount: rewardChanceCount,
            hostViewController: hostVC,
            asyncAfter: asyncAfter)
        
        trackForMemoryLeaks(hostVC, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        if let loader = loader as? RewardAdLoaderStub {
            trackForMemoryLeaks(loader, file: file, line: line)
        }
        
        return (sut, hostVC)
    }
    
    private func makeSUT(rewardChanceCount: Int = 0, file: StaticString = #filePath, line: UInt = #line) -> (RewardAdViewController, RewardAdLoaderSpy, AsyncAfterSpy) {
        let loader = RewardAdLoaderSpy()
        let asyncAfterSpy = AsyncAfterSpy()
        let sut = RewardAdControllerComposer.rewardAdComposedWith(
            loader: loader,
            rewardChanceCount: rewardChanceCount,
            hostViewController: UIViewController(),
            asyncAfter: asyncAfterSpy.asyncAfter)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(asyncAfterSpy, file: file, line: line)
        
        return (sut, loader, asyncAfterSpy)
    }
    
    private class UIViewControllerSpy: UIViewController {
        private var capturedPresentedViewController: UIViewController?

        override var presentedViewController: UIViewController? {
            return capturedPresentedViewController
        }

        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            capturedPresentedViewController = viewControllerToPresent
            completion?()
        }
        
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            capturedPresentedViewController = nil
            completion?()
        }
        
        func simulateConfirmDisplayingAd(file: StaticString = #filePath, line: UInt = #line) throws {
            let alert = try XCTUnwrap(capturedPresentedViewController as? CountdownAlertController, "Expect alert to be the desired type", file: file, line: line)
            alert.loadViewIfNeeded()
            alert.simulateUserConfirmDisplayingAd()
        }
        
        func simulateCancelDisplayingAd(file: StaticString = #filePath, line: UInt = #line) throws {
            let alert = try XCTUnwrap(capturedPresentedViewController as? CountdownAlertController, "Expect alert to be the desired type", file: file, line: line)
            alert.loadViewIfNeeded()
            alert.simulateUserDismissAlert()
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
        
        func completeLoading(with error: Error, at index: Int = 0) {
            capturedCompletions[index](.failure(error))
        }
    }
    
    private final class RewardAdSpy: RewardAd {
        let id = UUID()
        
        private(set) var capturedPresentations = [(vc: UIViewController, handler: () -> Void)]()

        func present(fromRootViewController rootViewController: UIViewController, userDidEarnRewardHandler: @escaping () -> Void) {
            capturedPresentations.append((rootViewController, userDidEarnRewardHandler))
        }
        
        func completeGivingReward() {
            capturedPresentations.last?.handler()
        }
    }
    
    private final class AsyncAfterSpy {
        private(set) var capturedDelays = [TimeInterval]()
        private(set) var capturedTasks = [() -> Void]()
        
        func asyncAfter(delay: TimeInterval, task: @escaping () -> Void) {
            capturedDelays.append(delay)
            capturedTasks.append(task)
        }
        
        func completeAsyncTask(at index: Int = 0) {
            capturedTasks[index]()
        }
    }
}
