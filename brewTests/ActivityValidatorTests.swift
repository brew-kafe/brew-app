//
//  ActivityValidatorTests.swift
//  brewTests
//
//  Created by Monserrath Valenzuela on 29/09/25.
//

import XCTest
@testable import brew

final class ActivityValidatorTests: XCTestCase {
    
    func testTitleValidation() {
        XCTAssertTrue(ActivityValidator.isValidTitle("Regar"))
        XCTAssertFalse(ActivityValidator.isValidTitle(""))
        XCTAssertFalse(ActivityValidator.isValidTitle(" "))
        XCTAssertFalse(ActivityValidator.isValidTitle("   \n  \t  "))
    }
    
    func testTitleBoundary() {
        XCTAssertTrue(ActivityValidator.isValidTitle("A"))
        XCTAssertTrue(ActivityValidator.isValidTitle(String(repeating: "X", count: 255)))
        XCTAssertFalse(ActivityValidator.isValidTitle(String(repeating: "X", count: 256)))
    }
}
