//
//  Rules.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/4/3.
//  Copyright © 2019年 Ming-Ta Yang. All rights reserved.
//

import Foundation

enum Constants {
    static let maxPlayChances = 1
    static let adHintTime = 5.0
    static let adGrantChances = 1
    static let rewardAdId = "ca-app-pub-3940256099942544/1712485313"
    static let bottomAdId = "ca-app-pub-3940256099942544/2934735716"
    static let appStoreReviewUrl = "https://itunes.apple.com/app/id1459347669?action=write-review"
    static let appStoreDownloadUrl = "https://itunes.apple.com/app/id1459347669"
}

extension UserDefaults {
    enum Key {
        static let voicePromptsSwitch = "VoicePromptsSwitch"
        static let remove_bottom_ad = "remove_bottom_ad7"
    }
}
