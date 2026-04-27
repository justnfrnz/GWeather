import SwiftUI

struct WeatherDetailSheet: View {
    let item: List
    
    var body: some View {
        ZStack {
            // 1. Background: Dark Gradient + Blur
            LinearGradient(gradient: Gradient(colors: [Color(hue: 0.656, saturation: 0.787, brightness: 0.354), Color.black]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Handle Bar
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.top)
                
                // Date/Time Header
                Text(item.dtTxt ?? "Date Not Available")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                // Main Temperature Display
                VStack(spacing: 5) {
                    Text("\(Int(item.main?.temp ?? 0))°")
                        .font(.system(size: 100, weight: .thin)) // Thin looks very modern
                        .foregroundColor(.white)
                    
                    Text(item.weather?.first?.description?.capitalized ?? "")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Weather Grid (Humidity, Pressure, etc.)
                HStack(spacing: 0) {
                    DetailBox(label: "HUMIDITY", value: "\(item.main?.humidity ?? 0)%", icon: "humidity.fill")
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.vertical, 10)
                    
                    DetailBox(label: "PRESSURE", value: "\(item.main?.pressure ?? 0) hPa", icon: "gauge.medium")
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

// 2. Helper View for Grid Items
struct DetailBox: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(label)
                .font(.caption2)
                .tracking(1) // Spaces letters for a "Pro" look
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
    }
}
