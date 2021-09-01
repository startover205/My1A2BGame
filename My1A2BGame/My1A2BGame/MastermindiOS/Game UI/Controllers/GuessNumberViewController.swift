//
//  GussNumberViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/10/7.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import UIKit
import MastermindiOS

public class GuessNumberViewController: UIViewController {
    var evaluate: ((_ guess: [Int], _ answer: [Int]) throws -> (correctCount: Int, misplacedCount: Int))?
    var voicePromptViewController: VoicePromptViewController?
    var adViewController: RewardAdViewController?
    var onWin: ((_ guessCount: Int, _ guessTime: TimeInterval) -> Void)?
    var onLose: (() -> Void)?
    var onRestart: (() -> Void)?
    var digitCount: Int = 0
    var availableGuess = 0 {
        didSet {
            updateAvailableGuessLabel()
        }
    }
    
    @IBOutlet var helperViewController: HelperViewController!
    @IBOutlet private(set) public var quizLabelViewController: QuizLabelViewController!
    @IBOutlet private(set) public weak var lastGuessLabel: UILabel!
    @IBOutlet private(set) public weak var availableGuessLabel: UILabel!
    @IBOutlet private(set) public weak var guessButton: UIButton!
    @IBOutlet private(set) public weak var quitButton: UIButton!
    @IBOutlet private(set) public weak var restartButton: UIButton!
    @IBOutlet private(set) public weak var hintTextView: UITextView!
    @IBOutlet private(set) public var fadeOutElements: [UIView]!
    
    public var quizNumbers = [String]()
    private var guessCount = 0

    private var guessHistoryText = ""
    private lazy var startPlayTime: TimeInterval = CACurrentMediaTime()
    
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
        
        helperViewController?.configureViews()
        
        lastGuessLabel.text = ""
        
        quizLabelViewController.configureViews()
        
        fadeOutElements.forEach { (view) in
            view.alpha = 0
        }
        
        guessHistoryText = ""
        
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
        let alert = UIAlertController(
            title: NSLocalizedString("Are you sure you want to give up?", comment: ""),
            message: nil,
            preferredStyle: .alert)
        
        let ok = UIAlertAction(
            title: NSLocalizedString("Give Up!", comment: "2nd"),
            style: .destructive) { [weak self] _ in
            self?.showLoseVCAndEndGame()
        }
        
        let cancel = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "2nd"),
            style: .cancel)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    @IBAction func restartBtnPressed(_ sender: Any) {
        onRestart?()
    }
}

// MARK: - GuessPadDelegate
extension GuessNumberViewController: GuessPadDelegate{
    public func padDidFinishEntering(numberTexts: [String]) {
        tryToMatchNumbers(guessTexts: numberTexts, answerTexts: quizNumbers)
    }
}

extension GuessNumberViewController {
    
    func tryToMatchNumbers(guessTexts: [String], answerTexts: [String]){
        //startCounting
        _ = startPlayTime
        
        guessCount += 1
        availableGuess -= 1
        
        //try to match numbers
        let answer = answerTexts.compactMap(Int.init)
        let guess = guessTexts.compactMap(Int.init)
        
        guard let evaluate = evaluate else { return }
        
        let (correctCount, misplacedCount) = try! evaluate(guess, answer)

        //show result
        let guessText = guessTexts.joined()
        let result = "\(guessText)          \(correctCount)A\(misplacedCount)B\n"
        lastGuessLabel.text = result
        lastGuessLabel.alpha = 0.5
        lastGuessLabel.isHidden = false
        animate?(0.5, { [weak self] in
            self?.lastGuessLabel.alpha = 1
        }, nil)
        hintTextView.text = "\n" + guessHistoryText
        guessHistoryText = result + guessHistoryText
        
        var text = "\(correctCount) A, \(misplacedCount) B" //for speech
        
        //win
        if correctCount == digitCount {
            feedbackGenerator?.notificationOccurred(.success)
            feedbackGenerator = nil
            
            text = NSLocalizedString("Congrats! You won!", comment: "")
            
            onWin?(guessCount, CACurrentMediaTime() - self.startPlayTime)
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
        self.endGame()

        voicePromptViewController?.playVoicePromptIfEnabled(message: NSLocalizedString("Don't give up! Give it another try!", comment: ""))
        
        onLose?()
    }
    
    func fadeOut() { fadeTo(alpha: 0) }
    
    func fadeIn() { fadeTo(alpha: 1) }
        
    private func fadeTo(alpha: CGFloat) {
        animate?(1, { [weak self] in
            self?.fadeOutElements.forEach { $0.alpha = alpha }
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
    
    func endGame()  {
        //toggle UI
        guessButton.isHidden = true
        quitButton.isHidden = true
        restartButton.isHidden = false
        helperViewController?.hideView()
        quizLabelViewController.revealAnswer()
    }
}
