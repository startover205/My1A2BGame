//
//  WinViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/5/31.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import GameKit

class WinViewController: UIViewController {
    
    var guessCount = 0
    var spentTime = 99999.9
    
    @IBOutlet weak var guessCountLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var newRecordStackView: UIStackView!
    @IBAction func dismissKeyboard(_ sender: UITextField) {
    }
    @IBAction func didTapScreen(_ sender: Any) {
        view.endEditing(true)
    }
    
    private lazy var prepareEmoji: Void = {
        self.emojiLabel.transform = CGAffineTransform(translationX: 0, y:-view.frame.height)
        return
    }()
    private lazy var emojiAnimation: Void = {
        UIView.animate(withDuration: 4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
            
            self.emojiLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            
        })
        return
    }()
    private lazy var fireworkAnimation: Void = {
        for i in 0...20 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                self.showFirework()
            }
        }
        return
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showResult()
        
        newRecordStackView.alpha = breakNewRecord() ? 1 : 0
        
        _ = prepareEmoji
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = emojiAnimation
        _ = fireworkAnimation
    }
    
    @IBAction func confirmBtnPressed(_ sender: Any) {
        
        if coreDataManager.totalCount == 10{
            let oldWinner = coreDataManager.fetchAllObjects().last!
            coreDataManager.delete(object: oldWinner)
        }
        
        let newWinner = coreDataManager.createObject()
        newWinner.name = nameLabel.text
        newWinner.guessTimes = Int16(guessCount)
        newWinner.spentTime = spentTime
        
        coreDataManager.saveContext { (success) in
            if success {
                let alert = UIAlertController(title: "紀錄完成！".localized, message: nil, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "確定".localized, style: .default, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alert.addAction(ok)
                
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "紀錄失敗".localized, message: "對不起，請重新再試一次。".localized, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "確定".localized, style: .default)
                
                alert.addAction(ok)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension WinViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldString = textField.text! as NSString
        let newString = oldString.replacingCharacters(in: range, with: string)
        
        confirmBtn.isEnabled = !newString.isEmpty
        
        return true
    }
}

// MARK: - Private
extension WinViewController {
    func showResult(){
        guessCountLabel.text = NSLocalizedString("共猜了", comment: "") + " \(guessCount) " + NSLocalizedString("次", comment: "")
    }
    
    func showFirework(){
        
        var cellsForFirework = [CAEmitterCell]()
        
        let cellRect = CAEmitterCell()
        let cellHeart = CAEmitterCell()
        let cellStar = CAEmitterCell()
        
        cellsForFirework.append(cellRect)
        cellsForFirework.append(cellStar)
        cellsForFirework.append(cellHeart)
        
        for cell in cellsForFirework {
            cell.birthRate = 4500
            cell.lifetime = 2
            cell.velocity = 100
            cell.scale = 0
            cell.scaleSpeed = 0.2
            cell.yAcceleration = 30
            cell.color = #colorLiteral(red: 1, green: 0.8302680122, blue: 0.3005099826, alpha: 1)
            cell.greenRange = 20
            cell.spin = CGFloat.pi
            cell.spinRange = CGFloat.pi * 3/4
            cell.emissionRange = CGFloat.pi
            cell.alphaSpeed = -1 / cell.lifetime
            
            cell.beginTime = CACurrentMediaTime()
            cell.timeOffset = 1
        }
        
        cellStar.contents = #imageLiteral(resourceName: "flake_star").cgImage
        cellHeart.contents = #imageLiteral(resourceName: "flake_heart").cgImage
        cellRect.contents = #imageLiteral(resourceName: "flake_rectangle").cgImage
        
        let emitterLayer = CAEmitterLayer()
        
        let randomDistribution = GKRandomDistribution(lowestValue: 1, highestValue: 8)
        
        var randomX = Double(randomDistribution.nextInt()) / 9
        var randomY = Double(randomDistribution.nextInt()) / 9
        
        while randomX <= 7/9 , randomX >= 2/9, randomY <= 7/9, randomY >= 2/9 {
            randomX = Double(randomDistribution.nextInt()) / 9
            randomY = Double(randomDistribution.nextInt()) / 9
        }
        
        emitterLayer.emitterPosition = CGPoint(x: self.view.frame.width * CGFloat(randomX) , y: self.view.frame.height * CGFloat(randomY))
        
        emitterLayer.emitterCells = cellsForFirework
        emitterLayer.renderMode = kCAEmitterLayerOldestLast
        view.layer.insertSublayer(emitterLayer, at: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            emitterLayer.removeFromSuperlayer()
        }
        
    }
    
    func breakNewRecord() -> Bool {
        
        if coreDataManager.totalCount < 10 {
            return true
        } else {
            let lastPlace = coreDataManager.fetchAllObjects().last
            return Int16(guessCount) < (lastPlace?.guessTimes)!
        }
    }
}

