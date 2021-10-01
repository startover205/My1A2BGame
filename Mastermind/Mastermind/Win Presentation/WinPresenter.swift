//
//  WinPresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/30.
//

import Foundation

public protocol WinView {
    func display(_ viewModel: WinMessageViewModel)
}

public struct WinMessageViewModel {
    public let message: String
}

public final class WinPresenter {
    private let winView: WinView
    private let digitCount: Int
    
    public init(digitCount: Int, winView: WinView) {
        self.digitCount = digitCount
        self.winView = winView
    }
    
    public static var shareMessageFormat: String {
        NSLocalizedString("%d_SHARE_MESSAGE_FORMAT",
                          tableName: "Win",
                          bundle: Bundle(for: WinPresenter.self),
                          comment: "Format for the sharing message")
    }
    
    public static var winMessageFormat: String {
        NSLocalizedString("%d_WIN_MESSAGE_FORMAT",
                          tableName: "Win",
                          bundle: Bundle(for: WinPresenter.self),
                          comment: "Format for the win message")
    }
    
    public func didRequestWinMessage() {
        winView.display(WinMessageViewModel(message: String.localizedStringWithFormat(Self.winMessageFormat, digitCount)))
    }
}
