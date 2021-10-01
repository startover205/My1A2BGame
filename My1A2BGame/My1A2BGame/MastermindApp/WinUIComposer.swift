//
//  WinUIComposer.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/20.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import GameKit
import StoreKit
import Mastermind
import MastermindiOS

extension WinPresenter: WinViewControllerDelegate { }

public final class WinUIComposer {
    private init() {}
    
    public static func winComposedWith(score: Score, digitCount: Int, recordLoader: RecordLoader, currentDate: @escaping () -> Date = Date.init, appDownloadURL: String, activityViewControllerFactory: @escaping ActivityViewControllerFactory = UIActivityViewController.init) -> WinViewController {
        
        let winViewController = makeWinViewController()
        winViewController.guessCount = score.guessCount
        winViewController.showFireworkAnimation = showFireworkAnimation(on:)
        
        let winPresenter = WinPresenter(
            digitCount: digitCount,
            winView: WeakRefVirtualProxy(winViewController))
        winViewController.delegate = winPresenter
        
        let message = String.localizedStringWithFormat(WinPresenter.shareMessageFormat, score.guessCount)
        let shareController = ShareViewController(
            hostViewController: winViewController,
            sharing: { [unowned winViewController] in
            return makeSharingItems(message: message, appDownloadURL: appDownloadURL, snapshotView: winViewController.view)
            }, activityViewControllerFactory: activityViewControllerFactory)

        winViewController.shareViewController = shareController
        
        let presentationAdapter = RecordPresentationAdapter(
            loader: recordLoader,
            guessCount: score.guessCount,
            guessTime: score.guessTime,
            currentDate: currentDate)
        let recordViewController = winViewController.recordViewController!
        recordViewController.hostViewController = winViewController
        recordViewController.delegate = presentationAdapter
        
        presentationAdapter.presenter = RecordPresenter(
            validationView: WeakRefVirtualProxy(recordViewController),
            saveView: WeakRefVirtualProxy(recordViewController))
        
        return winViewController
    }
    
    private static func makeSharingItems(message: String, appDownloadURL: String, snapshotView: UIView) -> [Any] {
        var sharingItems = [Any]()
        sharingItems.append(message)
        sharingItems.append(appDownloadURL)
        
        UIGraphicsBeginImageContextWithOptions(snapshotView.bounds.size, false, UIScreen.main.scale)
        snapshotView.drawHierarchy(in: snapshotView.bounds, afterScreenUpdates: true)
        if let screenShotImage = UIGraphicsGetImageFromCurrentImageContext() {
            sharingItems.append(screenShotImage)
        }
        UIGraphicsEndImageContext()
        
        return sharingItems
    }
    
    private static func makeWinViewController() -> WinViewController {
        let winController = UIStoryboard(name: "Win", bundle: .init(for: WinViewController.self)).instantiateViewController(withIdentifier: "WinViewController") as! WinViewController
        
        return winController
    }
    
    private static func showFireworkAnimation(on view: UIView) {
        func showFirework(on view: UIView){
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
            
            emitterLayer.emitterPosition = CGPoint(x: view.frame.width * CGFloat(randomX) , y: view.frame.height * CGFloat(randomY))
            
            emitterLayer.emitterCells = cellsForFirework
            emitterLayer.renderMode = CAEmitterLayerRenderMode.oldestLast
            view.layer.insertSublayer(emitterLayer, at: 0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak emitterLayer] in
                emitterLayer?.removeFromSuperlayer()
            }
        }
        
        for i in 0...20 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) { [weak view] in
                guard let view = view else { return }
                showFirework(on: view)
            }
        }
    }
}

final class RecordPresentationAdapter: RecordViewControllerDelegate {
    private let loader: RecordLoader
    private let guessCount: Int
    private let guessTime: TimeInterval
    private let currentDate: (() -> Date)
    var presenter: RecordPresenter?

    public init(loader: RecordLoader, guessCount: Int, guessTime: TimeInterval, currentDate: @escaping (() -> Date)) {
        self.loader = loader
        self.guessCount = guessCount
        self.guessTime = guessTime
        self.currentDate = currentDate
    }
    
    public func didRequestValidateRecord() {
        presenter?.didValidateRecord(loader.validate(score: (guessCount, guessTime)))
    }
    
    public func didRequestSaveRecord(playerName: String) {
        let record = PlayerRecord(playerName: playerName, guessCount: guessCount, guessTime: guessTime, timestamp: currentDate())
        
        do {
            try loader.insertNewRecord(record)
            presenter?.didSaveRecordSuccessfully()
        } catch {
            presenter?.didSaveRecord(with: error)
        }
    }
}
