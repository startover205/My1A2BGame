//
//  RewardAdPresenter.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/28.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation

public final class RewardAdPresenter {
    private init() {}
    
    public static var alertTitle: String {
        NSLocalizedString("ALERT_TITLE",
                          tableName: "RewardAd",
                          bundle: Bundle(for: RewardAdPresenter.self),
                          comment: "Title for reward ad alert")
    }
    
    public static var alertMessageFormat: String {
        NSLocalizedString("%d_ALERT_MESSAGE_FORMAT",
                          tableName: "RewardAd",
                          bundle: Bundle(for: RewardAdPresenter.self),
                          comment: "Message format for reward ad alert")
    }
    
    public static var alertCancelTitle: String {
        NSLocalizedString("ALERT_CANCEL_TITLE",
                          tableName: "RewardAd",
                          bundle: Bundle(for: RewardAdPresenter.self),
                          comment: "Cancel title for reward ad alert")
    }
    
    public static var alertCountDownTime: TimeInterval { 5.0 }
}
