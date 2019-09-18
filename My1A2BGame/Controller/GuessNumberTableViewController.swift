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
//    @IBOutlet var answerTextFields: [UITextField]!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var checkFormatLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var hintTextView: UITextView!
    @IBOutlet var fadeOutElements: [UIView]!
    
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
    
    @IBAction func selectText(_ sender: UITextField) {
        sender.selectAll(self)
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    //for continuous inputs
//    @IBAction func jumpToNextTextField(_ sender: UITextField) {
//
//        guard sender.text?.count == 1 else {
//            return
//        }
//
//        guard sender.tag != answerTextFields.count-1 else {
//            sender.resignFirstResponder()
//            return
//        }
//        answerTextFields[sender.tag+1].becomeFirstResponder()
//    }
    
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
        
//
//        guard isFormatCorrect() else{
//            checkFormatLabel.isHidden = false
//            return
//        }
//        checkFormatLabel.isHidden = true
//

//
//        tryToMatchNumbers(anserTexts: <#T##[String]#>)
    }
    
    @IBAction func quitBtnPressed(_ sender: Any) {
        AlertManager.shared.showActionAlert(.giveUp) {
            self.showLoseVCAndEndGame()
        }
    }

    @IBAction func restartBtnPressed(_ sender: Any) {
        _ = _fadeOut
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "GuessViewController") else {
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

//// MARK: - UITextFieldDelegate
//extension GuessNumberTableViewController: UITextFieldDelegate {
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        let maxLength = 1
//        let currentString: NSString = textField.text! as NSString
//        let newString: NSString =
//            currentString.replacingCharacters(in: range, with: string) as NSString
//        return newString.length <= maxLength
//    }
//}

// MARK: - Ad Related
extension GuessNumberTableViewController {
    
    func showRewardAdAlert(){
        guard AppDelegate.internetAvailable() else {
            return
        }
        
        let alert = AlertAdController(title: NSLocalizedString("您用完次數了...", comment: "2nd"), message:
            NSLocalizedString("是否要觀看廣告？觀看廣告能讓您增加", comment: "8th") + "\(Constants.adGrantChances)" + NSLocalizedString("次機會", comment: "8th"), cancelMessage: NSLocalizedString("No, thank you", comment: "7th"), countDownTime: Constants.adHintTime, adHandler: {
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
            let alert = UIAlertController(title: NSLocalizedString("廣告還沒有讀取好，請稍候試試", comment: "2nd"), message: "", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: NSLocalizedString("確定", comment: "2nd"), style: .default)
            
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
                controller.view.backgroundColor = self.view.backgroundColor
                
                text = NSLocalizedString("恭喜贏了", comment: "")
            }
            //lose
        } else if availableGuess == 0 {
            outOfChances()
        }
        
        //speech function
        if voiceSwitch.isOn {
            let speechUtterance = AVSpeechUtterance(string: text)
            speechUtterance.voice = AVSpeechSynthesisVoice(language: NSLocalizedString("zh-TW", comment: ""))
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
            let text = NSLocalizedString("不要灰心，再試試看", comment: "")
            let speechUtterance = AVSpeechUtterance(string: text)
            speechUtterance.voice = AVSpeechSynthesisVoice(language: NSLocalizedString("zh-TW", comment: ""))
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
        availableGuessLabel.text = NSLocalizedString("還可以猜", comment: "") + " \(availableGuess) " + NSLocalizedString("次", comment: "")
        availableGuessLabel.textColor = availableGuess <= 3 ? .red : .darkGray
    }
    
    func loadUserDefaults(){
        voiceSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaults.Key.voicePromptsSwitch)
    }
    
    func saveUserDefaults(){
        UserDefaults.standard.set(voiceSwitch.isOn, forKey: UserDefaults.Key.voicePromptsSwitch)
    }
    
    func showVoicePromptHint(){
        let alertController = UIAlertController(title: NSLocalizedString("語音提示功能已開啟", comment: ""), message: NSLocalizedString("Siri會將猜測結果報告給您", comment: "2nd"), preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("確定", comment: ""), style: .default, handler: nil)
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
//    func isFormatCorrect() -> Bool {
//        for i in 0..<quizNumbers.count {
//            guard let answerText = answerTextFields[i].text , answerText.count == 1, Int(answerText) != nil else{
//                return false
//            }
//        }
//
//        for i in 0...quizNumbers.count-2 {
//            for j in i+1...quizNumbers.count-1{
//                if answerTextFields[i].text == answerTextFields[j].text, i != j{
//                    return false
//                }
//            }
//        }
//        return true
//    }
    
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
        availableGuess = Constants.maxPlayChances
        
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
//        for textField in answerTextFields {
//            textField.alpha = 0
//        }
        
        //show answer
        for i in 0..<digitCount{
            quizLabels[i].textColor = #colorLiteral(red: 0.287477035, green: 0.716722175, blue: 0.8960909247, alpha: 1)
            quizLabels[i].text = quizNumbers[i]
        }
    }
}

