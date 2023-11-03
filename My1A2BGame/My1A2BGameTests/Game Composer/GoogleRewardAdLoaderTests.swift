//
//  GoogleRewardAdLoaderTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2022/1/4.
//  Copyright © 2022 Ming-Ta Yang. All rights reserved.
//

import XCTest
import GoogleMobileAds
import My1A2BGame
import MastermindiOS

class GoogleRewardAdLoaderTests: XCTestCase {
    
    func test_load_deliversFailureOnLoadError() {
        let sut = makeSUT()
        let spy = GADRewardedAd.loadingSpy()
        spy.startIntercepting()
        let exp = expectation(description: "wait for loading")
        
        sut.load() { result in
            switch result {
            case .failure:
                break
            case .success:
                XCTFail("Expect failure case")
            }
            exp.fulfill()
        }
        spy.completeLoadingWithError()

        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversFailureOnEmptyAdWithNoError() {
        let sut = makeSUT()
        let spy = GADRewardedAd.loadingSpy()
        spy.startIntercepting()
        let exp = expectation(description: "wait for loading")
        
        sut.load() { result in
            switch result {
            case .failure:
                break
            case .success:
                XCTFail("Expect failure case")
            }
            exp.fulfill()
        }
        spy.completeLoadingWithEmptyAd()

        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversFailureIfCanNotLoadAd() {
        let sut = makeSUT(canLoadAd: { false })
        let spy = GADRewardedAd.loadingSpy()
        spy.startIntercepting()
        let exp = expectation(description: "wait for loading")
        
        sut.load() { result in
            switch result {
            case .failure:
                break
            case .success:
                XCTFail("Expect failure case")
            }
            exp.fulfill()
        }
        spy.completeLoadingWithEmptyAd()

        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversAdOnSuccessfulLoading() {
        let adUnitID = testUnitID()
        let sut = makeSUT(adUnitID: adUnitID)
        let spy = GADRewardedAd.loadingSpy()
        spy.startIntercepting()
        let exp = expectation(description: "wait for loading")
        
        sut.load() { result in
            switch result {
            case let .success(ad as GADRewardedAd):
                XCTAssertEqual(ad.adUnitID, adUnitID)
            default:
                XCTFail("Expect successful case returing a GADRewardedAd instance, got \(result) instead")
            }
            exp.fulfill()
        }
        spy.completeLoadingWithAd(adUnitID: adUnitID)

        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        var sut: GoogleRewardAdLoader? = makeSUT()
        let spy = GADRewardedAd.loadingSpy()
        spy.startIntercepting()
        var capturedResult: RewardAdLoader.Result?
        
        sut?.load() { capturedResult = $0 }
        
        sut = nil
        spy.completeLoadingWithError()
        
        XCTAssertNil(capturedResult)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(adUnitID: String = "", canLoadAd: @escaping () -> Bool = { true }, file: StaticString = #filePath, line: UInt = #line) -> GoogleRewardAdLoader {
        let sut = GoogleRewardAdLoader(adUnitID: adUnitID, canLoadAd: canLoadAd)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func testUnitID() -> String { "ca-app-pub-1287774922601866/3704195420" }
}

extension GADRewardedAd {
    static func loadingSpy() -> Spy {
        Spy(
            #selector(GADRewardedAd.load(withAdUnitID:request:completionHandler:)),
            #selector(Spy.load(withAdUnitID:request:completionHandler:))
        )
    }

    class Spy: NSObject {
        private let source: Selector
        private let destination: Selector
        private static var capturedCompletion: GADRewardedAdLoadCompletionHandler?

        init(_ source: Selector, _ destination: Selector) {
            self.source = source
            self.destination = destination
            Self.capturedCompletion = nil
        }

        @objc func load(withAdUnitID adUnitID: String, request: GADRequest?, completionHandler: @escaping GADRewardedAdLoadCompletionHandler) {
            Self.capturedCompletion = completionHandler
        }
        
        func startIntercepting() {
            method_exchangeImplementations(
                class_getClassMethod(GADRewardedAd.self, source)!,
                class_getInstanceMethod(Spy.self, destination)!
            )
        }
        
        func completeLoadingWithError() {
            Self.capturedCompletion?(nil, anyNSError())
        }
        
        func completeLoadingWithEmptyAd() {
            Self.capturedCompletion?(nil, nil)
        }
        
        func completeLoadingWithAd(adUnitID: String) {
            Self.capturedCompletion?(GADRewardedAdStub(adUnitID: adUnitID), nil)
        }

        deinit {
            method_exchangeImplementations(
                class_getInstanceMethod(Spy.self, destination)!,
                class_getClassMethod(GADRewardedAd.self, source)!
            )
            Self.capturedCompletion = nil
        }
    }
}

private final class GADRewardedAdStub: GADRewardedAd {
    private var _adUnitID: String?
    
    convenience init(adUnitID: String) {
        self.init()
        self._adUnitID = adUnitID
    }
    
    override var adUnitID: String { _adUnitID ?? super.adUnitID }
}
