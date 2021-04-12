//
//  ImageQualityTests.swift
//  BumblebeeDetectorTests
//
//  Created by Marcin Kiliszek on 12/04/2021.
//

import XCTest

class ImageQualityTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testImageSharpness() throws {
        if let beeImage = UIImage(named: "bee_square", in: Bundle(for: type(of: self)), compatibleWith: nil) {
            let sut = ImageQuality()
            
            var testImage: UIImage? = nil
            var testStDev: Double? = nil
            var testMean: Double? = nil
            
            (testImage, testStDev, testMean) = sut.imageSharpness(image: beeImage)
            
            XCTAssertNotNil(testImage)
            XCTAssertNotNil(testStDev)
            XCTAssertNotNil(testMean)
        } else {
            XCTFail("Failed to load the test image")
        }
    }
    
    func testSequenceSharpnessStDev() throws {
        if let beeImage = UIImage(named: "bee_square", in: Bundle(for: type(of: self)), compatibleWith: nil) {
            let sut = ImageQuality()
            
            let testStDevs = sut.sequenceSharpnessStDev(images: [beeImage, beeImage])
            
            XCTAssertFalse(testStDevs.isEmpty)
        } else {
            XCTFail("Failed to load the test image")
        }
    }

}
