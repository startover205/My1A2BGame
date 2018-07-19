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

class GuessNumberTableViewController: UITableViewController {

    @IBOutlet weak var voiceSwitch: UISwitch!
    var quizNumbers = [String]()
    var guessCount = 0
    var guessHistoryText = ""
    let synthesizer = AVSpeechSynthesizer()

    
    @IBOutlet weak var lastGuessLabel: UILabel!
    @IBOutlet weak var guessCountLabel: UILabel!
    @IBOutlet var quizLabels: [UILabel]!
    @IBOutlet var answerTextFields: [UITextField]!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var checkFormatLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var hintTextView: UITextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGame()
        
        loadUserDefaults()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        //check format
        guard checkFormat() else{
            checkFormatLabel.isHidden = false
            
            return
            
        }
        checkFormatLabel.isHidden = true
        
        //guessCount -1
        guessCount -= 1
//        guessCountLabel.text = "還可以猜 \(guessCount) 次"
        guessCountLabel.text = NSLocalizedString("還可以猜", comment: "") + " \(guessCount) " + NSLocalizedString("次", comment: "")
        
        
        
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
                show(controller, sender: nil)
                
                
                text = NSLocalizedString("恭喜贏了", comment: "")
                
            }
            
            
            //lose
        }else if guessCount == 0{
            quitButton.sendActions(for: .touchUpInside)
            text =  NSLocalizedString("不要灰心，再試試看", comment: "")

        }
        
        //speech function
        if voiceSwitch.isOn{
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: NSLocalizedString("zh-TW", comment: ""))
        synthesizer.speak(speechUtterance)
        }
        
    }
    
    @IBAction func quitBtnPressed(_ sender: Any) {
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
        guessCount = 12
        guessCountLabel.text = NSLocalizedString("還可以猜", comment: "") + " \(guessCount) " + NSLocalizedString("次", comment: "")
        
        let shuffledDistribution = GKShuffledDistribution(lowestValue: 0, highestValue: 9)
        
        //set answers
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        
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

extension GuessNumberTableViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 1
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
        
    }
    
    
}

