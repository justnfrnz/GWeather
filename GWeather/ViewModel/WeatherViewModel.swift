import RxSwift
import RxCocoa
import CoreLocation

class WeatherViewModel: NSObject, CLLocationManagerDelegate {
    private let networkManager = NetworkManager()
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
    
    // Delegate method called when location is found
    // Success: Called when GPS find you
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation], didFailWithError error: Error) {
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
                let condition = firstEntry.weather?.first?.main?.rawValue ?? "Clouds"
                let icon = self.determineIcon(condition: condition)
                self.weatherIcon.accept(icon)
                
                // Update history (Append new list to history for tab)
                self.history.accept(model.list ?? [])
                
                self.isLoading.accept(false)
            }, onFailure: { [weak self] error in
                self?.isLoading.accept(false)
                
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
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func determineIcon(condition: String) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Requirement: Moon icon if past 6 PM (18:00) or before 6 AM
        if (hour >= 18 || hour < 6) {
            return "moon.stars.fill"
        }
        return condition == "Rain" ? "cloud.rain.fill" : "sun.max.fill"
    }
}

