//
//  GameUIComposer.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/7/25.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind
import MastermindiOS

public final class GameUIComposer {
    private init() {}
    
    public static func gameComposedWith(title: String, gameVersion: GameVersion, userDefaults: UserDefaults, secret: DigitSecret, delegate: ReplenishChanceDelegate, currentDeviceTime: @escaping () -> TimeInterval = CACurrentMediaTime, onWin: @escaping (Score) -> Void, onLose: @escaping () -> Void, onRestart: @escaping () -> Void, animate: @escaping Animate = UIView.animate) -> GuessNumberViewController {
        let voicePromptViewController = VoicePromptViewController(userDefaults: userDefaults)
        
        let inputVC = makeInputPadUI()
        inputVC.digitCount = gameVersion.digitCount

        let gameViewController = makeGameViewController()
        gameViewController.title = title
        
        gameViewController.voicePromptViewController = voicePromptViewController
        voicePromptViewController.onToggleSwitch = { [unowned gameViewController] isOn in
            if isOn {
                let alertController = UIAlertController(title: NSLocalizedString("Voice-Prompts Feature is On", comment: ""), message: NSLocalizedString("Siri will speak out the result for you.", comment: "2nd"), preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
                
                alertController.addAction(okAction)
                gameViewController.present(alertController, animated: true, completion: nil)
            }
        }
        
        gameViewController.inputVC = inputVC
        inputVC.delegate = gameViewController
        
        gameViewController.onRestart = onRestart
        gameViewController.animate = animate
        
        gameViewController.helperViewController?.animate = animate
        gameViewController.helperViewController?.onTapHelperInfo = {
            AlertManager.shared.showConfirmAlert(.helperInfo)
        }
        
        gameViewController.quizLabelViewController.answer = secret.content
        
        gameViewController.hintViewController.animate = animate
        
        let gamePresentationAdapter = GamePresentationAdapter(
            maxGuessCount: gameVersion.maxGuessCount,
            secret: secret, delegate: delegate,
            currentDeviceTime: currentDeviceTime,
            onWin: onWin,
            onLose: onLose)
        gameViewController.delegate = gamePresentationAdapter
        gamePresentationAdapter.presenter = GamePresenter(gameView: WeakRefVirtualProxy(gameViewController))
        
        return gameViewController
    }
    
    private static func makeGameViewController() -> GuessNumberViewController {
        let gameViewController = UIStoryboard(name: "Game", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(withIdentifier: "GuessViewController") as! GuessNumberViewController

        return gameViewController
    }
    
    public static func makeInputPadUI() -> GuessPadViewController {
        let controller = UIStoryboard(name: "Game", bundle: .init(for: GuessPadViewController.self)).instantiateViewController(withIdentifier: "GuessPadViewController") as! GuessPadViewController
        
        return controller
    }
}

protocol GameView {
    func display(_ viewModel: MatchResultViewModel)
    func display(_ viewModel: LeftChanceCountViewModel)
    func displayGameEnd()
}

struct MatchResultViewModel {
    let matchCorrect: Bool
    let resultMessage: String
    let voiceMessage: String
}

struct LeftChanceCountViewModel {
    let message: String
    let textColor: UIColor
}

final class GamePresenter {
    let gameView: GameView

    init(gameView: GameView) {
        self.gameView = gameView
    }
    
    private var labelColor: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .darkGray
        }
    }
    
    func didUpdateLeftChanceCount(_ leftChanceCount: Int) {
        let format = NSLocalizedString("You can still guess %d times", comment: "")

        let message = String.localizedStringWithFormat(format, leftChanceCount)
        let textColor = leftChanceCount <= 3 ? UIColor.systemRed : labelColor
        gameView.display(LeftChanceCountViewModel(message: message, textColor: textColor))
    }
    
    func didMatchGuess(guess: DigitSecret, hint: String?, matchCorrect: Bool) {
        let resultMessage = guess.content.compactMap(String.init).joined() + "          \(hint ?? "")\n"
        
        let voiceMessage = matchCorrect ? NSLocalizedString("Congrats! You won!", comment: "") : hint ?? ""
        
        gameView.display(MatchResultViewModel(
                            matchCorrect: matchCorrect,
                            resultMessage: resultMessage,
                            voiceMessage: voiceMessage))
    }
    
    func didEndGame() {
        gameView.displayGameEnd()
    }
}

protocol GuessNumberViewControllerDelegate {
    func didRequestMatch(_ guess: [Int])
    func didRequestLeftChanceCountUpdate()
}

final class GamePresentationAdapter: GuessNumberViewControllerDelegate {
    
    init(maxGuessCount: Int, secret: DigitSecret, delegate: ReplenishChanceDelegate, currentDeviceTime: @escaping () -> TimeInterval, onWin: @escaping (Score) -> Void, onLose: @escaping () -> Void) {
        self.leftChanceCount = maxGuessCount
        self.secret = secret
        self.delegate = delegate
        self.currentDeviceTime = currentDeviceTime
        self.onWin = onWin
        self.onLose = onLose
    }
    
    let secret: DigitSecret
    let delegate: ReplenishChanceDelegate
    let currentDeviceTime: () -> TimeInterval
    let onWin: (Score) -> Void
    let onLose: () -> Void
    var presenter: GamePresenter?
    
    private var leftChanceCount: Int
    private var gameStartTime: TimeInterval?
    private var guessCount = 0
    
    func didRequestLeftChanceCountUpdate() {
        presenter?.didUpdateLeftChanceCount(leftChanceCount)
    }
    
    func didRequestMatch(_ guess: [Int]) {
        let guess = DigitSecret(digits: guess)!
        let (hint, correct) = DigitSecretMatcher.match(guess, with: secret)
        
        leftChanceCount -= 1
        guessCount += 1
        
        if gameStartTime == nil {
            gameStartTime = currentDeviceTime()
        }
        
        presenter?.didUpdateLeftChanceCount(leftChanceCount)
        presenter?.didMatchGuess(guess: guess, hint: hint, matchCorrect: correct)
        
        if correct {
            presenter?.didEndGame()
            
            let guessTime = currentDeviceTime() - (gameStartTime ?? 0.0)
            
            onWin((guessCount, guessTime))
        } else if leftChanceCount == 0 {
            handleOutOfChance()
        }
    }
    
    private func handleOutOfChance() {
        delegate.replenishChance { [weak self] replenishCount in
            guard let self = self else { return }
            
            if replenishCount <= 0 {
                self.presenter?.didEndGame()
                
                self.onLose()
            } else {
                self.leftChanceCount += replenishCount
                
                self.presenter?.didUpdateLeftChanceCount(self.leftChanceCount)
            }
        }
    }
}

