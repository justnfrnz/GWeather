import RxSwift
import RxCocoa

class GWeatherViewModel {
    private let networkManager = NetworkManager()
    private let disposeBag = DisposeBag()
    
    let weatherModel = BehaviorRelay<[OpenWeatherModel]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishRelay<String>()
    
    func fetchWeatherForecast(cityName: String = "Mapandan", countryCode: String = "PH") {
        networkManager.fetchWeatherForecast(cityName: cityName, countryCode: countryCode)
            .subscribe(onSuccess: {model in
                print("Weather: \(model)")
            }, onFailure: {error in
                if let serverError = error.asApiError {
                    print("Server message: \(serverError.message)")
                } else {
                    print("General error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
}

