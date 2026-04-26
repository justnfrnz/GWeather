import Moya
internal import Alamofire

enum API {
    case getWeatherForecast(cityName: String, countryCode: String)
}

extension API: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string:Constants.shared.baseUrl) else {fatalError("Invalid url")}
        return url
    }
    
    var path: String {
        switch self {
        case .getWeatherForecast(cityName: let cityName, countryCode: let countryCode):
            return "appid=\(Constants.shared.appId)&units=\(Constants.shared.units)&q=\(cityName),\(countryCode)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .getWeatherForecast(cityName: let cityName, countryCode: let countryCode):
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
