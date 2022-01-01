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
    
    public static func gameComposedWith(
        gameVersion: GameVersion,
        userDefaults: UserDefaults,
        speechSynthesizer: AVSpeechSynthesizer = .init(),
        secret: DigitSecret,
        delegate: ReplenishChanceDelegate,
        currentDeviceTime: @escaping () -> TimeInterval = CACurrentMediaTime,
        onWin: @escaping (Score) -> Void,
        onLose: @escaping () -> Void,
        onRestart: @escaping () -> Void,
        animate: @escaping Animate = UIView.animate
    ) -> GuessNumberViewController {
        
        let gameViewController = makeGameViewController()
        gameViewController.title = gameVersion.title
        gameViewController.viewModel = GamePresenter.sceneViewModel
        
        let voicePromptViewController = VoicePromptViewController(
            userDefaults: userDefaults,
            synthesizer: speechSynthesizer,
            onToggleSwitch: { [unowned gameViewController] isOn in
                if isOn {
                    let alertController = UIAlertController(
                        title: VoicePromptOnAlertPresenter.alertTitle,
                        message: VoicePromptOnAlertPresenter.alertMessage,
                        preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(
                        title: VoicePromptOnAlertPresenter.alertConfirmTitle,
                        style: .default)
                    
                    alertController.addAction(okAction)
                    gameViewController.showDetailViewController(alertController, sender: self)
                }
            })
        gameViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: voicePromptViewController.view)
        
        gameViewController.onRestart = onRestart
        gameViewController.animate = animate
        
        gameViewController.helperViewController?.animate = animate
        gameViewController.helperViewController?.onTapHelperInfo = { [unowned gameViewController] in
            let alertController = UIAlertController(
                title: HelperPresenter.infoAlertTitle,
                message: HelperPresenter.infoAlertMessage,
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(
                title: HelperPresenter.infoAlertConfirmTitle,
                style: .default,
                handler: nil)
            
            alertController.addAction(okAction)
            gameViewController.showDetailViewController(alertController, sender: self)
        }
        
        gameViewController.quizLabelViewController.answer = secret.content
        
        gameViewController.hintViewController.animate = animate
        
        let gamePresentationAdapter = GamePresentationAdapter(
            gameController: gameViewController,
            maxGuessCount: gameVersion.maxGuessCount,
            secret: secret, delegate: delegate,
            currentDeviceTime: currentDeviceTime,
            onWin: onWin,
            onLose: onLose)
        gameViewController.delegate = gamePresentationAdapter
        let presenter = GamePresenter(
            gameView: WeakRefVirtualProxy(gameViewController),
            utteranceView: voicePromptViewController)
        gamePresentationAdapter.presenter = presenter
        
        gameViewController.onGuessButtonPressed = gamePresentationAdapter.didTapGuessButton
        
        gameViewController.onTapGiveUp = { [weak presenter] in
            presenter?.didTapGiveUpButton()
        }
        
        gameViewController.onConfirmGiveUp = { [weak presenter] in
            presenter?.didLoseGame()
            
            onLose()
        }
        
        return gameViewController
    }
    
    private static func makeGameViewController() -> GuessNumberViewController {
        let gameViewController = UIStoryboard(name: "Game", bundle: .init(for: GuessNumberViewController.self)).instantiateViewController(withIdentifier: "GuessViewController") as! GuessNumberViewController
        
        return gameViewController
    }
}

final class GamePresentationAdapter: GuessNumberViewControllerDelegate {
    private let secret: DigitSecret
    private let delegate: ReplenishChanceDelegate
    private let currentDeviceTime: () -> TimeInterval
    private let onWin: (Score) -> Void
    private let onLose: () -> Void
    var presenter: GamePresenter?
    weak var gameController: GuessNumberViewController?
    
    init(gameController: GuessNumberViewController, maxGuessCount: Int, secret: DigitSecret, delegate: ReplenishChanceDelegate, currentDeviceTime: @escaping () -> TimeInterval, onWin: @escaping (Score) -> Void, onLose: @escaping () -> Void) {
        self.gameController = gameController
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
    
    func didTapGuessButton() {
        guard leftChanceCount > 0 else {
            handleOutOfChance()
            return
        }
        
        let inputVC = makeInputController(title: NumberInputPresenter.viewModel.viewTitle)
        inputVC.digitCount = secret.content.count
        inputVC.delegate = self

        gameController?.showDetailViewController(UINavigationController(rootViewController: inputVC), sender: self)
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
    
    private func makeInputController(title: String) -> NumberInputViewController {
        let controller = UIStoryboard(name: "Game", bundle: .init(for: NumberInputViewController.self)).instantiateViewController(withIdentifier: "NumberInputViewController") as! NumberInputViewController
        controller.title = title
        
        return controller
    }
}

extension GamePresentationAdapter: NumberInputViewControllerDelegate {
    public func numberInputViewController(_ numberInputViewController: NumberInputViewController, didFinishEntering numberTexts: [String]) {
        numberInputViewController.presentingViewController?.dismiss(animated: true, completion: nil)
        
        let guess = DigitSecret(digits: numberTexts.compactMap(Int.init))!
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
}
