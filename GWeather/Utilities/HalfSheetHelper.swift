import SwiftUI

extension List: Identifiable {
    public var id: Int { return dt ?? Int.random(in: 0...100000) }
}

struct HalfSheetHelper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let sheet = uiViewController.parent?.presentationController as? UISheetPresentationController {
            sheet.detents = [.medium(), .large()] // iOS 15 native detents
            sheet.prefersGrabberVisible = true     // iOS 15 native grabber
        }
    }
}

extension View {
    func ios15HalfSheet() -> some View {
        return background(HalfSheetHelper())
    }
}
