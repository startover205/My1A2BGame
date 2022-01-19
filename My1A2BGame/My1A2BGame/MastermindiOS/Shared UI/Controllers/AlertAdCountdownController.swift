//
//  AlertAdCountdownController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/3/31.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import UIKit
import MastermindiOS

public typealias TimerFactory = (TimeInterval, _ repeats: Bool, _ task: @escaping (Timer) -> Void) -> Timer

/// 時間到自動消失
public final class AlertAdCountdownController: UIViewController {
    
    @IBOutlet weak private(set) public var countDownProgressView: UIProgressView!
    @IBOutlet weak private(set) public var cancelButton: UIButton!
    @IBOutlet weak private(set) public var confirmButton: UIButton!
    @IBOutlet weak private(set) public var titleLabel: UILabel!
    @IBOutlet weak private(set) public var messageLabel: UILabel!
    
    private let onConfirm: (() -> Void)?
    private let onCancel: (() -> Void)?
    private(set) public var countdownTime = 5.0
    private let alertTitle: String
    private let message: String?
    private let cancelAction: String
    
    private let timerFactory: TimerFactory
    private let animate: Animate
    private weak var adCountDownTimer: Timer?
    private weak var progressCountDownTimer: Timer?
    
    private var currentProgress = 0.0
    private lazy var _startCounting: Void = {
        startCounting()
    }()
    
    public init(title: String, message: String? = nil, cancelAction: String, countdownTime: Double, onConfirm: (() -> Void)? = nil, onCancel: (() -> Void)? = nil, timerFactory: @escaping TimerFactory = Timer.scheduledTimer, animate: @escaping Animate = UIView.animate) {
        
        self.alertTitle = title
        self.message = message
        self.cancelAction = cancelAction
        self.countdownTime = countdownTime
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self.timerFactory = timerFactory
        self.animate = animate
        
        super.init(nibName: "AlertAdCountdownController", bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        cancelBtn.alpha = 0
        cancelButton.setTitle(cancelAction, for: .normal)
        titleLabel.text = alertTitle
        messageLabel.text = message
        
        cancelButton.alpha = 1
        addButtonBorder()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = _startCounting
    }
    
    deinit {
        progressCountDownTimer?.invalidate()
        adCountDownTimer?.invalidate()
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.onConfirm?()
        })
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.onCancel?()
        }
    }
}

// MARK: - Private
private extension AlertAdCountdownController {
    
    func startCounting(){
        adCountDownTimer = timerFactory(countdownTime, false) { [weak self] _ in
            self?.adDidCountDown()
        }
        
        countDownProgressView.progress = 1.0
        
        animate(countdownTime, { [weak self] in
            self?.countDownProgressView.layoutIfNeeded()
        }, nil)
        
        shakeImage(durationPerShake: countdownTime/3, shakeCount: 3)
    }
    
    func shakeImage(durationPerShake: TimeInterval, shakeCount: Int = 0) {
        if shakeCount <= 0 { return }
        
        confirmButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 36)
        
        UIView.animate(withDuration: durationPerShake, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, options: [], animations: { [weak self] in

            self?.confirmButton.transform = .identity
            
        }, completion: { [weak self]  _ in
            self?.shakeImage(durationPerShake: durationPerShake, shakeCount: shakeCount-1)
        })
    }
    
    /// 計時結束
    @objc
    func adDidCountDown(){
        adCountDownTimer?.invalidate()

        presentingViewController?.dismiss(animated: true) {
            self.onCancel?()
        }
    }
    
    func addButtonBorder(){
        let border = CALayer()
        border.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        border.frame = .init(x: 0, y: 0, width: cancelButton.bounds.width, height: 1)
        cancelButton.layer.addSublayer(border)
    }
}

extension AlertAdCountdownController {
    func tapConfirmButton() {
        onConfirm?()
    }
}
