//
//  SharedLocalizationTestHelpers.swift
//  MastermindTests
//
//  Created by Ming-Ta Yang on 2021/9/27.
//

import XCTest

func assertLocalizedKeyAndValuesExist(in presentationBundle: Bundle, _ table: String, for fileTypes: [String] = ["strings"], file: StaticString = #filePath, line: UInt = #line) {
    let localizationBundles = allLocalizationBundles(in: presentationBundle, file: file, line: line)
    let localizedStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table, for: fileTypes, file: file, line: line)
    
    localizationBundles.forEach { (bundle, localization) in
        localizedStringKeys.forEach { key in
            let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)
            
            if localizedString == key {
                let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
                
                XCTFail("Missing \(language) (\(localization)) localized string for key: '\(key)' in table: '\(table)'", file: file, line: line)
            }
        }
    }
}

private typealias LocalizedBundle = (bundle: Bundle, localization: String)

private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #filePath, line: UInt = #line) -> [LocalizedBundle] {
    return bundle.localizations.compactMap { localization in
        guard
            let path = bundle.path(forResource: localization, ofType: "lproj"),
            let localizedBundle = Bundle(path: path)
        else {
            XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line: line)
            return nil
        }
        
        return (localizedBundle, localization)
    }
}

private func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, for fileTypes: [String], file: StaticString = #filePath, line: UInt = #line) -> Set<String> {
    return bundles.reduce([]) { (acc, current) in
        var allKeys = [String]()
        
        fileTypes.forEach { type in
            if
                let path = current.bundle.path(forResource: table, ofType: type),
                let strings = NSDictionary(contentsOfFile: path),
                let keys = strings.allKeys as? [String] {
                allKeys.append(contentsOf: keys)
            } else {
                XCTFail("Couldn't load localized strings from \"\(type)\" file for localization: \(current.localization)", file: file, line: line)
            }
        }
        
        return acc.union(Set(allKeys))
    }
}
