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
    
    var quizNumbers = [String]()
    var guessCount = 0
    var guessHistoryText = ""
    
    @IBOutlet weak var lastGuessLabel: UILabel!
    @IBOutlet weak var guessCountLabel: UILabel!
    @IBOutlet var quizImageViews: [UIImageView]!
    @IBOutlet var answerTextFields: [UITextField]!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    @IBOutlet weak var checkFormatLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!


    @IBAction func clearText(_ sender: UITextField) {
        sender.selectAll(self)
    }
    
    //收鍵盤
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    //連續輸入
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
    
    
    //////猜！
    @IBAction func guess(_ sender: Any) {
        
        //檢查輸入格式
        guard checkFormat() else{
            checkFormatLabel.isHidden = false;            checkFormatLabel.isHidden = false
            checkFormatLabel.isHidden = false
            
            
            return
            
        }
        
        checkFormatLabel.isHidden = true
        
        //次數-1
        guessCount -= 1
        guessCountLabel.text = "還可以猜 \(guessCount) 次"
        
        //對照AB
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
        
        
        //顯示猜的結果
        let result = "\(guessText)          \(numberOfAs)A\(numberOfBs)B\n"
        
        lastGuessLabel.text = result
        lastGuessLabel.alpha = 0.5
        lastGuessLabel.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.lastGuessLabel.alpha = 1

        }
        
        hintTextView.text = "\n" + guessHistoryText
        guessHistoryText = result + guessHistoryText


        
        var text = "\(numberOfAs)A\(numberOfBs)B"

        
        //假如贏了
        if numberOfAs == 4 {
            
            endGame()
            
            if let controller = storyboard?.instantiateViewController(withIdentifier: "win") as? WinViewController
            {
                controller.guessCount = guessCount
//                show(controller, sender: nil)
                
                let imageView = UIImageView(image: UIImage(named: "firework"))
                self.view.addSubview(imageView)
                
                
                text = "恭喜贏了"
                
            }
            
            
        }else if guessCount == 0{
            quitButton.sendActions(for: .touchUpInside)
            text = "GG"
        }
        
        
        let speechUtterance = AVSpeechUtterance(string: text)
        
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
        
        let synthesizer = AVSpeechSynthesizer()
        
        synthesizer.speak(speechUtterance)
        
    }
    
    /////輸了
    @IBAction func quit(_ sender: Any) {
        
        endGame()
        
    }
    
    /////結束遊戲
    func endGame()  {
        
        guessButton.isHidden = true
        
        quitButton.isHidden = true
        
        restartButton.isHidden = false
        
        for i in 0...quizNumbers.count-1{
            let imageName = "數字\(quizNumbers[i])"
            quizImageViews[i].image = UIImage(named: imageName)
        }
    }
    
    ////重新開始
    @IBAction func restart(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBOutlet weak var hintTextView: UITextView!
    
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
        
        
//        let emitterLayer = CAEmitterLayer()
//        
//        emitterLayer.emitterPosition = CGPoint(x: 320, y: 320)
//        
//        let cell = CAEmitterCell()
//        cell.birthRate = 100
//        cell.lifetime = 10
//        cell.velocity = 100
//        cell.scale = 0.1
//        
//        cell.emissionRange = CGFloat.pi * 2.0
//        cell.contents = UIImage(named: "RadialGradient.png")!.cgImage
//        
//        emitterLayer.emitterCells = [cell]
//        
//        view.layer.addSublayer(emitterLayer)
        
//        //資料恢復預設
//        quizNumbers.removeAll()
//
        //UI恢復預設
        for i in  0...3{
            quizImageViews[i].image = #imageLiteral(resourceName: "問號")
            answerTextFields[i].text = ""
        }
        checkFormatLabel.isHidden = true
        guessCount = 16
        guessCountLabel.text = "還可以猜 \(guessCount) 次"
        quitButton.isHidden = false
        guessButton.isHidden = false
        restartButton.isHidden = true
        hintTextView.text = ""
        
        let shuffledDistribution = GKShuffledDistribution(lowestValue: 0, highestValue: 9)
    
        //設定四位數
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        
        
    }
    
    deinit {
        
        print("Somebody helps me! I'm gonna get killed!!! at : \(Date())")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emitterLayer = CAEmitterLayer()
        
        emitterLayer.emitterPosition = CGPoint(x: 320, y: 320)
        
        let cell = CAEmitterCell()
        cell.birthRate = 100
        cell.lifetime = 10
        cell.velocity = 100
        cell.scale = 0.1
        
        cell.emissionRange = CGFloat.pi * 2.0
        cell.contents = UIImage(named: "RadialGradient.png")!.cgImage
        
        emitterLayer.emitterCells = [cell]
        
        view.layer.addSublayer(emitterLayer)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
            initGame()
        
        print("self: \(self)")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
