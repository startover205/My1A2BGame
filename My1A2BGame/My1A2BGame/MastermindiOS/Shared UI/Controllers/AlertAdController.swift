//
//  AlertAdController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/3/31.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import UIKit

/// 時間到才能按取消
class AlertAdController: UIViewController {
    
    @IBOutlet weak var countDownProgressView: UIProgressView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var adBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    typealias AdHandler = ()->()
    typealias CancelHandler = ()->()
    private var confirmHandler: AdHandler?
    private var cancelHandler: CancelHandler?
    private var countDownTime = 5.0
    private var titleString: String
    private var message: String?
    private var cancelMessage: String
    
    private weak var adCountDownTimer: Timer?
    private weak var progressCountDownTimer: Timer?
    
    private var currentProgress = 0.0
    private lazy var _startCounting: Void = {
        startCounting()
    }()
    private lazy var _shakeAdIcon: Void = {
        shakeAdIcon()
    }()
    private lazy var _shakeAdIconSecond: Void = {
        shakeAdIcon()
    }()
    
    init(title: String, message: String? = nil, cancelMessage: String, countDownTime: Double, confirmHandler: AdHandler? = nil, cancelHandler: CancelHandler? = nil) {
        
        self.titleString = title
        self.message = message
        self.cancelMessage = cancelMessage
        self.countDownTime = countDownTime
        self.confirmHandler = confirmHandler
        self.cancelHandler = cancelHandler
        
        super.init(nibName: String(describing: AlertAdController.self), bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelBtn.alpha = 0
        cancelBtn.setTitle(cancelMessage, for: .normal)
        titleLabel.text = titleString
        messageLabel.text = message
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = _startCounting
    }
    
    deinit {
        print("deinit file: \(#file)")
        progressCountDownTimer?.invalidate()
        adCountDownTimer?.invalidate()
    }
    
    @IBAction func adBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.confirmHandler?()
        })
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        cancelHandler?()
    }
}

// MARK: - Private
private extension AlertAdController {
    
    func startCounting(){
        
        adCountDownTimer = Timer.scheduledTimer(timeInterval: countDownTime, target: self, selector: #selector(adDidCountDown), userInfo: nil, repeats: false)
        
        progressCountDownTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(progressDidCountDown), userInfo: nil, repeats: true)
    }
    
    @objc
    func adDidCountDown(){
        UIView.animate(withDuration: 0.25) {
            self.cancelBtn.alpha = 1
        }
        self.addButtonBorder()
        adCountDownTimer?.invalidate()
    }
    
    @objc
    func progressDidCountDown(){
        self.currentProgress += 0.1 / countDownTime
        self.countDownProgressView.setProgress(Float(currentProgress), animated: true)
        
        if self.currentProgress >= 0.1 {
            _ = _shakeAdIcon
        }
        
        if self.currentProgress >= 0.5 {
            _ = _shakeAdIconSecond
        }
        
        if self.currentProgress >= 1 {
            progressCountDownTimer?.invalidate()
        }
    }
    
    func shakeAdIcon(){

            self.adBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 36)
        
        UIView.animate(withDuration: 1.25, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, options: [], animations: {
            
            self.adBtn.transform = .identity
            
        }, completion: nil)
    }
    
    func addButtonBorder(){
        let border = CALayer()
        border.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        border.frame = .init(x: 0, y: 0, width: cancelBtn.bounds.width, height: 1)
        cancelBtn.layer.addSublayer(border)
    }
}
