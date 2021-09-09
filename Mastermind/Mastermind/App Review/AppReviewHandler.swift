//
//  PromptAppReviewHandler.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/19.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import StoreKit

public protocol AppReviewHandler {
    func markProcessCompleteOneTime()
    func askForAppReviewIfAppropriate(completion: ((Bool) -> Void)?)
}

public class AppReviewController {
    private let userDefaults: UserDefaults
    private let processCompleteCountKey: String = "processCompleteCount"
    private let lastPromptAppVersionKey: String = "lastPromptAppVersion"
    private let appVersion: String
    private let askForReview: () -> ()
    private let targetProcessCompletedCount: Int
    
    public init(userDefaults: UserDefaults, askForReview: @escaping () -> (), targetProcessCompletedCount: Int, appVersion: String) {
        self.userDefaults = userDefaults
        self.askForReview = askForReview
        self.targetProcessCompletedCount = targetProcessCompletedCount
        self.appVersion = appVersion
    }
    
    public func markProcessCompleteOneTime() {
        var processCompletedCount = userDefaults.integer(forKey: processCompleteCountKey)
        processCompletedCount += 1
        userDefaults.set(processCompletedCount, forKey: processCompleteCountKey)
    }
    
    public func askForAppReviewIfAppropriate() {
        let processCompletedCount = userDefaults.integer(forKey: processCompleteCountKey)
        guard processCompletedCount >= targetProcessCompletedCount else { return }
        
        let lastPromptAppVersion = userDefaults.string(forKey: lastPromptAppVersionKey)
        guard lastPromptAppVersion != appVersion else { return }
        
        askForReview()
        
        userDefaults.set(appVersion, forKey: lastPromptAppVersionKey)
    }
}
