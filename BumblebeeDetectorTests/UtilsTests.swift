//
//  UtilsTests.swift
//  BumblebeeDetectorTests
//
//  Created by Marcin Kiliszek on 12/04/2021.
//

import XCTest
import CoreLocation

class UtilsTests: XCTestCase {
    
    func testGetVideoMetadata() throws {
        if let videoUrlString = Bundle(for: type(of: self)).path(forResource: "test_video", ofType: "MOV") {
            let videoUrl = URL(fileURLWithPath: videoUrlString)
            
            var firstFrame: UIImage? = nil
            var location: CLLocationCoordinate2D? = nil
            var date: Date? = nil
            
            (firstFrame, location, date) = Utils.getVideoMetadata(url: videoUrl)

            XCTAssertNotNil(firstFrame)
            XCTAssertNotNil(location)
            XCTAssertNotNil(date)
        } else {
            XCTFail("Failed to load the test video")
        }
    }
    
    func testIsoToLocation() throws {
        let isoString = "+53.3717-001.4980+122.192/"
        let correctLocation = CLLocationCoordinate2D(latitude: 53.3717, longitude: -1.498)
        
        let testLocation = Utils.iso6709ToCLLocationCoordinate2D(locationString: isoString)
        
        XCTAssertTrue(correctLocation.latitude == testLocation?.latitude
                    && correctLocation.longitude == testLocation?.longitude)
    }
    
    func testCGRectToCropping() throws {
        let testRect = CGRect(x: 0.5, y: 0.4, width: 0.3, height: 0.15)
        let orgW = 1280.0
        let orgH = 720.0
        
        let testOutput = Utils.detectionCGRectToCropping(cgrect: testRect, orgW: orgW, orgH: orgH)
        let expectedOutput = CGRect(x: 532.0, y: 180.0, width: 216.0, height: 216.0)
        
        XCTAssert(testOutput == expectedOutput)
    }
}
