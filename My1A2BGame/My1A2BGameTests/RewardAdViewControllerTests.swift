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

final class RewardAdPresenter {
    private init() {}
    
    public static var alertTitle: String {
        NSLocalizedString("ALERT_TITLE",
                          tableName: "RewardAd",
                          bundle: Bundle(for: RewardAdPresenter.self),
                          comment: "Title for reward ad alert")
    }
    
    public static var alertMessage: String {
        NSLocalizedString("ALERT_Message",
                          tableName: "RewardAd",
                          bundle: Bundle(for: RewardAdPresenter.self),
                          comment: "Message for reward ad alert")
    }
    
    public static var alertCancelTitle: String {
        NSLocalizedString("ALERT_CANCEL_TITLE",
                          tableName: "RewardAd",
                          bundle: Bundle(for: RewardAdPresenter.self),
                          comment: "Cancel title for reward ad alert")
    }
    
    public static var alertCountDownTime: TimeInterval { 5.0 }
}

public final class RewardAdViewController: ReplenishChanceDelegate {
    private let loader: RewardAdLoader
    private let rewardChanceCount: Int
    private weak var hostViewController: UIViewController?
    
    init(loader: RewardAdLoader, rewardChanceCount: Int, hostViewController: UIViewController) {
        self.loader = loader
        self.rewardChanceCount = rewardChanceCount
        self.hostViewController = hostViewController
    }
    
    public func replenishChance(completion: @escaping (Int) -> Void) {
        guard let ad = loader.rewardAd, let hostVC = hostViewController else { return completion(0) }
        
        let rewardChanceCount = rewardChanceCount

        let alert = AlertAdCountdownController(
            title: RewardAdPresenter.alertTitle,
            message: RewardAdPresenter.alertMessage,
            cancelMessage: RewardAdPresenter.alertCancelTitle,
            countDownTime: RewardAdPresenter.alertCountDownTime,
            confirmHandler: { [weak hostVC] in
                guard let hostVC = hostVC else { return }
                
                ad.present(fromRootViewController: hostVC) {
                    completion(rewardChanceCount)
                }
            },
            cancelHandler: { completion(0) })
        
        hostVC.present(alert, animated: true)
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

    func test_replenishChance_requestHostViewControllerToPresentAlertWithProperContentAnimatedlyIfRewardAdAvailable() {
        let rewardAdLoader = RewardAdLoaderStub(ad: RewardAdSpy())
        let (sut, hostVC) = makeSUT(loader: rewardAdLoader)

        sut.replenishChance { _ in }

        XCTAssertEqual(hostVC.capturedPresentations.count, 1, "Expect exactly one presentation")
        XCTAssertEqual(hostVC.capturedPresentations.first?.animated, true, "Expect presenation is animated")
        let alert = try? XCTUnwrap(hostVC.capturedPresentations.first?.vc as? AlertAdCountdownController, "Expect alert to be desired type")
        
        XCTAssertEqual(alert?.alertTitle, RewardAdPresenter.alertTitle)
        XCTAssertEqual(alert?.message, RewardAdPresenter.alertMessage)
        XCTAssertEqual(alert?.cancelMessage, RewardAdPresenter.alertCancelTitle)
        XCTAssertEqual(alert?.countDownTime, RewardAdPresenter.alertCountDownTime)
    }

    func test_replenishChance_deliversZeroOnCancelAlert() {
        let rewardAdLoader = RewardAdLoaderStub(ad: RewardAdSpy())
        let (sut, hostVC) = makeSUT(loader: rewardAdLoader)
        var capturedChanceCount: Int?
        
        sut.replenishChance { capturedChanceCount = $0 }

        let alert = try? XCTUnwrap(hostVC.capturedPresentations.first?.vc as? AlertAdCountdownController, "Expect alert to be desired type")
        alert?.cancelHandler?()
        
        XCTAssertEqual(capturedChanceCount, 0)
    }
    
    func test_replenishChance_displaysRewardAdAndReplenishOnDisplayCompletionWhenUserConfirmsAlert() {
        let ad = RewardAdSpy()
        let rewardAdLoader = RewardAdLoaderStub(ad: ad)
        let (sut, hostVC) = makeSUT(loader: rewardAdLoader, rewardChanceCount: 5)
        var capturedChanceCount: Int?
        
        sut.replenishChance { capturedChanceCount = $0 }

        let alert = try? XCTUnwrap(hostVC.capturedPresentations.first?.vc as? AlertAdCountdownController, "Expect alert to be desired type")
        
        XCTAssertTrue(ad.capturedPresentations.isEmpty, "Expect ad presententation not used before comfirm alert")
        alert?.confirmHandler?()
        
        XCTAssertEqual(ad.capturedPresentations.first?.vc, hostVC, "Expect ad presents using host view controller")
        XCTAssertNil(capturedChanceCount, "Expect replenish completion not called before ad presentation completes")
        
        ad.capturedPresentations.first?.handler()
        
        XCTAssertEqual(capturedChanceCount, 5, "Expect replenishing after ad presentation completes")
        
        ad.clearCapturedInstances()
    }
    
    // MARK: Helpers
    
    private func makeSUT(loader: RewardAdLoaderStub = .null, rewardChanceCount: Int = 0, file: StaticString = #filePath, line: UInt = #line) -> (RewardAdViewController, UIViewControllerPresentationSpy) {
        let hostVC = UIViewControllerPresentationSpy()
        let sut = RewardAdViewController(loader: loader, rewardChanceCount: rewardChanceCount, hostViewController: hostVC)
        
        trackForMemoryLeaks(hostVC, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
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
    
    private final class RewardAdSpy: RewardAd {
        private(set) var capturedPresentations = [(vc: UIViewController, handler: () -> Void)]()

        func present(fromRootViewController rootViewController: UIViewController, userDidEarnRewardHandler: @escaping () -> Void) {
            capturedPresentations.append((rootViewController, userDidEarnRewardHandler))
        }
        
        func clearCapturedInstances() {
            capturedPresentations.removeAll()
        }
    }
}
