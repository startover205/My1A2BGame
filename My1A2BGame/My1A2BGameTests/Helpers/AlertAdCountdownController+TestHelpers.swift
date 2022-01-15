//
//  AlertAdCountdownController+TestHelpers.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2022/1/15.
//  Copyright © 2022 Ming-Ta Yang. All rights reserved.
//

import My1A2BGame

extension AlertAdCountdownController {
    func alertTitle() -> String? { titleLabel.text }
    
    func alertMessage() -> String? { messageLabel.text }
    
    func dismissAction() -> String? { cancelBtn.title(for: .normal) }
    
    func simulateUserDismissAlert() {
        cancelBtn.sendActions(for: .touchUpInside)
    }
    
    func simulateUserConfirmDisplayingAd() {
        adBtn.sendActions(for: .touchUpInside)
    }
}
