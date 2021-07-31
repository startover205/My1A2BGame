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

protocol AdProvider {
    var rewardAd: GADRewardedAd? { get }
}

public protocol GameVersion {
    var digitCount: Int { get }
    var title: String { get }
    var maxGuessCount: Int { get }
}

public struct BasicGame: GameVersion {
    public let digitCount: Int = 4
    
    public let title: String = "Basic"
    
    public var maxGuessCount: Int = 10
    
    public init() {}
}

public struct AdvancedGame: GameVersion {
    public let digitCount: Int = 5
    
    public let title: String = "Advanced"
    
    public var maxGuessCount: Int = 15
    
    public init() {}
}

public class GuessNumberViewController: UIViewController {

    public var gameVersion: GameVersion!
    
    private var digitCount: Int { gameVersion.digitCount }
    
    private lazy var isAdvancedVersion = {
        return gameVersion.digitCount == 5
    }()
    
    var adProvider: AdProvider?
    var evaluate: ((_ guess: [Int], _ answer: [Int]) throws -> (correctCount: Int, misplacedCount: Int))?
    
    @IBOutlet weak var quizLabelContainer: UIStackView!
    @IBOutlet private(set) public weak var voiceSwitch: UISwitch!
    @IBOutlet private(set) public weak var lastGuessLabel: UILabel!
    @IBOutlet private(set) public weak var availableGuessLabel: UILabel!
    @IBOutlet private(set) public weak var guessButton: UIButton!
    @IBOutlet private(set) public weak var quitButton: UIButton!
    @IBOutlet private(set) public weak var restartButton: UIButton!
    @IBOutlet private(set) public weak var hintTextView: UITextView!
    @IBOutlet private(set) public var fadeOutElements: [UIView]!
    
    @IBOutlet weak var helperView: UIView!
    @IBOutlet var helperNumberButtons: [HelperButton]!
    
    private(set) public var quizLabels = [UILabel]()
    var quizNumbers = [String]()
    private var guessCount = 0
    var availableGuess = Constants.maxPlayChances {
        didSet{
            updateAvailableGuessLabel()
        }
    }
    private var guessHistoryText = ""
    private let synthesizer = AVSpeechSynthesizer()
    private lazy var startPlayTime: TimeInterval = CACurrentMediaTime()
    private lazy var _fadeOut: Void = {
        fadeOut()
    }()
    private lazy var _fadeIn: Void = {
        fadeIn()
    }()
    
    public var inputVC: UINavigationController!

    // 觸覺回饋
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        lastGuessLabel.text = ""
        
        configureQuizLabels()
        
        navigationController?.delegate = self
        
        fadeOutElements.forEach { (view) in
            view.alpha = 0
        }
        
        initGame()
        //        initCheatGame()
    }
    
    private func makeQuizeLabel() -> UILabel {
        let label = UILabel()
        label.text = "?"
        label.textColor = .systemRed
        label.font = .init(name: "Arial Rounded MT Bold", size: 80)
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    private func configureQuizLabels() {
        for _ in 0 ..< digitCount {
            let label = makeQuizeLabel()
            quizLabelContainer.addArrangedSubview(label)
            quizLabels.append(label)
        }
        quizLabelContainer.layoutIfNeeded()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = _fadeIn
        
        loadUserDefaults()
    }
    
    @IBAction func helperBtnPressed(_ sender: Any) {
        if helperView.isHidden {
            self.helperView.isHidden = false
            self.helperView.transform = .init(translationX: 0, y: -300)
            UIView.animate(withDuration: 0.25) {
                self.helperView.transform = .identity
            }
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.helperView.transform = .init(translationX: 0, y: -300)
            }) { (_) in
                self.helperView.isHidden = true
            }
        }
    }
    
    @IBAction func helperInfoBtnPressed(_ sender: Any) {
        AlertManager.shared.showConfirmAlert(.helperInfo)
    }
    @IBAction func helperNumberBtnPressed(_ sender: HelperButton) {
        sender.toggleColor()
    }
    
    @IBAction func helperResetBtnPressed(_ sender: Any) {
        helperNumberButtons.forEach { (button) in
            button.reset()
        }
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
        
        showNumberPad { [weak self] result in
            guard let self = self else { return }
            if let guess = try? result.get() {
                self.tryToMatchNumbers(guessTexts: guess, answerTexts: self.quizNumbers)
            }
        }
        
        return
    }
    
    func showNumberPad(completion: @escaping (Result<[String], Error>) -> ()) {
        self.present(inputVC, animated: true, completion: nil)
    }
    
    @IBAction func quitBtnPressed(_ sender: Any) {
        AlertManager.shared.showActionAlert(.giveUp) {
            self.showLoseVCAndEndGame()
        }
    }
    
    @IBAction func restartBtnPressed(_ sender: Any) {
        _ = _fadeOut
        let identifier = isAdvancedVersion ? "GuessAdvancedViewController" : "GuessViewController"
        guard let controller = storyboard?.instantiateViewController(withIdentifier: identifier) else {
            assertionFailure()
            return
        }
        self.navigationController?.setViewControllers([controller], animated: false)
    }
    
    @IBAction func changeVoicePromptsSwitchState(_ sender: UISwitch) {
        
        saveUserDefaults()
        if sender.isOn {
            showVoicePromptHint()
        }
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

// MARK: - Description
extension GuessNumberViewController: UINavigationControllerDelegate{
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is LoseViewController || viewController is WinViewController {
            self.endGame()
        }
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
        UIView.animate(withDuration: 0.5) {
            self.lastGuessLabel.alpha = 1
        }
        hintTextView.text = "\n" + guessHistoryText
        guessHistoryText = result + guessHistoryText
        
        var text = "\(correctCount) A, \(misplacedCount) B" //for speech
        
        //win
        if correctCount == digitCount {
            feedbackGenerator?.notificationOccurred(.success)
            feedbackGenerator = nil
            
            if let controller = storyboard?.instantiateViewController(withIdentifier: String(describing: WinViewController.self)) as? WinViewController
            {
                controller.guessCount = guessCount
                controller.spentTime = CACurrentMediaTime() - self.startPlayTime
                show(controller, sender: nil)
                controller.isAdvancedVersion = isAdvancedVersion
                controller.view.backgroundColor = self.view.backgroundColor
                
                text = NSLocalizedString("Congrats! You won!", comment: "")
            }
        } else {
            feedbackGenerator?.notificationOccurred(.error)
            feedbackGenerator = nil
            
            // 如果沒次數，且沒廣告，則直接結束
            if availableGuess == 0, adProvider?.rewardAd == nil {
                showLoseVCAndEndGame()
            }
        }
        
        //speech function
        if voiceSwitch.isOn {
            let speechUtterance = AVSpeechUtterance(string: text)
            synthesizer.speak(speechUtterance)
        }
    }
    
    func showLoseVCAndEndGame(){
        let controller = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: String(describing: LoseViewController.self))
        controller.view.backgroundColor = self.view.backgroundColor
        navigationController?.pushViewController(controller, animated: true)
        if self.voiceSwitch.isOn{
            let text = NSLocalizedString("Don't give up! Give it another try!", comment: "")
            let speechUtterance = AVSpeechUtterance(string: text)
            speechUtterance.voice = AVSpeechSynthesisVoice(language: NSLocalizedString("en-US", comment: ""))
            self.synthesizer.speak(speechUtterance)
        }
    }
    func fadeOut(){
        UIView.animate(withDuration: 1) {
            self.fadeOutElements.forEach({ (view) in
                view.alpha = 0
            })
        }
    }
    func fadeIn(){
        UIView.animate(withDuration: 1) {
            self.fadeOutElements.forEach({ (view) in
                view.alpha = 1
            })
        }
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
    
    func loadUserDefaults(){
        voiceSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaults.Key.voicePromptsSwitch)
    }
    
    func saveUserDefaults(){
        UserDefaults.standard.set(voiceSwitch.isOn, forKey: UserDefaults.Key.voicePromptsSwitch)
    }
    
    func showVoicePromptHint(){
        let alertController = UIAlertController(title: NSLocalizedString("Voice-Prompts Feature is On", comment: ""), message: NSLocalizedString("Siri will speak out the result for you.", comment: "2nd"), preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func initGame(){
        
        //set data
        availableGuess = isAdvancedVersion ? Constants.maxPlayChancesAdvanced : Constants.maxPlayChances
        
        let shuffledDistribution = GKShuffledDistribution(lowestValue: 0, highestValue: 9)
        
        //set answers
        quizNumbers.removeAll()
        for _ in 0..<digitCount {
            quizNumbers.append(String(shuffledDistribution.nextInt()))
        }
    }
    
    func initCheatGame(){
        //set data
        availableGuess = isAdvancedVersion ? Constants.maxPlayChancesAdvanced : Constants.maxPlayChances
        //        availableGuess = 1
        
        //set answers
        for i in 0..<digitCount {
            quizNumbers.append(String(i+1))
        }
    }
    
    func endGame()  {
        //toggle UI
        guessButton.isHidden = true
        quitButton.isHidden = true
        restartButton.isHidden = false
        helperView.isHidden = true
        
        //show answer
        for i in 0..<digitCount{
            quizLabels[i].textColor = #colorLiteral(red: 0.287477035, green: 0.716722175, blue: 0.8960909247, alpha: 1)
            quizLabels[i].text = quizNumbers[i]
        }
    }
}
