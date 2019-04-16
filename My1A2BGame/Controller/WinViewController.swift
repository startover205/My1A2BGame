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
    @IBOutlet weak var shareBarBtnItem: UIBarButtonItem!
    @IBAction func dismissKeyboard(_ sender: UITextField) {
    }
    @IBAction func didTapScreen(_ sender: Any) {
        view.endEditing(true)
    }
    
    private lazy var _prepareEmoji: Void = {
        prepareEmoji()
    }()
    private lazy var _emojiAnimation: Void = {
        emojiAnimation()
    }()
    private lazy var _fireworkAnimation: Void = {
        fireworkAnimation()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showResult()
        
        newRecordStackView.alpha = breakNewRecord() ? 1 : 0
        
        _ = _prepareEmoji
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = _emojiAnimation
        _ = _fireworkAnimation
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        presentShareAlert()
    }
    
    @IBAction func confirmBtnPressed(_ sender: Any) {
        addRecordToCoreData()
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
    func presentShareAlert(){
        var activityItems: [Any] = [NSLocalizedString("我在「1A2B Fun!」裡只花", comment: "8th") +
            "\(guessCount)" +
            NSLocalizedString("次就猜贏了！快來挑戰我！", comment: "8th")]
        activityItems.append(Constants.appStoreDownloadUrl)
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        if let screenShotImage = UIGraphicsGetImageFromCurrentImageContext() {
            activityItems.append(screenShotImage)
        }
        UIGraphicsEndImageContext()
        
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if UIDevice().model == "iPad" {
            controller.popoverPresentationController?.barButtonItem = shareBarBtnItem
        }
        present(controller, animated: true, completion: nil)
    }
    func addRecordToCoreData(){
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
                let alert = UIAlertController(title: NSLocalizedString("紀錄完成！", comment: "2nd"), message: nil, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: NSLocalizedString("確定", comment: "2nd"), style: .default, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alert.addAction(ok)
                
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: NSLocalizedString("紀錄失敗", comment: "2nd"), message:                   NSLocalizedString("對不起，請重新再試一次", comment: "2nd"), preferredStyle: .alert)
                
                let ok = UIAlertAction(title: NSLocalizedString("確定", comment: "2nd"), style: .default)
                
                alert.addAction(ok)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak emitterLayer] in
            emitterLayer?.removeFromSuperlayer()
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
    func prepareEmoji(){
        self.emojiLabel.transform = CGAffineTransform(translationX: 0, y:-view.frame.height)
    }
    func emojiAnimation(){
        UIView.animate(withDuration: 4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
            
            self.emojiLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            
        })
    }
    func fireworkAnimation(){
        for i in 0...20 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) { [weak self] in
                self?.showFirework()
            }
        }
    }
}

