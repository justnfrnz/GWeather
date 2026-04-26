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
        case .getWeatherForecast(lat: let lat, long: let long):
            return "appid=\(Configs.openWeatherApiKey)&units=\(Constants.shared.units)&lat=\(lat)&lon=\(long)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .getWeatherForecast(lat: _, long: _):
            return .requestPlain
        }
    }
    
    var headers: [String:String]? {
        return ["Content-type":"application/json"]
    }
    
    var sampleData: Data {
        return Data()
    }
}
