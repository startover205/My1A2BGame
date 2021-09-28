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

public final class RewardAdViewController {
    private let loader: RewardAdLoader
    private weak var hostViewController: UIViewController?
    
    init(loader: RewardAdLoader, hostViewController: UIViewController) {
        self.loader = loader
        self.hostViewController = hostViewController
    }
    
    func replenishChance(completion: @escaping (Int) -> Void) {
        guard let _ = loader.rewardAd, let hostVC = hostViewController else { return completion(0) }

        let alert = AlertAdCountdownController(
            title: RewardAdPresenter.alertTitle,
            message: RewardAdPresenter.alertMessage,
            cancelMessage: RewardAdPresenter.alertCancelTitle,
            countDownTime: RewardAdPresenter.alertCountDownTime,
            adHandler: nil,
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
        let rewardAdLoader = RewardAdLoaderStub(ad: RewardAdFake())
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
        let rewardAdLoader = RewardAdLoaderStub(ad: RewardAdFake())
        let (sut, hostVC) = makeSUT(loader: rewardAdLoader)
        var capturedChanceCount: Int?
        
        sut.replenishChance { capturedChanceCount = $0 }

        let alert = try? XCTUnwrap(hostVC.capturedPresentations.first?.vc as? AlertAdCountdownController, "Expect alert to be desired type")
        alert?.cancelHandler?()
        
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
    
    private final class RewardAdFake: RewardAd {
        func present(fromRootViewController rootViewController: UIViewController, userDidEarnRewardHandler: @escaping () -> Void) {
        }
    }
}
