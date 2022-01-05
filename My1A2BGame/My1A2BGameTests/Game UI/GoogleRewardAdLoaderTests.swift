//
//  GoogleRewardAdLoaderTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2022/1/4.
//  Copyright © 2022 Ming-Ta Yang. All rights reserved.
//

import XCTest
import GoogleMobileAds
import MastermindiOS

final class GoogleRewardAdLoader {
    let adUnitID: String
    
    init(adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    func load(completion: @escaping (RewardAdLoader.Result) -> Void) {
        completion(.failure(anyNSError()))
    }
}

class GoogleRewardAdLoaderTests: XCTestCase {
    
    func test_load_deliversFailureOnLoadError() {
        let sut = makeSUT()
        let stub = GADRewardedAd.alwaysFailingLoadingStub()
        stub.startIntercepting()
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

        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(adUnitID: String = "", file: StaticString = #filePath, line: UInt = #line) -> GoogleRewardAdLoader {
        let sut = GoogleRewardAdLoader(adUnitID: adUnitID)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func testUnitID() -> String { "ca-app-pub-1287774922601866/3704195420" }
}

extension GADRewardedAd {
    static func alwaysFailingLoadingStub() -> Stub {
        Stub(
            #selector(GADRewardedAd.load(withAdUnitID:request:completionHandler:)),
            #selector(Stub.load(withAdUnitID:request:completionHandler:))
        )
    }

    class Stub: NSObject {
        private let source: Selector
        private let destination: Selector

        init(_ source: Selector, _ destination: Selector) {
            self.source = source
            self.destination = destination
        }

        @objc func load(withAdUnitID adUnitID: String, request: GADRequest?, completionHandler: @escaping GADRewardedAdLoadCompletionHandler) {
            completionHandler(nil, anyNSError())
        }

        func startIntercepting() {
            method_exchangeImplementations(
                class_getClassMethod(GADRewardedAd.self, source)!,
                class_getInstanceMethod(Stub.self, destination)!
            )
        }

        deinit {
            method_exchangeImplementations(
                class_getInstanceMethod(Stub.self, destination)!,
                class_getClassMethod(GADRewardedAd.self, source)!
            )
        }
    }
}
