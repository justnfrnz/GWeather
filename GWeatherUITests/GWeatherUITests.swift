//
//  GWeatherUITests.swift
//  GWeatherUITests
//
//  Created by Justin on 4/26/26.
//

import XCTest

final class GWeatherUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments += ["-resetState"]
        app.launch()
    }
    
    @MainActor
    func testCompleteUserJourney() throws {
        let registerToggle = app.buttons["Don't have an account? Register"]
        XCTAssertTrue(registerToggle.waitForExistence(timeout: 5)) // Wait for Splash Screen to finish/
        
        // REGISTRATION PHASE
        registerToggle.tap()
        
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
    
        emailField.tap()
        emailField.typeText("sampleTestUser@gmail.com")
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        app.buttons["REGISTER"].tap()
        
        emailField.tap()
        emailField.tap(withNumberOfTaps: 3, numberOfTouches: 1) // Clear the previous field inputs
        emailField.typeText("sampleTestUser@gmail.com")
        
        passwordField.tap()
        passwordField.tap(withNumberOfTaps: 3, numberOfTouches: 1) // Clear the previous field inputs
        passwordField.typeText("password123")
        
        app.buttons["LOGIN"].tap()
        
        // 4. VERIFY FINAL STATE
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Should be on the Weather screen now")
    }
    
    @MainActor
    func testRegistrationModeToogle() throws {
        let registerToggle = app.buttons["Don't have an account? Register"]
        XCTAssertTrue(registerToggle.waitForExistence(timeout: 5)) // Added Timeout because of the delay in SplashView
        
        // Switch to Register Mode
        registerToggle.tap()
        
        // Verify Title Change
        let registerTitle = app.staticTexts["Create Account"]
        XCTAssertTrue(registerTitle.exists, "Header should change to Create Account")
        
        // Verify Button Change
        let registerButton = app.buttons["REGISTER"]
        XCTAssertTrue(registerButton.exists, "Button should now say REGISTER")
    }
}
