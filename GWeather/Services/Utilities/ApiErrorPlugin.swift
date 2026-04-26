import Foundation
import Moya

struct ApiErrorPlugin: PluginType {
    // This is called immediately after a network request finishes
    func process(_ result: Result<Response, MoyaError>, target: any TargetType) -> Result<Response, MoyaError> {
        switch result {
        case .success(let response):
            // Check if status code is an error (outside 200-299)
            if !(200...299).contains(response.statusCode) {
                do {
                    // Try to parse your custom server error json
                    let serverError = try JSONDecoder().decode(ApiErrorModel.self, from: response.data)
                    // Wrap it in a MoyaError so the stream sees it as a failure
                    return .failure(.underlying(serverError, response))
                } catch {
                    // If parsing fails, just return the standard Moya Error
                    return .failure(.statusCode(response))
                }
            }
            return .success(response)
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension Error {
    var asApiError: ApiErrorModel? {
        if let moyaError = self as? MoyaError,
           case let .underlying(error, _) = moyaError {
            return error as? ApiErrorModel
        }
        return self as? ApiErrorModel
    }
}
