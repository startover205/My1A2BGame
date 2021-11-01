//
//  MoreUIIntegrationTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/26.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
@testable import My1A2BGame

public final class MoreUIComposer {
    private init() {}
    
    static func more() -> SettingsTableViewController {
        let settingsController = UIStoryboard(name: "More", bundle: .main).instantiateViewController(withIdentifier: "SettingsTableViewController") as! SettingsTableViewController
        
        return settingsController
    }
}

class MoreUIIntegrationTests: XCTestCase {

    func test_selectFAQ_navigatesToFAQView() throws {
        let sut = makeSUT()
        let nav = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        sut.simulateSelectFAQ()
        RunLoop.current.run(until: Date())
        
        let faq = try XCTUnwrap(nav.topViewController as? FAQViewController)
        XCTAssertEqual(faq.question(at: 0), localized("QUESTION_AD_NOT_SHOWING"))
        XCTAssertEqual(faq.answer(at: 0), localized("ANSWER_AD_NOT_SHOWING"))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SettingsTableViewController {
        let sut = MoreUIComposer.more()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Localizable"
        let bundle = Bundle.main
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

private extension SettingsTableViewController {
    func simulateSelectFAQ() {
        performSegue(withIdentifier: "faq", sender: self)
    }
}
