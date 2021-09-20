//
//  GameView.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/19.
//

public struct GameEndViewModel {
    public let voiceMessage: String
}

public protocol GameView {
    func display(_ viewModel: MatchResultViewModel)
    func display(_ viewModel: LeftChanceCountViewModel)
    func display(_ viewModel: GameEndViewModel)
}
