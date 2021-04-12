//
//  LocalisationTests.swift
//  BumblebeeDetectorTests
//
//  Created by Marcin Kiliszek on 12/04/2021.
//

import XCTest

class LocalisationTests: XCTestCase {
    
    private var sut: BeeLocaliser!
    
    override func setUp() {
        super.setUp()
        sut = BeeLocaliser()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDetectBeeOnImage() throws {
        if let beeImage = UIImage(named: "bee", in: Bundle(for: type(of: self)), compatibleWith: nil)?.cgImage {
            let testImage = sut.detectBee(onImage: beeImage)
            
            XCTAssertNotNil(testImage)
        } else {
            XCTFail("Failed to load the test image")
        }
    }
    
    func testDetectBeeOnVideo() throws {
        if let beeVideoUrlString = Bundle(for: type(of: self)).path(forResource: "test_video", ofType: "MOV") {
            let beeVideoUrl = URL(fileURLWithPath: beeVideoUrlString)
            
            let detections = sut.detectBee(onVideo: beeVideoUrl, fps: 1)
            
            XCTAssertFalse(detections.isEmpty)
        } else {
            XCTFail("Failed to load the test video")
        }
    }

}
