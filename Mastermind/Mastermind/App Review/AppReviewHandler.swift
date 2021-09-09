//
//  PromptAppReviewHandler.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/8/19.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

public protocol AppReviewHandler {
    func markProcessCompleteOneTime()
    func askForAppReviewIfAppropriate(completion: ((Bool) -> Void)?)
}
