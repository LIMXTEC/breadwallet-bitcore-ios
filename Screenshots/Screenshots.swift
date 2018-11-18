//
//  Screenshots.swift
//  Screenshots
//
//  Created by Adrian Corscadden on 2017-07-02.
//  Copyright © 2018 Bitcorewallet Team. All rights reserved.
//

import XCTest

class Screenshots: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        snapshot("1LockScreen")

        let app = XCUIApplication()
        let staticText = app.collectionViews.staticTexts["5"]
        staticText.tap()
        staticText.tap()
        staticText.tap()
        staticText.tap()
        staticText.tap()
        staticText.tap()
        
        // go back to home screen if needed
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.exists {
            backButton.tap()
        }
        
        snapshot("0TxList")

        app.buttons["MENU"].tap()
        let scrollViewsQuery = app.scrollViews
        scrollViewsQuery.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).tap()
        snapshot("2Security")
        scrollViewsQuery.otherElements.buttons["Close"].tap()

        app.buttons["MENU"].tap()
        let scrollViewsQuery2 = app.scrollViews
        scrollViewsQuery2.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).tap()
        snapshot("3Support")

    }
    
}
