//
//  AlertAdController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/3/31.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import UIKit

/// 時間到自動消失
public final class AlertAdCountdownController: UIViewController {
    
    @IBOutlet weak private(set) public var countDownProgressView: UIProgressView!
    @IBOutlet weak private(set) public var cancelBtn: UIButton!
    @IBOutlet weak private(set) public var adBtn: UIButton!
    @IBOutlet weak private(set) public var titleLabel: UILabel!
    @IBOutlet weak private(set) public var messageLabel: UILabel!
    
    private(set) public var confirmHandler: (() -> Void)?
    private(set) public var cancelHandler: (() -> Void)?
    private(set) public var countDownTime = 5.0
    private(set) public var alertTitle: String
    private(set) public var message: String?
    private(set) public var cancelMessage: String
    
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
    
    public init(title: String, message: String? = nil, cancelMessage: String, countDownTime: Double, confirmHandler: (() -> Void)? = nil, cancelHandler: (() -> Void)? = nil) {
        
        self.alertTitle = title
        self.message = message
        self.cancelMessage = cancelMessage
        self.countDownTime = countDownTime
        self.confirmHandler = confirmHandler
        self.cancelHandler = cancelHandler
        
        super.init(nibName: "AlertAdController", bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        cancelBtn.alpha = 0
        cancelBtn.setTitle(cancelMessage, for: .normal)
        titleLabel.text = alertTitle
        messageLabel.text = message
        
        self.cancelBtn.alpha = 1
        self.addButtonBorder()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = _startCounting
    }
    
    deinit {
        progressCountDownTimer?.invalidate()
        adCountDownTimer?.invalidate()
    }
    
    @IBAction func adBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.confirmHandler?()
        })
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.cancelHandler?()
        }
    }
}

// MARK: - Private
private extension AlertAdCountdownController {
    
    func startCounting(){
        adCountDownTimer = Timer.scheduledTimer(timeInterval: countDownTime, target: self, selector: #selector(adDidCountDown), userInfo: nil, repeats: false)
        
        progressCountDownTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(progressDidCountDown), userInfo: nil, repeats: true)
    }
    
    /// 計時結束
    @objc
    func adDidCountDown(){
        adCountDownTimer?.invalidate()

        self.presentingViewController?.dismiss(animated: true) {
            self.cancelHandler?()
        }
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

extension AlertAdCountdownController {
    func tapConfirmButton() {
        confirmHandler?()
    }
}
