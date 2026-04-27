//
//  GWeatherTests.swift
//  GWeatherTests
//
//  Created by Justin on 4/26/26.
//

import Testing
@testable import GWeather
import Foundation

@MainActor
struct GWeatherTests {
    
    @Test("Validates email regex correctly")
    func testEmailRegex() {
        let viewModel = AuthViewModel()
        
        // Invalid format
        viewModel.email = "test@"
        #expect(viewModel.validateFields() == false)
        
        viewModel.email = "test@domain"
        #expect(viewModel.validateFields() == false)
        
        // Valid format
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        #expect(viewModel.validateFields() == true)
    }
    
    @Test("Validates password length requirement")
    func testPasswordLength() {
        let viewModel = AuthViewModel()
        viewModel.email = "test@example.com"
        
        // Too short
        viewModel.password = "12345"
        #expect(viewModel.validateFields() == false)
        
        // Minimum lenth (6)
        viewModel.password = "123456"
        #expect(viewModel.validateFields() == true)
    }
    @Test("Saves and Retrives users from local memory")
    func testUserPersistence() {
        let viewModel = AuthViewModel()
        viewModel.email = "testuser@gmail.com"
        viewModel.password = "password123"
        
        viewModel.registerAction()
        
        viewModel.loginAction()
        #expect(viewModel.isLoggedIn == true)
    }
    
    @Test("Return moon icon after 6 PM and sun during day")
    func testWeatherIcon() {
        let viewModel = WeatherViewModel()
        
        // Note: determineIcon uses Date(), so we test based on the logic
        // that 6 PM (18) to 6 AM (6) returns the moon.
        let icon = viewModel.determineIcon(condition: "Clear")
        
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 18 || hour < 6 {
            #expect(icon == "moon.stars.fill")
        } else {
            #expect(icon == "sun.max.fill")
        }
    }
    
    @Test("Format Unix timestamp to readable time string")
    func testTimeFormatting() {
        let viewModel = WeatherViewModel()
        
        let formattedTime = viewModel.formatUnixTime(1714185600)
        #expect(formattedTime.contains("AM") || formattedTime.contains("PM"))
    }
    
    @Test("Converts country code to full country name")
    func testCountryNameConversion() {
        let viewModel = WeatherViewModel()
        
        let philippines = viewModel.getFullCountryName(from: "PH")
        #expect(philippines == "Philippines")
        
        let unknwon = viewModel.getFullCountryName(from: "XYZ")
        #expect(unknwon == "XYZ")
    }
    
}
