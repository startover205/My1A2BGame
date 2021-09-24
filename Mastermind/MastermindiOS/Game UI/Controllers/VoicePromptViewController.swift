//
//  VoicePromptViewController.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2021/8/5.
//

import UIKit
import Mastermind
import AVFoundation

public final class VoicePromptViewController: NSObject {
    private(set) public lazy var view: UISwitch = {
        let view = UISwitch()
        view.isOn = userDefaults.bool(forKey: "VOICE_PROMPT")
        view.addTarget(self, action: #selector(voicePromptToggled), for: .valueChanged)
        return view
    }()
    
    private let userDefaults: UserDefaults
    private let synthesizer: AVSpeechSynthesizer
    
    public init(userDefaults: UserDefaults, synthesizer: AVSpeechSynthesizer = .init()) {
        self.userDefaults = userDefaults
        self.synthesizer = synthesizer
    }
    
    public var onToggleSwitch: ((Bool) -> Void)?
    
    @objc private func voicePromptToggled() {
        userDefaults.setValue(view.isOn, forKey: "VOICE_PROMPT")
        onToggleSwitch?(view.isOn)
    }
}

extension VoicePromptViewController: UtteranceView{
    public func display(_ viewModel: VoiceMessageViewModel) {
        if view.isOn {
            let speechUtterance = AVSpeechUtterance(string: viewModel.message)
            synthesizer.speak(speechUtterance)
        }
    }
}
