//
//  ImageQualityTests.swift
//  BumblebeeDetectorTests
//
//  Created by Marcin Kiliszek on 12/04/2021.
//

import XCTest

class ImageQualityTests: XCTestCase {

    private var sut: ImageQuality!
    
    override func setUp() {
        super.setUp()
        sut = ImageQuality()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testImageSharpness() throws {
        if let beeImage = UIImage(named: "bee_square", in: Bundle(for: type(of: self)), compatibleWith: nil) {
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
            let testStDevs = sut.sequenceSharpnessStDev(images: [beeImage, beeImage])
            
            XCTAssertFalse(testStDevs.isEmpty)
        } else {
            XCTFail("Failed to load the test image")
        }
    }

}
