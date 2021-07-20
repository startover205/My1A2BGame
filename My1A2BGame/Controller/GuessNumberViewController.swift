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

class GuessNumberViewController: UIViewController {
    
    private lazy var digitCount = {
        return quizLabels.count
    }()
    private lazy var isAdvancedVersion = {
        return digitCount == 5
    }()
    
    var adProvider: AdProvider?
    
    @IBOutlet weak var voiceSwitch: UISwitch!
    @IBOutlet weak var lastGuessLabel: UILabel!
    @IBOutlet weak var availableGuessLabel: UILabel!
    @IBOutlet var quizLabels: [UILabel]!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var hintTextView: UITextView!
    @IBOutlet var fadeOutElements: [UIView]!
    
    @IBOutlet weak var helperView: UIView!
    @IBOutlet var helperNumberButtons: [HelperButton]!
    
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
    
    lazy var navNumberPadVC: UINavigationController = {
        let nav = storyboard?.instantiateViewController(withIdentifier: "nav\(String(describing: GuessPadViewController.self))") as! UINavigationController
        nav.modalPresentationStyle = .formSheet
        let controller = nav.topViewController as! GuessPadViewController
        controller.delegate = self
        return nav
    }()
    
    lazy var navAdvancedNumberPadVC: UINavigationController = {
        let nav = storyboard?.instantiateViewController(withIdentifier: "navAdvanced\(String(describing: GuessPadViewController.self))") as! UINavigationController
        nav.modalPresentationStyle = .formSheet
        let controller = nav.topViewController as! GuessPadViewController
        controller.delegate = self
        return nav
    }()
    
    // 觸覺回饋
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        
        fadeOutElements.forEach { (view) in
            view.alpha = 0
        }
        
        initGame()
        //        initCheatGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        if digitCount == 5{
            self.present(navAdvancedNumberPadVC, animated: true, completion: nil)
        } else {
            self.present(navNumberPadVC, animated: true, completion: nil)
        }
        
        feedbackGenerator = .init()
        feedbackGenerator?.prepare()
        
        return
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
    func padDidFinishEntering(numberTexts: [String]) {
        tryToMatchNumbers(answerTexts: numberTexts)
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
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is LoseViewController || viewController is WinViewController {
            self.endGame()
        }
    }
}

// MARK: - Private
extension GuessNumberViewController {
    
    func tryToMatchNumbers(answerTexts: [String]){
        //startCounting
        _ = startPlayTime
        
        guessCount += 1
        availableGuess -= 1
        
        //try to match numbers
        var numberOfAs = 0
        var numberOfBs = 0
        var guessText = ""
        for j in 0..<digitCount{
            
            guessText.append(answerTexts[j])
            
            for i in 0..<digitCount{
                
                if answerTexts[j] == quizNumbers[i]{
                    if i == j{
                        numberOfAs += 1
                    }else{
                        numberOfBs += 1
                    }
                }
            }
        }
        
        //show result
        let result = "\(guessText)          \(numberOfAs)A\(numberOfBs)B\n"
        lastGuessLabel.text = result
        lastGuessLabel.alpha = 0.5
        lastGuessLabel.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.lastGuessLabel.alpha = 1
        }
        hintTextView.text = "\n" + guessHistoryText
        guessHistoryText = result + guessHistoryText
        
        var text = "\(numberOfAs) A, \(numberOfBs) B" //for speech
        
        //win
        if numberOfAs == digitCount {
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
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: LoseViewController.self))
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
