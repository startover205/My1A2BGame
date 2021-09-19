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
    var onRestart: (() -> Void)?
    var onGiveUp: (() -> Void)?
    var delegate: GuessNumberViewControllerDelegate?
    
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
        
        delegate?.didRequestLeftChanceCountUpdate()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fadeIn()
    }
    
    @IBAction func guessBtnPressed(_ sender: Any) {
        feedbackGenerator = .init()
        feedbackGenerator?.prepare()
        
        present(inputNavigationController, animated: true)
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

extension GuessNumberViewController: GameView {
    public func display(_ viewModel: MatchResultViewModel) {
        let result = viewModel.resultMessage
        hintViewController.updateHint(result)
        
        feedbackGenerator?.notificationOccurred(viewModel.matchCorrect ? .success : .error)
        feedbackGenerator = nil

        voicePromptViewController?.playVoicePromptIfEnabled(message: viewModel.voiceMessage)
    }
    
    public func display(_ viewModel: LeftChanceCountViewModel) {
        availableGuessLabel?.text = viewModel.message
        availableGuessLabel?.textColor = viewModel.shouldBeAwareOfChanceCount ? .systemRed : labelColor
    }
    
    public func displayGameEnd() {
        configureViewsForGameResult()
    }
    
    private var labelColor: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .darkGray
        }
    }
}

extension GuessNumberViewController {
    
    func tryToMatchNumbers(guessTexts: [String]) {
        delegate?.didRequestMatch(guessTexts.compactMap(Int.init))
    }
    
    func onGameLose(){
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
    
    func configureViewsForGameResult()  {
        //toggle UI
        guessButton.isHidden = true
        quitButton.isHidden = true
        restartButton.isHidden = false
        helperViewController?.hideView()
        quizLabelViewController.revealAnswer()
    }
}
