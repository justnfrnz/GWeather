import SwiftUI
import RxRelay

struct AuthView: View {
    @StateObject var viewModel = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            Text(viewModel.isRegisterMode ? "Create Account" : "Sign In")
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
                    
                    if let error = viewModel.emailError  {
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
                if viewModel.isRegisterMode {
                    viewModel.registerAction()
                } else {
                    viewModel.loginAction()
                }
            }) {
                Text(viewModel.isRegisterMode ? "REGISTER" : "LOGIN")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: {
                viewModel.isRegisterMode.toggle()
                viewModel.emailErrorRelay.accept(nil)
                viewModel.passwordErrorRelay.accept(nil) // Clear error when switching modes
            }) {
                Text(viewModel.isRegisterMode ? "Already have an account? Sign In" : "Don't have an account? Register")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 28/255, green: 28/255, blue: 84/255).ignoresSafeArea())
        
        if viewModel.showSuccessToast {
            ToastView(message: viewModel.toastMessage, isValid: viewModel.isValid)
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
                .padding(.top, 10)
        }
    }
}
