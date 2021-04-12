//
//  RequestsTests.swift
//  BumblebeeDetectorTests
//
//  Created by Marcin Kiliszek on 12/04/2021.
//

import XCTest

class RequestsTests: XCTestCase {

    func testSendImages_oneImage() throws {
        if let beeImage = UIImage(named: "bee_square", in: Bundle(for: type(of: self)), compatibleWith: nil) {
            // Create an expectation
            let expectation = self.expectation(description: "Sending a request")
            var predictions: [Prediction] = []
            
            Requests.sendImages(images: [beeImage]) { json in
                // parse json into the classifications array
                if let jsonDict = json as? [String: Any] {
                    if let jsonDeeper = jsonDict["pred"] as? [Any] {
                        for item in jsonDeeper {
                            if let item = item as? [Any] {
                                let species = item[0] as! String
                                let confidence = item[1] as! Double
                                
                                predictions.append(Prediction(species: species, confidence: confidence))
                            }
                        }
                    }
                }
                
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 65, handler: nil)
            
            XCTAssertFalse(predictions.isEmpty)
        } else {
            XCTFail("Failed to load the test image")
        }
    }

}
