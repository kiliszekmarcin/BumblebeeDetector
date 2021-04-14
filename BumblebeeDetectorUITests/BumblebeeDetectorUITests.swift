//
//  BumblebeeDetectorUITests.swift
//  BumblebeeDetectorUITests
//
//  Created by Marcin Kiliszek on 12/04/2021.
//

import XCTest

class BumblebeeDetectorUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }
    
    func testAppFlow() throws {
        // setup
        let beeName = String(UUID().uuidString.prefix(5))
        
        // test initialisation
        XCTAssert(app.staticTexts["Detections"].exists)
        XCTAssert(app.buttons["Add new bee"].exists)
        
        // //// ADD NEW BEE
        // go to add bee screen
        app.buttons["Add new bee"].tap()
        
        // check if navbar correct
        XCTAssert(app.staticTexts["Add a new bee"].exists)
        
        // select a video
        app.buttons["Select a video"].tap()
        app.buttons["Photo Library"].tap()
        app.buttons["Albums"].tap()
        app.otherElements["Bees 🐝"].tap()
        app.images["Video, ten seconds, 11 July 2020, 16:27"].tap()
        _ = app.buttons["Choose"].waitForExistence(timeout: 5)
        app.buttons["Choose"].tap()
        
        // click detect
        app.buttons["Detect"].tap()
        
        // check if loading displayed
        XCTAssert(app.staticTexts["Detecting"].exists || app.staticTexts["Predicting"].exists)
        
        // fill in the name
        var nameTextField = app.textFields["Enter a nickname"].firstMatch
        nameTextField.tap()
        nameTextField.typeText("\(beeName)\n")
        
        // check if nav bar updated
        XCTAssert(app.staticTexts[beeName].exists)
        
        // wait for the detection to finish
        XCTAssert(app.staticTexts["Detected bee:"].waitForExistence(timeout: 30))
        
        // predict if not started
        // make sure research mode is off
        if app.buttons["Predict"].exists {
            app.buttons["Predict"].tap()
        }
        
        // wait for predictions to appear
        XCTAssert(app.staticTexts["Predictions:"].waitForExistence(timeout: 70))
        
        // check if all elements in place
        XCTAssert(app.maps.firstMatch.exists)
        XCTAssert(app.staticTexts["Date spotted:"].exists)
        
        // save bee
        XCTAssert(app.buttons["Save"].isEnabled)
        app.buttons["Save"].tap()
        
        // check if bee present in the list
        var beeCell = app.cells.allElementsBoundByIndex.filter { $0.label.contains(beeName) }.first
        XCTAssertNotNil(beeCell)
        
        // //// VIEW THE BEE
        beeCell?.tap()
        
        // check if all fields are there
        XCTAssert(app.staticTexts[beeName].exists)
        XCTAssert(app.maps.firstMatch.exists)
        XCTAssert(app.staticTexts["Date spotted:"].exists)
        XCTAssert(app.staticTexts["Detected bee:"].exists)
        XCTAssert(app.staticTexts["Predictions:"].exists)
        
        // //// EDIT THE BEE
        let newBeeName = String(UUID().uuidString.prefix(5))
        
        nameTextField = app.textFields["Enter a nickname"].firstMatch
        nameTextField.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: beeName.count)
        nameTextField.typeText(deleteString)
        nameTextField.typeText("\(newBeeName)\n")
        
        // check if nav bar updated
        XCTAssert(app.staticTexts[newBeeName].exists)
        
        // save
        app.buttons["Save"].tap()
        
        // check if bee present in the list
        let oldBeeCell = app.cells.allElementsBoundByIndex.filter { $0.label.contains(beeName) }.first
        beeCell = app.cells.allElementsBoundByIndex.filter { $0.label.contains(newBeeName) }.first
        
        XCTAssertNil(oldBeeCell)
        XCTAssertNotNil(beeCell)
        
        // //// DELETE THE BEE
        beeCell?.swipeLeft()
        app.buttons["Delete"].tap()
        
        beeCell = app.cells.allElementsBoundByIndex.filter { $0.label.contains(newBeeName) }.first
        
        XCTAssertNil(beeCell)
    }

}
