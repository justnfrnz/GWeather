final class Constants {
    // Shared instance
    static let shared = Constants()
    
    // Private init
    private init() {}
    
    final let baseUrl: String = "api.openweathermap.org/data/2.5/forecast?"
    final let units: String = "metric"
}
