//
//  Rules.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/4/3.
//  Copyright © 2019年 Ming-Ta Yang. All rights reserved.
//

import Foundation

enum Constants {
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
