//
//  CountdownAlertController.swift
//  EasyTimer
//
//  Created by Ming-Ta Yang on 2019/3/31.
//  Copyright © 2019年 Sam's App Lab. All rights reserved.
//

import UIKit

public typealias AsyncAfter = (TimeInterval, @escaping () -> Void) -> Void

public final class CountdownAlertController: UIViewController {
    @IBOutlet weak private(set) public var ountdownProgressView: UIProgressView!
    @IBOutlet weak private(set) public var cancelButton: UIButton!
    @IBOutlet weak private(set) public var confirmButton: UIButton!
    @IBOutlet weak private(set) public var titleLabel: UILabel!
    @IBOutlet weak private(set) public var messageLabel: UILabel!
    
    private let onConfirm: (() -> Void)?
    private let onCancel: (() -> Void)?
    private let countdownTime: TimeInterval
    private let alertTitle: String
    private let message: String?
    private let cancelAction: String
    private let animate: Animate
    private let asyncAfter: AsyncAfter
    
    private var isFirstTimeAppear = true
    
    public init(
        title: String,
        message: String? = nil,
        cancelAction: String,
        countdownTime: TimeInterval,
        onConfirm: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil,
        animate: @escaping Animate = UIView.animate,
        asyncAfter: @escaping AsyncAfter = {
            DispatchQueue.main.asyncAfter(deadline: .now() + $0, execute: $1)
        }
    ) {
        
        self.alertTitle = title
        self.message = message
        self.cancelAction = cancelAction
        self.countdownTime = countdownTime
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self.animate = animate
        self.asyncAfter = asyncAfter
        
        super.init(nibName: "CountdownAlertController", bundle: .init(for: CountdownAlertController.self))
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.setTitle(cancelAction, for: .normal)
        titleLabel.text = alertTitle
        messageLabel.text = message
        
        addButtonBorder()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstTimeAppear {
            isFirstTimeAppear = false
            
            asyncAfter(countdownTime) { [weak self] in
                self?.onCancel?()
            }
            
            ountdownProgressView.progress = 1.0
            
            animate(countdownTime, { [weak self] in
                self?.ountdownProgressView.layoutIfNeeded()
            }, nil)
            
            shakeImage(durationPerShake: countdownTime/3, shakeCount: 3)
        }
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        onConfirm?()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        onCancel?()
    }
}

private extension CountdownAlertController {
    func shakeImage(durationPerShake: TimeInterval, shakeCount: Int = 0) {
        if shakeCount <= 0 { return }
        
        confirmButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 36)
        
        UIView.animate(withDuration: durationPerShake, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, options: [.allowUserInteraction], animations: { [weak self] in

            self?.confirmButton.transform = .identity
            
        }, completion: { [weak self]  _ in
            self?.shakeImage(durationPerShake: durationPerShake, shakeCount: shakeCount-1)
        })
    }
    
    func addButtonBorder() {
        let border = CALayer()
        border.backgroundColor = UIColor.lightGray.cgColor
        border.frame = .init(x: 0, y: 0, width: cancelButton.bounds.width, height: 0.5)
        cancelButton.layer.addSublayer(border)
    }
}
