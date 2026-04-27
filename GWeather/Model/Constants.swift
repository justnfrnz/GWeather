final class Constants {
    // Shared instance
    static let shared = Constants()
    
    // Private init
    private init() {}
    
    final let baseUrl: String = "https://api.openweathermap.org"
    final let units: String = "metric"
}
