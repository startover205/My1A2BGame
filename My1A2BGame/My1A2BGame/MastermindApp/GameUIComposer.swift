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
import AVFoundation

public final class GameUIComposer {
    private init() {}
    
    public static func gameComposedWith(title: String, gameVersion: GameVersion, userDefaults: UserDefaults, speechSynthesizer: AVSpeechSynthesizer = .init(), secret: DigitSecret, delegate: ReplenishChanceDelegate, currentDeviceTime: @escaping () -> TimeInterval = CACurrentMediaTime, onWin: @escaping (Score) -> Void, onLose: @escaping () -> Void, onRestart: @escaping () -> Void, animate: @escaping Animate = UIView.animate) -> GuessNumberViewController {
        let voicePromptViewController = VoicePromptViewController(userDefaults: userDefaults, synthesizer: speechSynthesizer)
        
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
        inputVC.delegate = WeakRefVirtualProxy(gameViewController)
        
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
    
    private static func makeInputPadUI() -> NumberInputViewController {
        let controller = UIStoryboard(name: "Game", bundle: .init(for: NumberInputViewController.self)).instantiateViewController(withIdentifier: "NumberInputViewController") as! NumberInputViewController
        
        return controller
    }
}

final class GamePresentationAdapter: GuessNumberViewControllerDelegate {
    private let secret: DigitSecret
    private let delegate: ReplenishChanceDelegate
    private let currentDeviceTime: () -> TimeInterval
    private let onWin: (Score) -> Void
    private let onLose: () -> Void
    var presenter: GamePresenter?
    
    init(maxGuessCount: Int, secret: DigitSecret, delegate: ReplenishChanceDelegate, currentDeviceTime: @escaping () -> TimeInterval, onWin: @escaping (Score) -> Void, onLose: @escaping () -> Void) {
        self.leftChanceCount = maxGuessCount
        self.secret = secret
        self.delegate = delegate
        self.currentDeviceTime = currentDeviceTime
        self.onWin = onWin
        self.onLose = onLose
    }
    
    private var leftChanceCount: Int
    private var gameStartTime: TimeInterval?
    private var guessCount = 0
    
    func didRequestLeftChanceCountUpdate() {
        presenter?.didUpdateLeftChanceCount(leftChanceCount)
    }
    
    func didRequestMatch(_ guess: [Int]) {
        let guess = DigitSecret(digits: guess)!
        let matchResult = DigitSecretMatcher.match(guess, with: secret)
        
        leftChanceCount -= 1
        guessCount += 1
        
        if gameStartTime == nil {
            gameStartTime = currentDeviceTime()
        }
        
        presenter?.didUpdateLeftChanceCount(leftChanceCount)
        presenter?.didMatchGuess(guess: guess, result: matchResult)
        
        if matchResult.correct {
            presenter?.didWinGame()
            
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
                self.presenter?.didLoseGame()
                
                self.onLose()
            } else {
                self.leftChanceCount += replenishCount
                
                self.presenter?.didUpdateLeftChanceCount(self.leftChanceCount)
            }
        }
    }
    
    func didTapGiveUpButton() {
        presenter?.didTapGiveUpButton(confirmCallBack: { [weak self] in
            self?.presenter?.didLoseGame()
            
            self?.onLose()
        })
    }
}

