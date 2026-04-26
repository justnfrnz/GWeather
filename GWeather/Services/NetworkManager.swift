import Moya
import RxSwift

protocol Networkable {
    var provider: MoyaProvider<API> {get}
    func fetchWeatherForecast(lat: Double, long: Double) -> Single<OpenWeatherModel>
    
}

class NetworkManager: Networkable {
    var provider = MoyaProvider<API>(plugins: [
        NetworkLoggerPlugin(),
        ApiErrorPlugin()
    ])
    
    func fetchWeatherForecast(lat: Double, long: Double) -> Single<OpenWeatherModel> {
        return request(target: .getWeatherForecast(lat: lat, long: long))
    }
}

private extension NetworkManager {
    
    private func request<T: Decodable>(target: API) -> Single<T> {
        return provider.rx.request(target)
            .retry { errorObservable in
                errorObservable.enumerated().flatMap { (index, error) -> Observable<Int> in
                    let maxRetries = 3
                    
                    // Only retry if it's a network error and we haven't hit the limit
                    if index < maxRetries && self.shouldRetry(error: error) {
                        let delay = Double(index + 1)
                        return Observable<Int>.timer(.seconds(Int(delay)), scheduler: MainScheduler.instance)
                    }
                    
                    // If it's a 401 or we ran out of retries, pass the error through
                    return Observable.error(error)
                }
                
            }
            .map(T.self)
    }
    
    private func shouldRetry(error: Error) -> Bool {
        // Don't retry if the server specifically gave us an ApiErrorModel like 404
        if error is ApiErrorModel { return false}
        
        // Retry for connection issues/timeouts
        return true
    }
}
