//
//  WinViewController.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2018/5/31.
//  Copyright © 2018年 Ming-Ta Yang. All rights reserved.
//

import UIKit
import GameKit
import StoreKit
import CoreData

public protocol WinnerStore {
    var totalCount: Int { get }
    
    func fetchAllObjects() -> [GameWinner]
    
    func createObject() -> GameWinner
    
    func delete(object: GameWinner)
    
    func saveContext(completion: SaveDoneHandler?)
}

public protocol AdvancedWinnerStore {
    var totalCount: Int { get }
    
    func fetchAllObjects() -> [AdvancedGameWinner]
    
    func createObject() -> AdvancedGameWinner
    
    func delete(object: AdvancedGameWinner)
    
    func saveContext(completion: SaveDoneHandler?)
}

public class GameWinner {
    public init(name: String?, guessTimes: Int16, spentTime: TimeInterval, winner: Winner) {
        self.name = name
        self.guessTimes = guessTimes
        self.spentTime = spentTime
        self._winner = winner
    }
    
    var name: String? {
        didSet {
            _winner.name = name
        }
    }
    var guessTimes: Int16 {
        didSet {
            _winner.guessTimes = guessTimes
        }
    }
    var spentTime: TimeInterval {
        didSet {
            _winner.spentTime = spentTime
        }
    }
    let _winner: Winner
}

public class AdvancedGameWinner {
    internal init(name: String?, guessTimes: Int16, spentTime: TimeInterval, winner: AdvancedWinner) {
        self.name = name
        self.guessTimes = guessTimes
        self.spentTime = spentTime
        self._winner = winner
    }
    
    var name: String? {
        didSet {
            _winner.name = name
        }
    }
    var guessTimes: Int16 {
        didSet {
            _winner.guessTimes = guessTimes
        }
    }
    var spentTime: TimeInterval {
        didSet {
            _winner.spentTime = spentTime
        }
    }
    let _winner: AdvancedWinner
}

extension Winner {
    func toModel() -> GameWinner {
        GameWinner(name: name, guessTimes: guessTimes, spentTime: spentTime, winner: self)
    }
}

extension AdvancedWinner {
    func toModel() -> AdvancedGameWinner {
        AdvancedGameWinner(name: name, guessTimes: guessTimes, spentTime: spentTime, winner: self)
    }
}

extension CoreDataManager: WinnerStore where T == Winner {
    func fetchAllObjects() -> [GameWinner] {
        fetchAllObjects().map { $0.toModel() }
    }
    
    func createObject() -> GameWinner {
        createObject().toModel()
    }
    
    func delete(object: GameWinner) {
        if let objectToDelete = fetchAllObjects().filter({ $0.spentTime == object.spentTime }).first {
            delete(object: objectToDelete)
        }
    }
}

extension CoreDataManager: AdvancedWinnerStore where T == AdvancedWinner {
    func fetchAllObjects() -> [AdvancedGameWinner] {
        fetchAllObjects().map { $0.toModel() }
    }
    
    func createObject() -> AdvancedGameWinner {
        createObject().toModel()
    }
    
    func delete(object: AdvancedGameWinner) {
        if let objectToDelete = fetchAllObjects().filter({ $0.spentTime == object.spentTime }).first {
            delete(object: objectToDelete)
        }
    }
}


public class WinViewController: UIViewController {
    
    public var guessCount = 0
    public var spentTime = 99999.9
    public var isAdvancedVersion = false
    
//    public var advancedWinnerCoreDataManager: CoreDataManager<AdvancedWinner>?
    public var winnerStore: WinnerStore?
    public var advancedWinnerStore: AdvancedWinnerStore?
    public var userDefaults: UserDefaults?
    
    @IBOutlet private(set) public weak var winLabel: UILabel!
    @IBOutlet private(set) public weak var guessCountLabel: UILabel!
    @IBOutlet private(set) public weak var emojiLabel: UILabel!
    @IBOutlet private(set) public weak var nameLabel: UITextField!
    @IBOutlet private(set) public weak var confirmBtn: UIButton!
    @IBOutlet private(set) public weak var newRecordStackView: UIStackView!
    @IBOutlet private(set) public weak var shareBarBtnItem: UIBarButtonItem!
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
    
    public convenience init(guessCount: Int, spentTime: TimeInterval, isAdvancedVersion: Bool) {
        self.init()
        self.guessCount = guessCount
        self.spentTime = spentTime
        self.isAdvancedVersion = isAdvancedVersion
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        showResult()
        
        if isAdvancedVersion{
            newRecordStackView.alpha = breakNewRecordAdvanced() ? 1 : 0
            winLabel.text =  NSLocalizedString("5A0B!! You won!!", comment: "")
        } else {
            newRecordStackView.alpha = breakNewRecord() ? 1 : 0
            winLabel.text =  NSLocalizedString("4A0B!! You won!!", comment: "")
        }
        
        _ = _prepareEmoji
        
        if #available(iOS 10.3, *) {
            tryToAskForReview()
        } 
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = _emojiAnimation
        _ = _fireworkAnimation
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        presentShareAlert()
    }
    
    @IBAction func confirmBtnPressed(_ sender: Any) {
        isAdvancedVersion ? addRecordToAdvancedWinnerCoreData() : addRecordToWinnerCoreData()
    }
}

// MARK: - UITextFieldDelegate
extension WinViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldString = textField.text! as NSString
        let newString = oldString.replacingCharacters(in: range, with: string)
        
        confirmBtn.isEnabled = !newString.isEmpty
        
        return true
    }
}

// MARK: - Core Data
private extension WinViewController {
    func breakNewRecord() -> Bool {
        guard let coreDataManager = winnerStore else { return false }
        
        if coreDataManager.totalCount < 10 {
            return true
        } else {
            let lastPlace = coreDataManager.fetchAllObjects().last
            return guessCount < (lastPlace?.guessTimes)!
        }
    }
    func breakNewRecordAdvanced() -> Bool {
        guard let coreDataManager = advancedWinnerStore else { return false }
        
        if coreDataManager.totalCount < 10 {
            return true
        } else {
            let lastPlace = coreDataManager.fetchAllObjects().last
            return Int16(guessCount) < (lastPlace?.guessTimes)!
        }
    }
    func addRecordToAdvancedWinnerCoreData(){
        guard let coreDataManager = advancedWinnerStore else { return }

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
                let alert = UIAlertController(title: NSLocalizedString("Record Complete!", comment: "2nd"), message: nil, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "2nd"), style: .default, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alert.addAction(ok)
                
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Failed to Make a Record", comment: "2nd"), message: NSLocalizedString("Sorry. Please try agin.", comment: "2nd"), preferredStyle: .alert)
                
                let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "2nd"), style: .default)
                
                alert.addAction(ok)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    func addRecordToWinnerCoreData(){
        guard let coreDataManager = winnerStore else { return }
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
                let alert = UIAlertController(title: NSLocalizedString("Record Complete!", comment: "2nd"), message: nil, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "2nd"), style: .default, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alert.addAction(ok)
                
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Failed to Make a Record", comment: "2nd"), message:                   NSLocalizedString("Sorry. Please try agin.", comment: "2nd"), preferredStyle: .alert)
                
                let ok = UIAlertAction(title: NSLocalizedString("OK", comment: "2nd"), style: .default)
                
                alert.addAction(ok)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Private
private extension WinViewController {
    func presentShareAlert(){
        let format = NSLocalizedString("I won 1A2B Fun! with guessing only %d times! Come challenge me!", comment: "8th")
        var activityItems: [Any] = [String.localizedStringWithFormat(format, guessCount)]
        activityItems.append(Constants.appStoreDownloadUrl)
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        if let screenShotImage = UIGraphicsGetImageFromCurrentImageContext() {
            activityItems.append(screenShotImage)
        }
        UIGraphicsEndImageContext()
        
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = shareBarBtnItem
        present(controller, animated: true, completion: nil)
    }
  
    func showResult(){
        let format = NSLocalizedString("You guessed %d times", comment: "")
        guessCountLabel.text = String.localizedStringWithFormat(format, guessCount)
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
        emitterLayer.renderMode = CAEmitterLayerRenderMode.oldestLast
        view.layer.insertSublayer(emitterLayer, at: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak emitterLayer] in
            emitterLayer?.removeFromSuperlayer()
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
    @available(iOS 10.3, *)
    func tryToAskForReview(){
        
        var count = userDefaults?.integer(forKey: UserDefaults.Key.processCompletedCount) ?? 0
        count += 1
        userDefaults?.set(count, forKey: UserDefaults.Key.processCompletedCount)
        
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            assertionFailure("Expected to find a bundle version in the info dictionary")
            return
        }
        
        let lastVersionPromptedForReview = userDefaults?.string(forKey: UserDefaults.Key.lastVersionPromptedForReview)
        
        if count >= 3 && currentVersion != lastVersionPromptedForReview {
            let twoSecondsFromNow = DispatchTime.now() + 2.0
            DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) { [weak self] in
                if self?.navigationController?.topViewController is WinViewController {
                    SKStoreReviewController.requestReview()
                    self?.userDefaults?.set(currentVersion, forKey: UserDefaults.Key.lastVersionPromptedForReview)
                }
            }
        }
    }
}

