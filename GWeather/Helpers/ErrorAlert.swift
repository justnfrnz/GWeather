import SwiftUI

struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
}

// 2. The Reusable Modifier
struct ErrorAlertModifier: ViewModifier {
    @Binding var errorMessage: String?

    func body(content: Content) -> some View {
        content
            .alert(item: Binding(
                get: { errorMessage.map { IdentifiableError(message: $0) } },
                set: { _ in errorMessage = nil }
            )) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
}

// 3. An extension to make it easy to call
extension View {
    func errorAlert(message: Binding<String?>) -> some View {
        self.modifier(ErrorAlertModifier(errorMessage: message))
    }
}
