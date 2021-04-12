//
//  LocalisationTests.swift
//  BumblebeeDetectorTests
//
//  Created by Marcin Kiliszek on 12/04/2021.
//

import XCTest

class LocalisationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDetectBee() throws {
        if let beeImage = UIImage(named: "bee", in: Bundle(for: type(of: self)), compatibleWith: nil)?.cgImage {
            let localiser = BeeLocaliser()
            let testImage = localiser.detectBee(onImage: beeImage)
            
            XCTAssertNotNil(testImage)
        } else {
            XCTFail("Failed to load the test image")
        }
    }

}
