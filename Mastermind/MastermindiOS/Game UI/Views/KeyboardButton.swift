//
//  KeyboardButton.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/9/16.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import UIKit

class KeyboardButton: UIButton {
    var defaultBackgroundColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureShadow()
        
        self.defaultBackgroundColor = backgroundColor
        self.setTitleColor(.lightText, for: .disabled)
    }
    
    override var isEnabled: Bool {
        didSet{
            updateUI()
        }
    }
    
    override var isHighlighted: Bool {
        didSet{
            updateUI()
        }
    }
}

// MARK: - Private
private extension KeyboardButton {
    func configureShadow() {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 0.0
        layer.masksToBounds = false
        layer.cornerRadius = 4.0
    }
    func setShadow(showing: Bool, animated: Bool = false){
        layer.shadowOpacity = showing ? 1.0 : 0.0
        
        if animated{
            let animation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowOpacity))
            layer.add(animation, forKey: #keyPath(CALayer.shadowOpacity))
        }
    }
    func updateUI() {
        if !isEnabled{
            backgroundColor = .lightGray
        } else if isHighlighted {
            backgroundColor = .lightGray
        } else {
            backgroundColor = defaultBackgroundColor
        }
        
        setShadow(showing: isEnabled)
    }
}
