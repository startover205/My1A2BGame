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
    
    @IBOutlet weak var voiceSwitch: UISwitch!
    
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
    
    @IBOutlet weak var lastGuessLabel: UILabel!
    @IBOutlet weak var availableGuessLabel: UILabel!
    @IBOutlet var quizLabels: [UILabel]!
    @IBOutlet var answerTextFields: [UITextField]!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var checkFormatLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var hintTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        initGame()
        initCheatGame()
        
        loadUserDefaults()
    }
    
    @IBAction func selectText(_ sender: UITextField) {
        sender.selectAll(self)
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    //for continuous inputs
    @IBAction func jumpToNextTextField(_ sender: UITextField) {
        
        guard sender.text?.count == 1 else {
            return
        }
        
        guard sender.tag != answerTextFields.count-1 else {
            sender.resignFirstResponder()
            return
        }
        answerTextFields[sender.tag+1].becomeFirstResponder()
    }
    
    @IBAction func guessBtnPressed(_ sender: Any) {
        
        guard availableGuess > 0 else {
            showRewardAdAlert()
            return
        }
        
        //check format
        guard checkFormat() else{
            checkFormatLabel.isHidden = false
            
            return
            
        }
        checkFormatLabel.isHidden = true
        
        //startCounting
        _ = startPlayTime
        
        guessCount += 1
        availableGuess -= 1
        
        //try to match numbers
        var numberOfAs = 0
        var numberOfBs = 0
        var guessText = ""
        for j in 0...quizNumbers.count-1{
            
            guessText.append(answerTextFields[j].text!)
            
            for i in 0...quizNumbers.count-1{
                
                if answerTextFields[j].text! == quizNumbers[i]{
                    if i == j{
                        numberOfAs += 1
                    }else{
                        numberOfBs += 1
                    }
                }
                
            }
            answerTextFields[j].text = ""
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
        if numberOfAs == 4 {
            
            endGame()
            
            if let controller = storyboard?.instantiateViewController(withIdentifier: "Win") as? WinViewController
            {
                controller.guessCount = guessCount
                controller.spentTime = CACurrentMediaTime() - self.startPlayTime
                show(controller, sender: nil)
                
                text = NSLocalizedString("恭喜贏了", comment: "")
                
            }
            
            //lose
        }else if availableGuess == 0{
            if GADRewardBasedVideoAd.sharedInstance().isReady {
                showRewardAdAlert()
            } else {
                quitButton.sendActions(for: .touchUpInside)
            }
        }
        
        //speech function
        if voiceSwitch.isOn{
            let speechUtterance = AVSpeechUtterance(string: text)
            speechUtterance.voice = AVSpeechSynthesisVoice(language: NSLocalizedString("zh-TW", comment: ""))
            synthesizer.speak(speechUtterance)
        }
        
    }
    
    @IBAction func quitBtnPressed(_ sender: Any) {
        if voiceSwitch.isOn{
            let text =  NSLocalizedString("不要灰心，再試試看", comment: "")
            let speechUtterance = AVSpeechUtterance(string: text)
            speechUtterance.voice = AVSpeechSynthesisVoice(language: NSLocalizedString("zh-TW", comment: ""))
            synthesizer.speak(speechUtterance)
        }
        endGame()
        
        
    }
    
    func endGame()  {
        //toggle UI
        guessButton.isHidden = true
        quitButton.isHidden = true
        restartButton.isHidden = false
        for textField in answerTextFields {
            textField.alpha = 0
        }
        
        //show answer
        for i in 0...quizNumbers.count-1{
            quizLabels[i].textColor = #colorLiteral(red: 0.287477035, green: 0.716722175, blue: 0.8960909247, alpha: 1)
            quizLabels[i].text = quizNumbers[i]
        }
        
    }
    
    @IBAction func restartBtnPressed(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = mainStoryBoard.instantiateInitialViewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = controller
    }
    
    func checkFormat() -> Bool {
        
        for i in 0...quizNumbers.count-1 {
            if answerTextFields[i].text == nil{
                return false
            }
            
            if answerTextFields[i].text?.count != 1{
                
                return false
            }
            
            if Int(answerTextFields[i].text!) == nil{
                
                return false
            }
            
        }
        
        for i in 0...quizNumbers.count-2 {
            
            for j in i+1...quizNumbers.count-1{
                if answerTextFields[i].text == answerTextFields[j].text, i != j{
                    return false
                }
            }
            
        }
        
        return true
        
    }
    
    func initGame(){
        
        //set data
        availableGuess = Constants.maxPlayChances
        
        let shuffledDistribution = GKShuffledDistribution(lowestValue: 0, highestValue: 9)
        
        //set answers
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        
    }
    
    func initCheatGame(){
        //set data
        availableGuess = Constants.maxPlayChances
        
        //set answers
        quizNumbers.append("1")
        quizNumbers.append("2")
        quizNumbers.append("3")
        quizNumbers.append("4")
    }
    
    @IBAction func changeVoicePromptsSwitchState(_ sender: UISwitch) {
        
        //save userDefault
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(sender.isOn, forKey: "VoicePromptsSwitch")
        
        //hint for switch function
        if sender.isOn {
            let alertController = UIAlertController(title: NSLocalizedString("語音提示功能已開啟", comment: ""), message: nil, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("確定", comment: ""), style: .default, handler: nil)
            
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func loadUserDefaults(){
        
        let userDefaults = UserDefaults.standard
        
        let isVoicePromptsOn = userDefaults.bool(forKey: "VoicePromptsSwitch")
        
        voiceSwitch.isOn = isVoicePromptsOn
        
    }
}

// MARK: - UITextFieldDelegate
extension GuessNumberTableViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 1
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}

// MARK: - Ad Related
extension GuessNumberTableViewController {
    func showRewardAdAlert(){
        let alert = AlertAdController(title: "您用完次數了...".localized, message: "是否要觀看廣告？觀看廣告能讓您增加\(Constants.adGrantChances)次機會".localized, countDownTime: Constants.adHintTime, adHandler: {
            self.showAd()
        }){
            self.quitButton.sendActions(for: .touchUpInside)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func showAd(){
        if GADRewardBasedVideoAd.sharedInstance().isReady {
            NotificationCenter.default.addObserver(self, selector: #selector(adDidReward), name: .adDidReward, object: nil)
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        } else {
            let alert = UIAlertController(title: "廣告還沒有讀取好，請稍候試試".localized, message: "", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "確定".localized, style: .default)
            
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

// MARK: - Private
private extension GuessNumberTableViewController {
    func updateAvailableGuessLabel(){
        availableGuessLabel.text = NSLocalizedString("還可以猜", comment: "") + " \(availableGuess) " + NSLocalizedString("次", comment: "")
    }
}
