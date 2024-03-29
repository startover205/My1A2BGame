//
//  InMemoryUserDefaults.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/8/7.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import Foundation

final class InMemoryUserDefaults: UserDefaults {
    private var values = [String: Any]()

    override func object(forKey defaultName: String) -> Any? {
        values[defaultName]
    }
    
    override func set(_ value: Any?, forKey defaultName: String) {
        willChangeValue(forKey: defaultName)
        values[defaultName] = value
        didChangeValue(forKey: defaultName)
    }
    
    func clearAllValues() {
        values.removeAll()
    }
}
