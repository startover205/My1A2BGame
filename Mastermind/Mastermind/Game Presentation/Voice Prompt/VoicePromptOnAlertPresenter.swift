//
//  VoicePromptOnAlertPresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/27.
//

import Foundation

public final class VoicePromptOnAlertPresenter {
    private init() {}
    
    public static var alertTitle: String {
        NSLocalizedString("VOICE_PROMPT_ON_ALERT_TITLE",
                          tableName: "VoicePrompt",
                          bundle: Bundle(for: VoicePromptOnAlertPresenter.self),
                          comment: "Alert title for turning on voice prompt function")
    }
    
    public static var alertMessage: String {
        NSLocalizedString("VOICE_PROMPT_ON_ALERT_MESSAGE",
                          tableName: "VoicePrompt",
                          bundle: Bundle(for: VoicePromptOnAlertPresenter.self),
                          comment: "Alert message for turning on voice prompt function")
    }
    
    public static var alertConfirmTitle: String {
        NSLocalizedString("VOICE_PROMPT_ON_ALERT_CONFIRM_TITLE",
                          tableName: "VoicePrompt",
                          bundle: Bundle(for: VoicePromptOnAlertPresenter.self),
                          comment: "Alert confirm title for turning on voice prompt function")
    }
}
