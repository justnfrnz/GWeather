import SwiftUI

struct SideMenuView: View {
    @ObservedObject var viewModel: AuthViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // User Profile Section
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.white)
                
                Text(viewModel.email)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.top, 50)
            
            Divider().background(Color.white.opacity(0.5))
            
            // Menu Items
            Button(action: { /* Navigate to profile */ }) {
                Label("My Profile", systemImage: "person.fill")
            }
            
            Button(action: { /* App Settings */ }) {
                Label("Settings", systemImage: "gearshape.fill")
            }
            
            Spacer()
            
            // Logout Button
            Button(action: {
                viewModel.logout()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Logout")
                }
                .foregroundColor(.red)
            }
            .padding(.bottom, 30)
        }
        .padding()
        .frame(maxWidth: 280, maxHeight: .infinity, alignment: .leading)
        .background(Color(hue: 0.656, saturation: 0.8, brightness: 0.2))
        .edgesIgnoringSafeArea(.all)
    }
}
