//
//  GamePresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/19.
//

import Foundation

public final class GamePresenter {
    private let gameView: GameView
    
    private static var giveUpAlertTitle: String {
        NSLocalizedString("GAME_GIVE_UP_ALERT_TITLE",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Title for the give up alert")
    }
    
    private static var giveUpAlertConfirmTitle: String {
        NSLocalizedString("GAME_GIVE_UP_ALERT_CONFIRM_TITLE",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Title for the give up alert confirm button")
    }

    private static var giveUpAlertCancelTitle: String {
        NSLocalizedString("GAME_GIVE_UP_ALERT_CANCEL_TITLE",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Title for the give up alert cancel button")
    }

    private static var guessChanceCountFormat: String {
        NSLocalizedString("%d_GUESS_CHANCE_COUNT_FORMAT",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Format for the left chance count")
    }

    private static var voiceMessageForWinning: String {
        NSLocalizedString("WIN_VOICE_MESSAGE",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Voice message played when user wins")
    }

    private static var voiceMessageForLosing: String {
        NSLocalizedString("LOSE_VOICE_MESSAGE",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Voice message played when user loses")
    }

    public init(gameView: GameView) {
        self.gameView = gameView
    }

    public func didUpdateLeftChanceCount(_ leftChanceCount: Int) {
        let message = String.localizedStringWithFormat(Self.guessChanceCountFormat, leftChanceCount)
        let shouldBeAwareOfChanceCount = leftChanceCount <= 3
        gameView.display(LeftChanceCountViewModel(message: message, shouldBeAwareOfChanceCount: shouldBeAwareOfChanceCount))
    }
    
    public func didMatchGuess(guess: DigitSecret, result: MatchResult) {
        let hint = "\(result.bulls)A\(result.cows)B"
        let resultMessage = guess.content.compactMap(String.init).joined() + "          " + "\(hint)\n"
        
        let voiceMessage = hint
        
        gameView.display(MatchResultViewModel(
                            matchCorrect: result.correct,
                            resultMessage: resultMessage,
                            voiceMessage: voiceMessage))
    }
    
    public func didWinGame() {
        gameView.display(GameEndViewModel(voiceMessage: Self.voiceMessageForWinning))
    }
    
    public func didLoseGame() {
        gameView.display(GameEndViewModel(voiceMessage: Self.voiceMessageForLosing))
    }
    
    public func didTapGiveUpButton(confirmCallBack: @escaping () -> Void) {
        gameView.display(GiveUpAlertViewModel(
                            title: Self.giveUpAlertTitle,
                            confirmTitle: Self.giveUpAlertConfirmTitle,
                            cancelTitle: Self.giveUpAlertCancelTitle,
                            confirmCallBack: confirmCallBack))
    }
}
