//
//  CountdownAlertController+TestHelpers.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2022/1/15.
//  Copyright © 2022 Ming-Ta Yang. All rights reserved.
//

import My1A2BGame
import MastermindiOS

extension CountdownAlertController {
    func alertTitle() -> String? { titleLabel.text }
    
    func alertMessage() -> String? { messageLabel.text }
    
    func cancelAction() -> String? { cancelButton.title(for: .normal) }
    
    func simulateUserDismissAlert() {
        cancelButton.sendActions(for: .touchUpInside)
    }
    
    func simulateUserConfirmDisplayingAd() {
        confirmButton.sendActions(for: .touchUpInside)
    }
}
