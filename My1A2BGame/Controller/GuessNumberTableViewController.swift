//
//  GuessNumberTableViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/5/30.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import GameKit
import AVKit
import GoogleMobileAds

class GuessNumberTableViewController: UITableViewController {
    private lazy var digitCount = {
        return quizLabels.count
    }()
    private lazy var isAdvancedVersion = {
        return digitCount == 5
    }()
    
    @IBOutlet weak var voiceSwitch: UISwitch!
    @IBOutlet weak var lastGuessLabel: UILabel!
    @IBOutlet weak var availableGuessLabel: UILabel!
    @IBOutlet var quizLabels: [UILabel]!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var checkFormatLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var hintTextView: UITextView!
    @IBOutlet var fadeOutElements: [UIView]!
    
    @IBOutlet weak var helperView: UIView!
    @IBOutlet var helperNumberButtons: [HelperButton]!
    
    private var quizNumbers = [String]()
    private var guessCount = 0
    private var availableGuess = Constants.maxPlayChances {
        didSet{
            updateAvailableGuessLabel()
        }
    }
    private var guessHistoryText = ""
    private lazy var synthesizer = AVSpeechSynthesizer()
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
            self.helperView.transform = .init(translationX: 0, y: -150)
            UIView.animate(withDuration: 0.25) {
                self.helperView.transform = .identity
            }
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.helperView.transform = .init(translationX: 0, y: -150)
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
            outOfChances()
            return
        }
        
        if digitCount == 5{
            self.present(navAdvancedNumberPadVC, animated: true, completion: nil)
        } else {
            self.present(navNumberPadVC, animated: true, completion: nil)
        }
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
extension GuessNumberTableViewController: GuessPadDelegate{
    func padDidFinishEntering(numberTexts: [String]) {
        tryToMatchNumbers(answerTexts: numberTexts)
    }
}

// MARK: - Ad Related
extension GuessNumberTableViewController {
    
    func showRewardAdAlert(){
        guard AppDelegate.internetAvailable() else {
            return
        }
        
        let format = NSLocalizedString("Do you want to watch a reward ad? Watching a reward ad will grant you %d chances!", comment: "")
        let alert = AlertAdController(title: NSLocalizedString("You Are Out Of Chances...", comment: "2nd"), message:
            String.localizedStringWithFormat(format, Constants.adGrantChances), cancelMessage: NSLocalizedString("No, thank you", comment: "7th"), countDownTime: Constants.adHintTime, adHandler: {
                self.showAd()
        }){
            self.showLoseVCAndEndGame()
        }
        present(alert, animated: true, completion: nil)
    }
    
    func showAd(){
        if GADRewardBasedVideoAd.sharedInstance().isReady {
            NotificationCenter.default.addObserver(self, selector: #selector(adDidReward), name: .adDidReward, object: nil)
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("The ad is still loading. Please try again later.", comment: "2nd"), message: "", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "2nd"), style: .default)
            
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc
    func adDidReward(){
        NotificationCenter.default.removeObserver(self, name: .adDidReward, object: nil)
        availableGuess += Constants.adGrantChances
    }
}

// MARK: - Description
extension GuessNumberTableViewController: UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is LoseViewController || viewController is WinViewController {
            self.endGame()
        }
    }
}

// MARK: - Private
private extension GuessNumberTableViewController {
    
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
        
        var text = "\(numberOfAs)A\(numberOfBs)B" //for speech
        
        //win
        if numberOfAs == digitCount {
            
            if let controller = storyboard?.instantiateViewController(withIdentifier: String(describing: WinViewController.self)) as? WinViewController
            {
                controller.guessCount = guessCount
                controller.spentTime = CACurrentMediaTime() - self.startPlayTime
                show(controller, sender: nil)
                controller.isAdvancedVersion = isAdvancedVersion
                controller.view.backgroundColor = self.view.backgroundColor
                
                text = NSLocalizedString("Congrats! You won!", comment: "")
            }
            //lose
        } else if availableGuess == 0 {
            outOfChances()
        }
        
        //speech function
        if voiceSwitch.isOn {
            let speechUtterance = AVSpeechUtterance(string: text)
            speechUtterance.voice = AVSpeechSynthesisVoice(language: NSLocalizedString("en-US", comment: ""))
            synthesizer.speak(speechUtterance)
        }
    }
    func outOfChances(){
        if GADRewardBasedVideoAd.sharedInstance().isReady, AppDelegate.internetAvailable() {
            showRewardAdAlert()
        } else {
            showLoseVCAndEndGame()
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
        availableGuessLabel.textColor = availableGuess <= 3 ? .red : .darkGray
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

