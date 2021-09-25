//
//  VoicePromptViewController.swift
//  MastermindiOS
//
//  Created by Ming-Ta Yang on 2021/8/5.
//

import UIKit
import Mastermind
import AVFoundation

private extension UserDefaults {
    @objc dynamic var VOICE_PROMPT: Bool { bool(forKey: "VOICE_PROMPT") }
}

public final class VoicePromptViewController: NSObject {
    private let voicePromptKey = "VOICE_PROMPT"
    
    private(set) public lazy var view: UISwitch = {
        let view = UISwitch()
        view.isOn = userDefaults.bool(forKey: voicePromptKey)
        view.addTarget(self, action: #selector(voicePromptToggled), for: .valueChanged)
        
        userDefaultsObservation = userDefaults.observe(\.VOICE_PROMPT, options: [.new], changeHandler: { (defaults, change) in
            view.isOn = change.newValue!
        })
        
        return view
    }()
    
    private let userDefaults: UserDefaults
    private let synthesizer: AVSpeechSynthesizer
    private let onToggleSwitch: (Bool) -> Void
    private var userDefaultsObservation: NSKeyValueObservation?

    public init(userDefaults: UserDefaults, synthesizer: AVSpeechSynthesizer = .init(), onToggleSwitch: @escaping ((Bool) -> Void)) {
        self.userDefaults = userDefaults
        self.synthesizer = synthesizer
        self.onToggleSwitch = onToggleSwitch
    }
    
    
    @objc private func voicePromptToggled() {
        userDefaults.setValue(view.isOn, forKey: voicePromptKey)
        onToggleSwitch(view.isOn)
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
