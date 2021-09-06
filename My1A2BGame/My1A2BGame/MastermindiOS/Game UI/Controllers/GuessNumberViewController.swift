//
//  GussNumberViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/10/7.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind
import MastermindiOS

public class GuessNumberViewController: UIViewController {
    var voicePromptViewController: VoicePromptViewController?
    var adViewController: RewardAdViewController?
    var onRestart: (() -> Void)?
    var onGiveUp: (() -> Void)?
    var availableGuess = 0 {
        didSet {
            updateAvailableGuessLabel()
        }
    }
    var guessCompletion: GuessCompletion!
    
    @IBOutlet var helperViewController: HelperViewController!
    @IBOutlet private(set) public var quizLabelViewController: QuizLabelViewController!
    @IBOutlet private(set) public var hintViewController: HintViewController!
    @IBOutlet private(set) public weak var availableGuessLabel: UILabel!
    @IBOutlet private(set) public weak var guessButton: UIButton!
    @IBOutlet private(set) public weak var quitButton: UIButton!
    @IBOutlet private(set) public weak var restartButton: UIButton!
    @IBOutlet private(set) public var fadeOutViews: [UIView]!
    
    public var inputVC: GuessPadViewController!
    private lazy var inputNavigationController = UINavigationController(rootViewController: inputVC)
    
    public var animate: Animate?
    
    // 觸覺回饋
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let voicePromptView = voicePromptViewController?.view {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: voicePromptView)
        }
        
        hintViewController.configureViews()
        quizLabelViewController.configureViews()
        
        fadeOutViews.forEach { $0.alpha = 0 }
        
        updateAvailableGuessLabel()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fadeIn()
    }
    
    @IBAction func guessBtnPressed(_ sender: Any) {
        guard availableGuess > 0 else {
            handleNoChanceLeft()
            return
        }
        
        feedbackGenerator = .init()
        feedbackGenerator?.prepare()
        
        present(inputNavigationController, animated: true)
    }
    
    private func handleNoChanceLeft() {
        if adViewController?.adAvailable() == true {
            adViewController?.askUserToWatchAd { [weak self] success in
                if !success { self?.showLoseVCAndEndGame() }
            }
        } else {
            showLoseVCAndEndGame()
        }
    }
    
    @IBAction func quitBtnPressed(_ sender: Any) {
        onGiveUp?()
    }
    
    @IBAction func restartBtnPressed(_ sender: Any) {
        onRestart?()
    }
}

// MARK: - GuessPadDelegate
extension GuessNumberViewController: GuessPadDelegate {
    public func padDidFinishEntering(numberTexts: [String]) {
        tryToMatchNumbers(guessTexts: numberTexts)
    }
}

extension GuessNumberViewController {
    
    func tryToMatchNumbers(guessTexts: [String]) {
        
        availableGuess -= 1
        
        let (hint, correct) = guessCompletion(DigitSecret(digits: guessTexts.compactMap(Int.init))!)
        
        //show result
        let guessText = guessTexts.joined()
        let result = "\(guessText)          \(hint ?? "")\n"
        hintViewController.updateHint(result)
        
        var text = hint ?? "" //for speech
        
        //win
        if correct {
            feedbackGenerator?.notificationOccurred(.success)
            feedbackGenerator = nil
            
            text = NSLocalizedString("Congrats! You won!", comment: "")
        } else {
            feedbackGenerator?.notificationOccurred(.error)
            feedbackGenerator = nil
            
            // 如果沒次數，且沒廣告，則直接結束
            if availableGuess <= 0 {
                handleNoChanceLeft()
            }
        }
        
        //speech function
        voicePromptViewController?.playVoicePromptIfEnabled(message: text)
    }
    
    func showLoseVCAndEndGame(){
        configureViewsForGameResult()

        voicePromptViewController?.playVoicePromptIfEnabled(message: NSLocalizedString("Don't give up! Give it another try!", comment: ""))
    }
    
    func fadeOut() { fadeTo(alpha: 0) }
    
    func fadeIn() { fadeTo(alpha: 1) }
        
    private func fadeTo(alpha: CGFloat) {
        animate?(1, { [weak self] in
            self?.fadeOutViews.forEach { $0.alpha = alpha }
        }, nil)
    }
    
    func updateAvailableGuessLabel() {
        let format = NSLocalizedString("You can still guess %d times", comment: "")
        availableGuessLabel?.text = String.localizedStringWithFormat(format, availableGuess)
        availableGuessLabel?.textColor = availableGuess <= 3 ? UIColor.systemRed : labelColor
    }
    
    private var labelColor: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .darkGray
        }
    }
    
    func configureViewsForGameResult()  {
        //toggle UI
        guessButton.isHidden = true
        quitButton.isHidden = true
        restartButton.isHidden = false
        helperViewController?.hideView()
        quizLabelViewController.revealAnswer()
    }
}
