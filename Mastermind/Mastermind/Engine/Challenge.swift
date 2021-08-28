//
//  Challenge.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/8/26.
//

public final class Challenge {
    private init(flow: Any) {
        self.flow = flow
    }
    
    private let flow: Any
    
    public static func start<Secret, Delegate: ChallengeDelegate>(secret: Secret, maxChanceCount: Int, matchGuess: @escaping GuessMatcher<Delegate, Secret>, delegate: Delegate) -> Challenge  {
        let flow = Flow(maxChanceCount: maxChanceCount, secret: secret, matchGuess: matchGuess, delegate: delegate)
        flow.start()
        return Challenge(flow: flow)
    }
}
