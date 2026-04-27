import Moya
internal import Alamofire

enum API {
    case getWeatherForecast(lat: Double, long: Double)
}

extension API: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string:Constants.shared.baseUrl) else {fatalError("Invalid url")}
        return url
    }
    
    var path: String {
        switch self {
        case .getWeatherForecast(lat: _, long: _):
            return "/data/2.5/forecast"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .getWeatherForecast(lat: let lat, long: let long):
            return .requestParameters(
                parameters: ["appid": Configs.openWeatherApiKey, "units":"metric", "lat": lat, "lon": long],
                encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String:String]? {
        return ["Content-type":"application/json"]
    }
    
    var sampleData: Data {
        return Data()
    }
}
