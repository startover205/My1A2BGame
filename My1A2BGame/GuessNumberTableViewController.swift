//
//  GuessNumberTableViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/5/30.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import GameKit

class GuessNumberTableViewController: UITableViewController {
    let shuffledDistribution = GKShuffledDistribution(lowestValue: 0, highestValue: 9)
    
    var quizNumbers = [String]()
    
    var guessCount = 0
    
    @IBOutlet weak var guessCountLabel: UILabel!
    
    @IBOutlet var quizImageViews: [UIImageView]!
    
    @IBOutlet var answerTextFields: [UITextField]!
    
    @IBOutlet weak var guessButton: UIButton!
    
    @IBOutlet weak var quitButton: UIButton!
    
    
    @IBOutlet weak var checkFormatLabel: UILabel!
    
    //收鍵盤
    @IBAction func dismissKeyboard(_ sender: UITextField) {
    }
    
    
    //連續輸入
    @IBAction func jumpToNextTextField(_ sender: UITextField) {
        
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
            
        }
        
        
        //顯示猜的結果
        hintTextView.text = "\(guessText)          \(numberOfAs)A\(numberOfBs)B\n" + hintTextView.text
        
      
       
        //假如贏了
        if numberOfAs == 4 {
            
            endGame()
            
            if let controller = storyboard?.instantiateViewController(withIdentifier: "win") as? WinViewController
            {
                controller.guessCount = guessCount
                show(controller, sender: nil)
                
            }
            
            
        }else if guessCount == 0{
            quitButton.sendActions(for: .touchUpInside)
        }
        
        
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
    
    
    @IBOutlet weak var restartButton: UIButton!
    
    
    ////重新開始
    @IBAction func restart(_ sender: Any) {
        
        initGame()
        
        
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
        
        
        //資料恢復預設
        quizNumbers.removeAll()
        
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

        
        
       //設定四位數
        
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        quizNumbers.append(String(shuffledDistribution.nextInt()))
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGame()
        
        
        
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    //
    //    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        // #warning Incomplete implementation, return the number of rows
    //        return 0
    //    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
