//
//  My1A2BGameTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2020/1/1.
//  Copyright © 2020 Ming-Ta Yang. All rights reserved.
//

import XCTest

//class My1A2BGameTests: XCTestCase {
//
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//}

class HelperButtonTests: XCTestCase {
    var button: HelperButton!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        button = HelperButton()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRest() {
        button.reset()
        
        XCTAssert(button.filterState == button.defaultState)
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
