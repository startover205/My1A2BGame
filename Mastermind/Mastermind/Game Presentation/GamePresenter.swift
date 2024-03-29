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

    public static var giveUpConfirmMessage: String {
        NSLocalizedString("GIVE_UP_CONFIRM_MESSAGE",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Confirm give up message")
    }

    public static var confirmGiveUpAction: String {
        NSLocalizedString("CONFIRM_GIVE_UP_ACTION",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Button for confirming give up game")
    }

    public static var cancelGiveUpAction: String {
        NSLocalizedString("CANCEL_GIVE_UP_ACTION",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Button for canceling give up game")
    }
    
    private static var guessHistoryViewTitle: String {
        NSLocalizedString("GUESS_HISTORY_VIEW_TITLE",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Title for the guess history view")
    }
    
    private static var guessAction: String {
        NSLocalizedString("GUESS_ACTION",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Button for guessing")
    }
    
    private static var giveUpAction: String {
        NSLocalizedString("GIVE_UP_ACTION",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Button for giving up the game")
    }
    
    private static var restartAction: String {
        NSLocalizedString("RESTART_ACTION",
            tableName: "Game",
            bundle: Bundle(for: GamePresenter.self),
            comment: "Button for restarting the game")
    }
    
    public static var sceneViewModel: GameSceneViewModel {
        .init(guessHistoryViewTitle: Self.guessHistoryViewTitle, guessAction: Self.guessAction, giveUpAction: Self.giveUpAction, restartAction: Self.restartAction)
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

    public func didTapGiveUpButton() {
        gameView.display(GiveUpConfirmViewModel(
                            message: Self.giveUpConfirmMessage,
                            confirmAction: Self.confirmGiveUpAction,
                            cancelAction: Self.cancelGiveUpAction))
    }
}
