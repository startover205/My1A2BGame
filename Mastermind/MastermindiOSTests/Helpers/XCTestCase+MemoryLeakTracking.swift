//
//  XCTestCase+MemoryLeakTracking.swift
//  MastermindiOSTests
//
//  Created by Ming-Ta Yang on 2022/1/20.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}