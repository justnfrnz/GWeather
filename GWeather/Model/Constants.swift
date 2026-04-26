final class Constants {
    // Shared instance
    static let shared = Constants()
    
    // Private init
    private init() {}
    
    final let baseUrl: String = "api.openweathermap.org/data/2.5/forecast?"
    final let appId: String = "1051735bc8d027068b88ef58adbf611a"
    final let units: String = "metric"
}
