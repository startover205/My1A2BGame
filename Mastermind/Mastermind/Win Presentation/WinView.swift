//
//  WinView.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/10/1.
//

public protocol WinView {
    func display(_ viewModel: WinMessageViewModel)
    func display(_ viewModel: WinResultViewModel)
}

public struct WinResultViewModel {
    public let guessCountMessage: String
}
