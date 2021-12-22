//
//  Rules.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/4/3.
//  Copyright © 2019年 Ming-Ta Yang. All rights reserved.
//

import Foundation

enum Constants {
    #if DEBUG
    static let maxPlayChances = 10
    static let maxPlayChancesAdvanced = 1
    static let adGrantChances = 1

    #else
    static let maxPlayChances = 10
    static let maxPlayChancesAdvanced = 15
    static let adGrantChances = 5

    #endif

    static let adHintTime = 5.0
    
    static let rewardAdId = "ca-app-pub-1287774922601866/3704195420"
    static let bottomAdId = "ca-app-pub-1287774922601866/6524610514"
  
    static let appStoreReviewUrl = "https://itunes.apple.com/app/id1459347669?action=write-review"
    static let appStoreDownloadUrl = "https://itunes.apple.com/app/id1459347669"
}

extension UserDefaults {
    enum Key {
        static let voicePromptsSwitch = "VOICE_PROMPT"
        static let remove_bottom_ad = "remove_bottom_ad"
        static let processCompletedCount = "processCompletedCount"
        static let lastVersionPromptedForReview = "lastVersionPromptedForReview"
    }
}
