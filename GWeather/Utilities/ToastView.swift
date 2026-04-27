import SwiftUI

struct ToastView: View {
    var message: String
    var isValid: Bool = true
    
    var body: some View {
        Text(message)
            .padding(.horizontal, 50)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(isValid ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
