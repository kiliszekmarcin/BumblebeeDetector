//
//  InterpolationTests.swift
//  BumblebeeDetectorTests
//
//  Created by Marcin Kiliszek on 12/04/2021.
//

import XCTest

class InterpolationTests: XCTestCase {
    
    private var sut: Interpolation!
    
    override func setUp() {
        super.setUp()
        
        if let videoUrlString = Bundle(for: type(of: self)).path(forResource: "test_video", ofType: "MOV") {
            let videoUrl = URL(fileURLWithPath: videoUrlString)
            sut = Interpolation(videoUrl: videoUrl)
        } else {
            XCTFail("Failed to load the test video")
        }
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDetectByInterpolation() throws {
        let detections = sut.detectByInterpolation(fps: 4, threshold: 0.5)
        
        XCTAssertFalse(detections.isEmpty)
    }

}
