//
//  WinPresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/30.
//

import Foundation

public final class WinPresenter {
    private let winView: WinView
    private let digitCount: Int
    private let guessCount: Int
    
    public init(digitCount: Int, guessCount: Int, winView: WinView) {
        self.digitCount = digitCount
        self.guessCount = guessCount
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
    
    public static var guessCountMessageFormat: String {
        NSLocalizedString("%d_GUESS_COUNT_MESSAGE_FORMAT",
                          tableName: "Win",
                          bundle: Bundle(for: WinPresenter.self),
                          comment: "Format for the guess count message")
    }
    
    public func didRequestWinResultMessage() {
        winView.display(WinResultViewModel(
                            winMessage: String.localizedStringWithFormat(Self.winMessageFormat, digitCount),
                            guessCountMessage: String.localizedStringWithFormat(Self.guessCountMessageFormat, guessCount)))
    }
}
