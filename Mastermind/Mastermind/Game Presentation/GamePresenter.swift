//
//  GamePresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/19.
//

import Foundation

public final class GamePresenter {
    private let gameView: GameView
    
    public static var giveUpAlertTitle: String {
        NSLocalizedString("Are you sure you want to give up?", comment: "")
    }
    
    public static var giveUpAlertConfirmTitle: String {
        NSLocalizedString("Give Up!", comment: "2nd")
    }

    public static var giveUpAlertCancelTitle: String {
        NSLocalizedString("Cancel", comment: "2nd")
    }

    public init(gameView: GameView) {
        self.gameView = gameView
    }

    public func didUpdateLeftChanceCount(_ leftChanceCount: Int) {
        let format = NSLocalizedString("You can still guess %d times", comment: "")

        let message = String.localizedStringWithFormat(format, leftChanceCount)
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
        gameView.display(GameEndViewModel(voiceMessage: NSLocalizedString("Congrats! You won!", comment: "")))
    }
    
    public func didLoseGame() {
        gameView.display(GameEndViewModel(voiceMessage: NSLocalizedString("Don't give up! Give it another try!", comment: "")))
    }
    
    public func didTapGiveUpButton(confirmCallBack: @escaping () -> Void) {
        gameView.display(GiveUpAlertViewModel(
                            title: Self.giveUpAlertTitle,
                            confirmTitle: Self.giveUpAlertConfirmTitle,
                            cancelTitle: Self.giveUpAlertCancelTitle,
                            confirmCallBack: confirmCallBack))
    }
}
