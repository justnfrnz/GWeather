import SwiftUI

struct CurrentWeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(viewModel.uiCityName), \(viewModel.uiCountryName)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Image(systemName: viewModel.uiIcon)
                .renderingMode(.original)
                .font(.system(size: 100))
                .padding(.vertical, 20)
            
            Text(viewModel.uiTemp)
                .font(.system(size: 70, weight: .thin))
            
            HStack(spacing: 40) {
                VStack {
                    Text("Sunrise")
                    Text(viewModel.uiSunrise).bold()
                }
                VStack {
                    Text("Sunset")
                    Text(viewModel.uiSunset).bold()
                }
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the screen
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
    }
}
