//
//  LoseUIComposer.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/24.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import SceneKit
import Mastermind
import MastermindiOS

public final class LoseUIComposer {
    private init() {}
    
    public static func loseScene() -> LoseViewController {
        let loseViewController = makeLoseViewController()
        loseViewController.viewModel = LosePresenter.loseViewModel
        loseViewController.rainAnimation = rainAnimation(on:)
        
        return loseViewController
    }
    
    private static func rainAnimation(on view: UIView) {
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
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width , height: 20)
        emitterLayer.frame = rect
        emitterLayer.emitterSize = rect.size
        emitterLayer.emitterShape = CAEmitterLayerEmitterShape.line
        emitterLayer.emitterPosition = CGPoint(x: rect.width / 2 , y: rect.height / 2)
        
        emitterLayer.emitterCells = [cell]
        view.layer.addSublayer(emitterLayer)
    }
    
    private static func makeLoseViewController() -> LoseViewController {
        let bundle = Bundle(for: LoseViewController.self)
        let controller = UIStoryboard(name: "Lose", bundle: bundle).instantiateViewController(withIdentifier: String(describing: LoseViewController.self)) as! LoseViewController
        
        return controller
    }
}
