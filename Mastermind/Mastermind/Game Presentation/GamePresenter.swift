//
//  GamePresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/19.
//

import Foundation

public final class GamePresenter {
    private let gameView: GameView
    private let utteranceView: UtteranceView

    public init(gameView: GameView, utteranceView: UtteranceView) {
        self.gameView = gameView
        self.utteranceView = utteranceView
    }

    public static var guessChanceCountFormat: String {
        NSLocalizedString("%d_GUESS_CHANCE_COUNT_FORMAT",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Format for the left chance count")
    }

    public static var voiceMessageForWinning: String {
        NSLocalizedString("WIN_VOICE_MESSAGE",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Voice message played when user wins")
    }

    public static var voiceMessageForLosing: String {
        NSLocalizedString("LOSE_VOICE_MESSAGE",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Voice message played when user loses")
    }

    public static var giveUpAlertTitle: String {
        NSLocalizedString("GAME_GIVE_UP_ALERT_TITLE",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Title for the give up alert")
    }

    public static var giveUpAlertConfirmTitle: String {
        NSLocalizedString("GAME_GIVE_UP_ALERT_CONFIRM_TITLE",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Title for the give up alert confirm button")
    }

    public static var giveUpAlertCancelTitle: String {
        NSLocalizedString("GAME_GIVE_UP_ALERT_CANCEL_TITLE",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Title for the give up alert cancel button")
    }

    public func didUpdateLeftChanceCount(_ leftChanceCount: Int) {
        let message = String.localizedStringWithFormat(Self.guessChanceCountFormat, leftChanceCount)
        let shouldBeAwareOfChanceCount = leftChanceCount <= 3
        gameView.display(LeftChanceCountViewModel(message: message, shouldBeAwareOfChanceCount: shouldBeAwareOfChanceCount))
    }

    public func didMatchGuess(guess: DigitSecret, result: MatchResult) {
        let hint = "\(result.bulls)A\(result.cows)B"
        let resultMessage = guess.content.compactMap(String.init).joined() + "          " + "\(hint)\n"

        gameView.display(MatchResultViewModel(
                            matchCorrect: result.correct,
                            resultMessage: resultMessage))

        utteranceView.display(VoiceMessageViewModel(message: hint))
    }

    public func didWinGame() {
        gameView.displayGameEnd()

        utteranceView.display(VoiceMessageViewModel(message: Self.voiceMessageForWinning))
    }

    public func didLoseGame() {
        gameView.displayGameEnd()

        utteranceView.display(VoiceMessageViewModel(message: Self.voiceMessageForLosing))
    }

    public func didTapGiveUpButton(confirmCallBack: @escaping () -> Void) {
        gameView.display(GiveUpAlertViewModel(
                            title: Self.giveUpAlertTitle,
                            confirmTitle: Self.giveUpAlertConfirmTitle,
                            cancelTitle: Self.giveUpAlertCancelTitle,
                            confirmCallBack: confirmCallBack))
    }
}
