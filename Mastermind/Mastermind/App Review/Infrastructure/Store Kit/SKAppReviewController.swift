//
//  SKAppReviewController.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/9.
//

import Foundation

public class SKAppReviewController: AppReviewController {
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
    
    public func askForReviewIfAppropriate() {
        let processCompletedCount = userDefaults.integer(forKey: processCompleteCountKey)
        guard processCompletedCount >= targetProcessCompletedCount else { return }
        
        let lastPromptAppVersion = userDefaults.string(forKey: lastPromptAppVersionKey)
        guard lastPromptAppVersion != appVersion else { return }
        
        askForReview()
        
        userDefaults.set(appVersion, forKey: lastPromptAppVersionKey)
    }
}
