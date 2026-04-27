import SwiftUI

struct WeatherDetailSheet: View {
    let item: List
    
    var body: some View {
        VStack(spacing: 25) {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top)

            Text(item.dtTxt ?? "Date Not Available")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("\(Int(item.main?.temp ?? 0))°C")
                .font(.system(size: 60, weight: .bold))

            HStack(spacing: 40) {
                VStack {
                    Text("Humidity")
                    Text("\(item.main?.humidity ?? 0)%").bold()
                }
                VStack {
                    Text("Pressure")
                    Text("\(item.main?.pressure ?? 0) hPa").bold()
                }
            }
            Spacer()
        }
        .padding()
    }
}
