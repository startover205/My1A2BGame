//
//  WeakRefVirtualProxy.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2021/9/17.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Mastermind

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: RecordValidationView where T: RecordValidationView {
    func display(_ viewModel: RecordValidationViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: RecordSaveView where T: RecordSaveView {
    func display(_ viewModel: RecordSaveViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: GameView where T: GameView {
    func displayGameEnd() {
        object?.displayGameEnd()
    }
    
    func display(_ viewModel: LeftChanceCountViewModel) {
        object?.display(viewModel)
    }
    
    func display(_ viewModel: MatchResultViewModel) {
        object?.display(viewModel)
    }
}