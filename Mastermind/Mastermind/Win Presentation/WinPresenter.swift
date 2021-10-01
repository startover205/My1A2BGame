//
//  WinPresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/30.
//

import Foundation

public final class WinPresenter {
    public init(view: Any) { }
    
    public static var shareMessageFormat: String {
        NSLocalizedString("%d_SHARE_MESSAGE_FORMAT",
                          tableName: "Win",
                          bundle: Bundle(for: WinPresenter.self),
                          comment: "Format for the sharing message")
    }
}
