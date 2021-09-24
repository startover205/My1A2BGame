//
//  GameView.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/19.
//

public protocol GameView {
    func display(_ viewModel: MatchResultViewModel)
    func display(_ viewModel: LeftChanceCountViewModel)
    func display(_ viewModel: GiveUpAlertViewModel)
    func displayGameEnd()
}

public struct GiveUpAlertViewModel {
    public let title: String
    public let confirmTitle: String
    public let cancelTitle: String
    public let confirmCallBack: () -> Void
}
