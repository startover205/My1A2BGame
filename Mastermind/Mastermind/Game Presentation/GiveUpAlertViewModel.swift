//
//  GiveUpAlertViewModel.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/9/26.
//

public struct GiveUpAlertViewModel {
    public let title: String
    public let confirmTitle: String
    public let cancelTitle: String
    public let confirmCallBack: () -> Void
}
