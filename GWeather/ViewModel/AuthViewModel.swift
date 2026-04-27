import Foundation
import RxSwift
import RxRelay
import RxCocoa
import SwiftUI
internal import Combine

class AuthViewModel: ObservableObject {
    private let disposebag = DisposeBag()
    private let userDefaultsKey = "saved_users"
    private var cancellables = Set<AnyCancellable>()
    
    let emailErrorRelay = BehaviorRelay<String?>(value: nil)
    let passwordErrorRelay = BehaviorRelay<String?>(value: nil)
    let isLoggedInRelay = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: "is_logged_in"))
    
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggedIn = false
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var isSideMenuOpen: Bool = false
    @Published var showSuccessToast: Bool = false
    @Published var isRegisterMode = false
    @Published var toastMessage: String = ""
    @Published var isValid = false
    
    init() {
        setupBindings()
        
        // Used in GWeatherUITests
        if CommandLine.arguments.contains("-resetState") {
            UserDefaults.standard.set(false, forKey: "is_logged_in")
        }
    }
    
    private func setupBindings() {
        // Bind SwiftUI TextFields to Rx Relays
        $email
            .sink { [weak self] _ in self?.emailErrorRelay.accept(nil)}
            .store(in: &cancellables)
        $password
            .sink { [weak self] _ in self?.passwordErrorRelay.accept(nil)}
            .store(in: &cancellables)
        
        // Bind Rx Relays back to SwiftUI @Published for the View to update
        isLoggedInRelay.asDriver()
            .drive(onNext: { [weak self] in
                self?.isLoggedIn = $0
                UserDefaults.standard.set($0, forKey: "is_logged_in")
            })
            .disposed(by: disposebag)
        
        emailErrorRelay
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] in self?.emailError = $0 })
            .disposed(by: disposebag)
        
        passwordErrorRelay
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] in self?.passwordError = $0 })
            .disposed(by: disposebag)
    }
    func validateFields() -> Bool {
        emailErrorRelay.accept(nil)
        passwordErrorRelay.accept(nil)
        
        var isValid = true
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isEmailFormatValid = emailPredicate.evaluate(with: email)
        
        if email.isEmpty {
            emailErrorRelay.accept("Email cannot be empty")
            isValid = false
        } else if !isEmailFormatValid {
            emailErrorRelay.accept("Please enter a valid email format")
            isValid = false
        }
        
        if password.isEmpty {
            passwordErrorRelay.accept("Password cannot be empty")
            isValid = false
        } else if password.count < 6 {
            passwordErrorRelay.accept("Too short (min 6 char)")
            isValid = false
        }
        
        if email.isEmpty || password.isEmpty {
            showToast(message: "Fields cannot be empty", isValid: false)
            return false
        }
        if !isValid {
            showToast(message: "Please fix errors above", isValid: false)
        }
        
        return isValid
    }
    
    // MARK: - Actions
    func registerAction() {
        guard validateFields() else { return } // Exit if validation fails
        
        let users = getSavedUsers()
        if users[email] != nil {
            showToast(message: "User already exists!", isValid: false)
            return
        }
        
        var updatedUsers = users
        updatedUsers[email] = password
        saveUsers(updatedUsers)
        
        UIApplication.shared.endEditing()
        
        showToast(message: "Registration Successful!", isValid: true)
        withAnimation(.spring) {self.isRegisterMode = false}
    }
    
    func loginAction() {
        guard validateFields() else { return } // Exit if validation fails
        
        let users = getSavedUsers()
        if let savedPassword = users[email], savedPassword == password {
            UIApplication.shared.endEditing()
            self.isLoggedIn = true
        } else {
            showToast(message: "Invalid email or password", isValid: false)
        }
    }
    func logout() {
        isLoggedIn = false
        isSideMenuOpen = false
        email = ""
        password = ""
    }
    
    func showToast(message: String, isValid: Bool) {
        self.toastMessage = message
        self.isValid = isValid
        withAnimation(.spring) { self.showSuccessToast = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { self.showSuccessToast = false }
        }
    }
    
    private func getSavedUsers() -> [String: String] {
        return UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: String] ?? [:]
    }
    
    private func saveUsers(_ users: [String: String]) {
        UserDefaults.standard.set(users, forKey: userDefaultsKey)
    }
}


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
