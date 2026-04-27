# GWeather
A professional, location-aware weather application built with **SwiftUI** and **RxSwift**. This app provides real-time weather data and forecasts using the OpenWeather API and robust local authentication.

---

## Getting Started (API Key Setup)
To protect sensitive data, the API key has been removed from this repository. To run the application, you must manually add the api key:

1. In the project root, create a file named **`Configs.swift`**.
2. Add the following code to the file:

```swift
import Foundation

struct Configs {
    static let openWeatherApiKey = "1051735bc8d027068b88ef58adbf611a"
}
```

---

## Key Features
*   **Authentication**: Secure Registration and Sign-In using `UserDefaults` for local persistence.
*   **Location-Aware**: Automatically detects the user's current City and Country using `CoreLocation`.
*   **Dynamic UI Logic**:
    *   **Day/Night Cycle**: Automatically switches to a **Moon Icon** (`moon.stars.fill`) if the current time is past **6:00 PM**.
    *   **Glassmorphism**: Modern, blurred UI elements for the Weather Detail sheets.
    *   **Interactive Toasts**: Compact, floating notifications for registration success and validation errors.
*   **Animations**: Custom splash screen with a pulsing logo and smooth fade-in transitions for weather data.

---

## Tech Stack
*   **Frameworks**: SwiftUI (UI) & Combine (Bridging).
*   **Reactive Programming**: **RxSwift** & **RxCocoa** used for networking, field validation, and location streams.
*   **Networking**: **Moya** (Alamofire-based) for type-safe API requests.
*   **Architecture**: **MVVM** with a custom bridge to sync Rx `BehaviorRelays` with SwiftUI `@Published` properties.

---

## Testing
The app includes a comprehensive testing suite to ensure logic stability and UI reliability.

### 1. Unit Tests (`GWeatherTests`)
*   **Email Validation**: Verified via **Regex** to ensure proper `email@domain.com` formatting.
*   **Password Logic**: Ensures minimum length and non-empty requirements.
*   **Time-Based Logic**: Explicitly verifies the 6 PM icon switch requirement.
*   **Data Mapping**: Verifies that Unix timestamps are correctly formatted into readable strings.

### 2. UI Tests (`GWeatherUITests`)
*   **Complete User Journey**: Automates the flow of Registering → Receiving a Success Toast → Hiding Keyboard → Logging In → Navigating Tabs.

---

## System Requirements
*   **iOS**: 15.0+
*   **Xcode**: 15.0+
*   **Language**: Swift 5.0+
*   **Dependency Manager**: CocoaPods

> **Note**: Please run `pod install` and open the `.xcworkspace` file to ensure all dependencies (RxSwift, Moya, etc.) are loaded correctly.

---

## Author
**Justin Franz Estocado**  
*Project submitted for the GWeather Technical Assessment.*
