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
            
            _ = Requests.sendImages(images: [beeImage]) { json in
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
    
    func testSendImages_multipleImages() throws {
        if let beeImage = UIImage(named: "bee_square", in: Bundle(for: type(of: self)), compatibleWith: nil) {
            // Create an expectation
            let expectation = self.expectation(description: "Sending a request")
            var predictions: [Prediction] = []
            
            _ = Requests.sendImages(images: Array(repeating: beeImage, count: 50), imagesToSend: 5) { json in
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
    
    func testSelectionMethod_even() throws {
        if let beeImage = UIImage(named: "bee_square", in: Bundle(for: type(of: self)), compatibleWith: nil) {
            let images = Array(repeating: beeImage, count: 50)
            let howMany = 10
            
            for method in Method.allCases {
                let selected = Requests.selectionMethod(images: images, howMany: howMany, method: method)
                
                XCTAssertTrue(selected.count == howMany, "method: \(method), expected: \(howMany), got: \(selected.count)")
            }
        } else {
            XCTFail("Failed to load the test image")
        }
    }
    
    func testSelectionMethod_uneven() throws {
        if let beeImage = UIImage(named: "bee_square", in: Bundle(for: type(of: self)), compatibleWith: nil) {
            let images = Array(repeating: beeImage, count: 54)
            let howMany = 10
            
            for method in Method.allCases {
                let selected = Requests.selectionMethod(images: images, howMany: howMany, method: method)
                
                XCTAssertTrue(selected.count == howMany, "method: \(method), expected: \(howMany), got: \(selected.count)")
            }
        } else {
            XCTFail("Failed to load the test image")
        }
    }
    
    func testSelectionMethod_lower() throws {
        if let beeImage = UIImage(named: "bee_square", in: Bundle(for: type(of: self)), compatibleWith: nil) {
            let images = Array(repeating: beeImage, count: 5)
            let howMany = 10
            
            for method in Method.allCases {
                let selected = Requests.selectionMethod(images: images, howMany: howMany, method: method)
                
                XCTAssertTrue(selected.count == images.count)
            }
        } else {
            XCTFail("Failed to load the test image")
        }
    }

}
