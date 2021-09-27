//
//  HelperPresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/27.
//

import Foundation

public final class HelperPresenter {
    private init() {}
    
    public static var infoAlertTitle: String {
        NSLocalizedString("HELPER_INFO_ALERT_TITLE",
                          tableName: "Helper",
                          bundle: Bundle(for: HelperPresenter.self),
                          comment: "Title for helper info alert")
    }
    
    public static var infoAlertMessage: String {
        NSLocalizedString("HELPER_INFO_ALERT_MESSAGE",
                          tableName: "Helper",
                          bundle: Bundle(for: HelperPresenter.self),
                          comment: "Message for helper info alert")
    }
    
    public static var infoAlertConfirmTitle: String {
        NSLocalizedString("HELPER_INFO_ALERT_CONFIRM_TITLE",
                          tableName: "Helper",
                          bundle: Bundle(for: HelperPresenter.self),
                          comment: "Confirm Title for helper info alert")
    }
}
