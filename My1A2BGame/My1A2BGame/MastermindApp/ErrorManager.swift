//
//  ErrorManager.swift
//  My1A2BGame
//
//  Created by Ming-Ta Yang on 2019/4/12.
//  Copyright © 2019 Ming-Ta Yang. All rights reserved.
//

import Foundation

struct ErrorManager {
    static func saveError(description: String, date: Date = Date()){
        
        let newMessage = date.description + " " + description + "\n"
        var errorMessage = UserDefaults.standard.string(forKey: "ErrorMessage") ?? "ErrorMessage: \n"
        errorMessage.append(newMessage)
        UserDefaults.standard.set(errorMessage, forKey: "ErrorMessage")
    }
    
    static func loadErrorMessage() -> ErrorMesssge {
        return UserDefaults.standard.string(forKey: "ErrorMessage") ?? "ErrorMessage: \n"
    }
    
    typealias ErrorMesssge = String
}


