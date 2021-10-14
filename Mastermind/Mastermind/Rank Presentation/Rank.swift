//
//  Rank.swift
//  Mastermind
//
//  Created by Ming-Ta Yang on 2021/10/14.
//

public struct Rank {
    public let title: String
    public let loader: RecordLoader
    
    public init(title: String, loader: RecordLoader) {
        self.title = title
        self.loader = loader
    }
}
