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

    @IBOutlet weak var guessCountLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //show left guessCount on screen
        guessCountLabel.text = NSLocalizedString("共猜了", comment: "") + " \(12 - guessCount) " + NSLocalizedString("次", comment: "")
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //emoji animation preparation
           self.emojiLabel.transform = CGAffineTransform(translationX: 0, y:-view.frame.height)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //emoji animation preparation
        UIView.animate(withDuration: 4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 3, options: [.curveEaseOut], animations: {
            
            self.emojiLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }, completion: nil)
        
        //firework animation
        for i in 0...20 {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                self.firework()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //show firework
    func firework(){
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

