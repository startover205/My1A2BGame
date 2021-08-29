//
//  GuessMatcher.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/29.
//

import Foundation

public typealias GuessMatcher<Delegate: ChallengeDelegate, Secret> = (_ guess: Delegate.Guess, _ secret: Secret) -> (hint: Delegate.Hint?, correct: Bool)
