import RxSwift
import Moya
import RxCocoa
import CoreLocation
import SwiftUI
internal import Combine

class WeatherViewModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let networkManager = NetworkManager()
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    // SwiftUI Observed Properties
    @Published var uiCityName: String = "Loading..."
    @Published var uiCountryName: String = ""
    @Published var uiTemp: String = "--°C"
    @Published var uiSunrise: String = "--:--"
    @Published var uiSunset: String = "--:--"
    @Published var uiIcon: String = "sun.max"
    @Published var uiHistory: [List] = []
    @Published var uiIsLoading: Bool = false
    @Published var uiErrorMessage: String? = nil
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        setupSwiftUIBindings()
    }
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishRelay<String>()
    
    
    
    // Current Weather Data (Tab 1)
    let cityName = BehaviorRelay<String>(value: "Unknown")
    let countryName = BehaviorRelay<String>(value: "--")
    let temperature = BehaviorRelay<String>(value: "--°C")
    let sunrise = BehaviorRelay<String>(value: "--:--")
    let sunset = BehaviorRelay<String>(value: "--:--")
    let weatherIcon = BehaviorRelay<String>(value: "sun.max")
    
    // History Data (Tab 2)
    let history = BehaviorRelay<[List]>(value:[])
    
    private func setupSwiftUIBindings() {
        // Map cityName Relay to uiCityName @Published
        cityName.asDriver()
            .drive(onNext: { [weak self] in self?.uiCityName = $0 })
            .disposed(by: disposeBag)
        
        countryName.asDriver()
            .drive(onNext: { [weak self] in self?.uiCountryName = $0 })
            .disposed(by: disposeBag)
        
        // Map temperature Relay
        temperature.asDriver()
            .drive(onNext: { [weak self] in self?.uiTemp = $0 })
            .disposed(by: disposeBag)
        
        // Map Icon
        weatherIcon.asDriver()
            .drive(onNext: { [weak self] in self?.uiIcon = $0 })
            .disposed(by: disposeBag)
        
        // Map History (Tab 2)
        history.asDriver()
            .drive(onNext: { [weak self] in self?.uiHistory = $0 })
            .disposed(by: disposeBag)
        
        // Map Loading State
        isLoading.asDriver()
            .drive(onNext: { [weak self] in self?.uiIsLoading = $0 })
            .disposed(by: disposeBag)
        
        // Map Error (using Optional to clear it)
        error.asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] in self?.uiErrorMessage = $0 })
            .disposed(by: disposeBag)
        
        // Map Sunrise
        sunrise.asDriver()
            .drive(onNext: { [weak self] in self?.uiSunrise = $0})
            .disposed(by: disposeBag)
        
        // Map Sunset
        sunset.asDriver()
            .drive(onNext: { [weak self] in self?.uiSunset = $0})
            .disposed(by: disposeBag)
    }
    
    func requestLocation() {
        isLoading.accept(true)
        locationManager.requestLocation()
        //        locationManager.requestWhenInUseAuthorization()
        //        locationManager.startUpdatingLocation()
    }
    
    // Delegate method called when location is found
    // Success: Called when GPS find you
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        
        // Get City Name via reverse Geocoding
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            let city = placemarks?.first?.locality ?? "Uknown"
            let country = placemarks?.first?.isoCountryCode ?? ""
            self?.cityName.accept(city)
            self?.countryName.accept(country)
        }
        
        // Fetch Weather using Lat/Long
        fetchWeatherByCoordinates(lat: location.coordinate.latitude, long: location.coordinate.longitude)
    }
    
    // Failure: Called when GPS fails
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let clError = error as? CLError
        
        switch clError?.code {
        case .locationUnknown:
            return // Still searching...
        case .denied:
            self.error.accept("Location services are disabled.")
        default:
            self.error.accept("GPS Error: \(error.localizedDescription)")
        }
        self.isLoading.accept(false)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            // Push a specific message to your UI
            self.error.accept("Location access denied. Please enable it in Settings to see local weather.")
            
            // OPTIONAL: Fallback to a default city if location is denied
            self.fetchWeatherByCoordinates(lat: 16.023686, long: 120.444400)
            
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            
        @unknown default:
            break
        }
    }
    
    // API Call
    private func fetchWeatherByCoordinates(lat: Double, long: Double) {
        isLoading.accept(true)
        networkManager.fetchWeatherForecast(lat: lat, long: long)
            .subscribe(onSuccess: { [weak self] model in
                guard let self = self, let firstEntry = model.list?.first else { return }
                print("Weather: \(model)")
                
                // Update City and Country info
                //                let city = model.city?.name ?? "City Name"
                //                let country = model.city?.country ?? "Country"
                //                self.cityName.accept(city)
                //                self.countryName.accept(country)
                
                // Update temperature (Celsius)
                if let temp = firstEntry.main?.temp {
                    self.temperature.accept("\(Int(temp))°C")
                }
                
                // Update Sunrise & Sunset
                if let sunriseVal = model.city?.sunrise, let sunsetVal = model.city?.sunset {
                    self.sunrise.accept(self.formatUnixTime(sunriseVal))
                    self.sunset.accept(self.formatUnixTime(sunsetVal))
                }
                
                // Update Icon Logic (Night mode after 6PM)
                let condition = firstEntry.weather?.first?.main ?? "Clouds"
                let icon = self.determineIcon(condition: condition)
                self.weatherIcon.accept(icon)
                
                // Update history (Append new list to history for tab)
                self.history.accept(model.list ?? [])
                
                self.isLoading.accept(false)
            }, onFailure: { [weak self] error in
                self?.isLoading.accept(false)
                
                if let moyaError = error as? MoyaError,
                   case let .objectMapping(decodingError, _) = moyaError {
                    print("Decoding Error Detail: \(decodingError)") // THIS WILL TELL YOU THE EXACT FIELD
                }
                
                if let serverError = error.asApiError {
                    print("Server message: \(serverError.message)")
                    self?.error.accept(serverError.message)
                } else {
                    print("General error: \(error.localizedDescription)")
                    self?.error.accept(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: Helpers
    
    private func formatUnixTime(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    
    
    private func determineIcon(condition: String) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Requirement: Moon icon if past 6 PM (18:00) or before 6 AM
        if (hour >= 18 || hour < 6) {
            return "moon.stars.fill"
        }
        
        // Standard condition check
        switch condition.lowercased() {
        case "rain": return "cloud.rain.fill"
        case "clear": return "sun.max.fill"
        case "clouds": return "cloud.fill"
        default: return "sun.max.fill"
        }
    }
}

