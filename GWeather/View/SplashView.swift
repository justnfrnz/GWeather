import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            MainView()
        } else {
            ZStack {
                // Your Theme Background
                Color(red: 28/255, green: 28/255, blue: 84/255)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Recreating a logo with SF Symbols
                    ZStack {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.yellow)
                            .offset(x: 30, y: -30)
                        
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 120))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                    }
                    Text("GWeather")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(2)
                }
            }
            .onAppear {
                // Time before switching to Login/Main screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
