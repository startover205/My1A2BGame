//
//  GussNumberViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/10/7.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import UIKit
import GameKit
import GoogleMobileAds
import MastermindiOS

public typealias Animate = ((_ duration: TimeInterval,
                             _ animations: @escaping () -> Void,
                             _ completion: ((Bool) -> Void)?) -> Void)

public protocol AdProvider {
    var rewardAd: GADRewardedAd? { get }
}

public class GuessNumberViewController: UIViewController {

    public var gameVersion: GameVersion!
    
    private var digitCount: Int { gameVersion.digitCount }
    
    var adProvider: AdProvider?
    var evaluate: ((_ guess: [Int], _ answer: [Int]) throws -> (correctCount: Int, misplacedCount: Int))?
    var voicePromptViewController: VoicePromptViewController?
    var onWin: ((_ guessCount: Int, _ guessTime: TimeInterval) -> Void)?
    var onLose: (() -> Void)?
    var onRestart: (() -> Void)?
    
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
    var availableGuess = Constants.maxPlayChances {
        didSet{
            updateAvailableGuessLabel()
        }
    }
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
        
        initGame()
        //        initCheatGame()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fadeIn()
    }
    
    @IBAction func guessBtnPressed(_ sender: Any) {
        guard availableGuess > 0 else {
            if let ad = adProvider?.rewardAd {
                showRewardAdAlert(ad: ad)
            } else {
                showLoseVCAndEndGame()
            }
            return
        }
        
        feedbackGenerator = .init()
        feedbackGenerator?.prepare()
        
        present(inputNavigationController, animated: true)
    }
    
    @IBAction func quitBtnPressed(_ sender: Any) {
        AlertManager.shared.showActionAlert(.giveUp) {
            self.showLoseVCAndEndGame()
        }
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

// MARK: - Ad Related
extension GuessNumberViewController {
    /// 顯示 alert，詢問使用者是否要看廣告來增加次數
    func showRewardAdAlert(ad: GADRewardedAd){
        let format = NSLocalizedString("Do you want to watch a reward ad? Watching a reward ad will grant you %d chances!", comment: "")
        let alert = AlertAdCountdownController(title: NSLocalizedString("You Are Out Of Chances...", comment: "2nd"), message:
            String.localizedStringWithFormat(format, Constants.adGrantChances), cancelMessage: NSLocalizedString("No, thank you", comment: "7th"), countDownTime: Constants.adHintTime, adHandler: {
                
                ad.present(fromRootViewController: self) { [weak self] in
                    _ = ad // 保留 ref，才不會因為 reload 新廣告導致 callback 沒被呼叫

    //                print("使用者看完影片 獎勵數量: \(ad.adReward.amount)")
                    self?.grantAdReward()
                }
                
        }){
            self.showLoseVCAndEndGame()
        }
        present(alert, animated: true, completion: nil)
    }
    
    func grantAdReward(){
        availableGuess += Constants.adGrantChances
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
            if availableGuess == 0, adProvider?.rewardAd == nil {
                showLoseVCAndEndGame()
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
    func fadeOut(){
        animate?(1, { [weak self] in
            self?.fadeOutElements.forEach { $0.alpha = 0 }
        }, nil)
    }
    func fadeIn(){
        animate?(1, { [weak self] in
            self?.fadeOutElements.forEach { $0.alpha = 1 }
        }, nil)
    }
    func updateAvailableGuessLabel(){
        let format = NSLocalizedString("You can still guess %d times", comment: "")
        availableGuessLabel.text = String.localizedStringWithFormat(format, availableGuess)
        if #available(iOS 13.0, *) {
            availableGuessLabel.textColor = availableGuess <= 3 ? UIColor.systemRed : UIColor.label
        } else {
            availableGuessLabel.textColor = availableGuess <= 3 ? UIColor.systemRed : UIColor.darkGray
        }
    }
    
    func initGame(){
        
        //set data
        availableGuess = gameVersion.maxGuessCount
        guessHistoryText = ""
    }
    
    func endGame()  {
        //toggle UI
        guessButton.isHidden = true
        quitButton.isHidden = true
        restartButton.isHidden = false
        helperViewController?.hideView()
        quizLabelViewController?.reveal(answer: quizNumbers)
    }
}
