//
//  GiveUpConfirmViewModel.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/26.
//

public struct GiveUpConfirmViewModel {
    public let message: String
    public let confirmAction: String
    public let cancelAction: String
    public let confirmCallback: () -> Void
}
