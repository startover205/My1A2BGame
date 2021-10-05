//
//  NumberInputPresenter.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/10/4.
//

import Foundation

public final class NumberInputPresenter {
    private init() {}
    
    private static var viewTitle: String {
        NSLocalizedString("VIEW_TITLE",
                          tableName: "NumberInput",
                          bundle: Bundle(for: NumberInputPresenter.self),
                          comment: "Title for number input view")
    }
    
    private static var clearInputAction: String {
        NSLocalizedString("CLEAR_INPUT_ACTION",
                          tableName: "NumberInput",
                          bundle: Bundle(for: NumberInputPresenter.self),
                          comment: "Button for clearing current inputs")
    }
    
    public static var viewModel: NumberInputViewModel {
        .init(viewTitle: Self.viewTitle,
              clearInputAction: Self.clearInputAction)
    }
    
}
