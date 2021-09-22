//
//  GussNumberViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/10/7.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import UIKit
import Mastermind

public protocol GuessNumberViewControllerDelegate {
    func didRequestMatch(_ guess: [Int])
    func didRequestLeftChanceCountUpdate()
    func didTapGiveUpButton()
}

public class GuessNumberViewController: UIViewController {
    public var voicePromptViewController: VoicePromptViewController?
    public var onRestart: (() -> Void)?
    public var delegate: GuessNumberViewControllerDelegate?
    
    @IBOutlet private(set) public var helperViewController: HelperViewController!
    @IBOutlet private(set) public var quizLabelViewController: QuizLabelViewController!
    @IBOutlet private(set) public var hintViewController: HintViewController!
    @IBOutlet private(set) public weak var availableGuessLabel: UILabel!
    @IBOutlet private(set) public weak var guessButton: UIButton!
    @IBOutlet private(set) public weak var giveUpButton: UIButton!
    @IBOutlet private(set) public weak var restartButton: UIButton!
    @IBOutlet private(set) public var fadeOutViews: [UIView]!
    
    public var inputVC: NumberInputViewController!
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
    
    @IBAction func giveUpBtnPressed(_ sender: Any) {
        delegate?.didTapGiveUpButton()
    }
    
    @IBAction func restartBtnPressed(_ sender: Any) {
        onRestart?()
    }
    
    private func fadeIn() {
        animate?(1, { [weak self] in
            self?.fadeOutViews.forEach { $0.alpha = 1 }
        }, nil)
    }
}

extension GuessNumberViewController: NumberInputViewControllerDelegate {
    public func padDidFinishEntering(numberTexts: [String]) {
        delegate?.didRequestMatch(numberTexts.compactMap(Int.init))
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
    
    public func display(_ viewModel: GameEndViewModel) {
        configureViewsForGameResult()
        
        voicePromptViewController?.playVoicePromptIfEnabled(message: viewModel.voiceMessage)
    }
    
    public func display(_ viewModel: GiveUpAlertViewModel) {
        let alert = UIAlertController(
            title: viewModel.title,
            message: nil,
            preferredStyle: .alert)
        
        let confirm = UIAlertAction(
            title: viewModel.confirmTitle,
            style: .destructive) {  _ in
            viewModel.confirmCallBack()
        }
        
        let cancel = UIAlertAction(
            title: viewModel.cancelTitle,
            style: .cancel)
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    private func configureViewsForGameResult()  {
        guessButton.isHidden = true
        giveUpButton.isHidden = true
        restartButton.isHidden = false
        helperViewController?.hideView()
        quizLabelViewController.revealAnswer()
    }
    
    private var labelColor: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .darkGray
        }
    }
}
