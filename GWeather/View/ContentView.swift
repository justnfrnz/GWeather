//
//  ContentView.swift
//  GWeather
//
//  Created by Justin on 4/26/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var weatherViewModel = WeatherViewModel()
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if !authViewModel.isLoggedIn {
                LoginView(viewModel: authViewModel)
            } else {
                ZStack(alignment: .leading) {
                    
                    // LAYER 1: Main App Content
                    VStack(spacing: 0) {
                        // Custom Header
                        HStack {
                            Button(action: {
                                withAnimation(.spring()) {
                                    authViewModel.isSideMenuOpen.toggle()
                                }
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Text("GWeather").fontWeight(.bold)
                            Spacer()
                            // Actual location button if you want it functional later
                            Button(action: {
                                withAnimation(.spring()) {
                                    weatherViewModel.requestLocation()
                                }
                            }) {
                                Image(systemName: "location.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                        
                        TabView {
                            CurrentWeatherView(viewModel: weatherViewModel)
                                .tabItem {
                                    Label("Current", systemImage: "thermometer.sun.fill")
                                }
                            
                            WeatherHistoryView(viewModel: weatherViewModel)
                                .tabItem {
                                    Label("History", systemImage: "clock.fill")
                                }
                        }
                        .accentColor(.white)
                        .opacity(weatherViewModel.uiIsLoading ? 0 : 1)
                    }
                    // Prevent interacting with tabs when menu is open
                    .disabled(authViewModel.isSideMenuOpen)
                    
                    // LAYER 2: Dim Overlay (only shows when menu is open)
                    if authViewModel.isSideMenuOpen {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation { authViewModel.isSideMenuOpen = false }
                            }
                            .transition(.opacity)
                    }
                    
                    // LAYER 3: Side Menu
                    SideMenuView(viewModel: authViewModel)
                        .offset(x: authViewModel.isSideMenuOpen ? 0 : -280)
                    
                    // LAYER 4: Loading Overlay (Top Most)
                    if weatherViewModel.uiIsLoading {
                        ZStack {
                            Color.black.opacity(0.5).ignoresSafeArea()
                            LoadingView()
                        }
                    }
                }
                .onAppear {
                    weatherViewModel.requestLocation()
                }
            }
        }
        .errorAlert(message: $weatherViewModel.uiErrorMessage)
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354).ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

//#Preview {
//    ContentView()
//}
