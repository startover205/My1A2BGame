//
//  LoseViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/7/17.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import SceneKit

class LoseViewController: UIViewController {
    @IBOutlet weak var rainSCNView: SCNView!
    @IBOutlet weak var emojiLabel: UILabel!
    
    private lazy var _rainAnimation: Void = {
        rainAnimation()
    }()
    private lazy var _emojiAnimation: Void = {
        emojiAnimation()
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = _rainAnimation
        _ = _emojiAnimation
    }
}

// MARK: - Private
private extension LoseViewController {
    func rainAnimation(){
        let cell = CAEmitterCell()
        
        cell.birthRate = 60
        cell.lifetime = 3
        cell.velocity = 600
        cell.scale = 1.5
        cell.scaleRange = 0.5
        cell.yAcceleration = -50
        cell.color = #colorLiteral(red: 0.4584070853, green: 0.7182741117, blue: 0.7093148919, alpha: 0.3186001712)
        cell.spinRange = CGFloat.pi / 72
        cell.alphaRange = 0.3
        cell.emissionRange = CGFloat.pi / 36
        cell.emissionLongitude = CGFloat.pi
        
        cell.contents = #imageLiteral(resourceName: "flake_rain_vertical").cgImage
        
        let emitterLayer = CAEmitterLayer()
        
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 20)
        emitterLayer.frame = rect
        emitterLayer.emitterSize = rect.size
        emitterLayer.emitterShape = kCAEmitterLayerLine
        emitterLayer.emitterPosition = CGPoint(x: rect.width / 2 , y: rect.height / 2)
        
        emitterLayer.emitterCells = [cell]
        view.layer.addSublayer(emitterLayer)
    }
    
    func emojiAnimation(){
        UIView.animate(withDuration: 6, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 2, options: [], animations: {
            self.emojiLabel.transform = CGAffineTransform(translationX: 0, y: 10)
            self.emojiLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 9)
        }, completion: nil)
    }
}
