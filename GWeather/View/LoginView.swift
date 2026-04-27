import SwiftUI
import RxRelay

struct LoginView: View {
    @StateObject var viewModel = AuthViewModel()
    @State private var isRegisterMode = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text(isRegisterMode ? "Create Account" : "Sign In")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                // --- Email Field ---
                VStack(alignment: .leading, spacing: 5) {
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    // Change border to red if emailError exists
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.emailError == nil ? Color.clear : Color.red, lineWidth: 2)
                        )
                    
                    if let error = viewModel.emailError {
                        Text(error).foregroundColor(.red).font(.caption).padding(.leading, 5)
                    }
                }
                
                // --- Password Field ---
                VStack(alignment: .leading, spacing: 5) {
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.passwordError == nil ? Color.clear : Color.red, lineWidth: 2)
                        )
                    
                    if let error = viewModel.passwordError {
                        Text(error).foregroundColor(.red).font(.caption).padding(.leading, 5)
                    }
                }
            }
            .padding(.horizontal)
            
            Button(action: {
                if isRegisterMode {
                    viewModel.registerAction()
                } else {
                    viewModel.loginAction()
                }
            }) {
                Text(isRegisterMode ? "REGISTER" : "LOGIN")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(isRegisterMode ? "Registration" : "Login Status"),
                    message: Text(viewModel.authError ?? "Unknown Error"),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            Button(action: {
                isRegisterMode.toggle()
//                viewModel.authError = nil
                viewModel.errorRelay.accept("")
                viewModel.emailErrorRelay.accept(nil)
                viewModel.passwordErrorRelay.accept(nil) // Clear error when switching modes
            }) {
                Text(isRegisterMode ? "Already have an account? Sign In" : "Don't have an account? Register")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354).ignoresSafeArea())
        // Alert to show validation or auth errors
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(isRegisterMode ? "Registration" : "Login Status"),
                message: Text(viewModel.authError ?? "Unknown Error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
