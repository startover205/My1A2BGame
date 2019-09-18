//
//  GuessPadViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/9/15.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import UIKit

protocol GuessPadDelegate: class {
    func padDidFinishEntering(numberTexts: [String])
}

class GuessPadViewController: UIViewController {
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    
    @IBOutlet var digitLabels: [UILabel]!
    
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    var currentDigit = 0
    weak var delegate: GuessPadDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearAllText()
        enableAllButton()

        currentDigit = 0
    }
    @IBAction func clearBtnPressed(_ sender: Any) {
        clearAllText()
        enableAllButton()
        
        currentDigit = 0
    }
    @IBAction func deleteBtnPressed(_ sender: Any) {
        if currentDigit > 0 {
            enableNumberBtn(text: digitLabels[currentDigit-1].text)
            digitLabels[currentDigit-1].text = ""
            
            currentDigit -= 1
        }
        
    }
    
    @IBAction func numberBtnPressed(_ sender: UIButton) {
        
        digitLabels[currentDigit].text = sender.titleLabel!.text
        
        sender.isEnabled = false
        
        currentDigit += 1
        
        if currentDigit == digitLabels.count {
            guess()
        }
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Private
private extension GuessPadViewController {
    func guess(){
        
        dismiss(animated: true) {
            var texts = [String]()
            for label in self.digitLabels {
                texts.append(label.text!)
            }
               self.delegate?.padDidFinishEntering(numberTexts: texts)
        }
    }
    func enableNumberBtn(text: String?){
        guard let text = text else { return }
        guard let number = Int(text) else {
            assertionFailure()
            return }
        switch number {
        case 0:
            zeroButton.isEnabled = true
        case 1:
            oneButton.isEnabled = true
        case 2:
            twoButton.isEnabled = true
        case 3:
            threeButton.isEnabled = true
        case 4:
            fourButton.isEnabled = true
        case 5:
            fiveButton.isEnabled = true
        case 6:
            sixButton.isEnabled = true
        case 7:
            sevenButton.isEnabled = true
        case 8:
            eightButton.isEnabled = true
        case 9:
            nineButton.isEnabled = true
        default:
            break
        }
    }
    func enableAllButton(){
        zeroButton.isEnabled = true
        oneButton.isEnabled = true
        twoButton.isEnabled = true
        threeButton.isEnabled = true
        fourButton.isEnabled = true
        fiveButton.isEnabled = true
        sixButton.isEnabled = true
        sevenButton.isEnabled = true
        eightButton.isEnabled = true
        nineButton.isEnabled = true
    }
    func clearAllText(){
        for label in digitLabels {
            label.text = ""
        }
    }
}
