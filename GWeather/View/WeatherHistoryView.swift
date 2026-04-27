import SwiftUI

struct WeatherHistoryView: View {
    @ObservedObject var viewModel:  WeatherViewModel
    @State private var selectedWeather: List?
    
    var body: some View {
        NavigationView {
            SwiftUI.List(viewModel.uiHistory, id: \.dt) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.dtTxt ?? "Unknown Time")
                            .font(.caption)
                        Text(item.weather?.first?.description?.capitalized ?? "")
                            .font(.headline)
                    }
                    Spacer()
                    Text("\(Int(item.main?.temp ?? 0))°C")
                        .font(.title3)
                        .bold()
                }
                .padding(.vertical, 5)
                .contentShape(Rectangle()) // Makes the whole row clickable
                .onTapGesture {
                    selectedWeather = item
                }
                .listRowBackground(Color.white.opacity(0.1))
            }
            .navigationTitle("Weather History")
            .listStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
            // --- THE BOTTOM SHEET ---
            .sheet(item: $selectedWeather) { weather in
                WeatherDetailSheet(item: weather)
                    .ios15HalfSheet()
            }
        }
    }
}


