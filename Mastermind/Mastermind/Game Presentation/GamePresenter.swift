//
//  GamePresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/19.
//

import Foundation

public final class GamePresenter {
    private let gameView: GameView

    public init(gameView: GameView) {
        self.gameView = gameView
    }

    public func didUpdateLeftChanceCount(_ leftChanceCount: Int) {
        let format = NSLocalizedString("You can still guess %d times", comment: "")

        let message = String.localizedStringWithFormat(format, leftChanceCount)
        let shouldBeAwareOfChanceCount = leftChanceCount <= 3
        gameView.display(LeftChanceCountViewModel(message: message, shouldBeAwareOfChanceCount: shouldBeAwareOfChanceCount))
    }
    
    public func didMatchGuess(guess: DigitSecret, hint: String?, matchCorrect: Bool) {
        let resultMessage = guess.content.compactMap(String.init).joined() + "          \(hint ?? "")\n"
        
        let voiceMessage = hint ?? ""
        
        gameView.display(MatchResultViewModel(
                            matchCorrect: matchCorrect,
                            resultMessage: resultMessage,
                            voiceMessage: voiceMessage))
    }
    
    public func didWinGame() {
        gameView.display(GameEndViewModel(voiceMessage: NSLocalizedString("Congrats! You won!", comment: "")))
    }
    
    public func didLoseGame() {
        gameView.display(GameEndViewModel(voiceMessage: NSLocalizedString("Don't give up! Give it another try!", comment: "")))
    }
}
