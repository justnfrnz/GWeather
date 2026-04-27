import SwiftUI

struct ToastView: View {
    var message: String
    var isValid: Bool = true
    
    var body: some View {
        Text(message)
            .padding()
            .background(isValid ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}
