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
    
    let emailRelay = BehaviorRelay<String>(value: "")
    let passwordRelay = BehaviorRelay<String>(value: "")
    let errorRelay = BehaviorRelay<String>(value: "")
    let emailErrorRelay = BehaviorRelay<String?>(value: nil)
    let passwordErrorRelay = BehaviorRelay<String?>(value: nil)
    let isLoggedInRelay = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: "is_logged_in"))
    let showAlertRelay = BehaviorRelay<Bool>(value: false)
    let authErrorRelay = BehaviorRelay<String?>(value: nil)
    
    @Published var email = ""
    @Published var password = ""
    @Published var authError: String?
    @Published var showAlert = false
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
    }
    
    private func setupBindings() {
        // Bind SwiftUI TextFields to Rx Relays
        $email
            .sink { [weak self] value in
                self?.emailRelay.accept(value)
                // Automatically clear errors when user types in Email
                self?.emailErrorRelay.accept(nil)
                self?.authErrorRelay.accept(nil)
            }
            .store(in: &cancellables)
        $password
            .sink { [weak self] value in
                self?.passwordRelay.accept(value)
                // Automatically clear errors when user types in Password
                self?.passwordErrorRelay.accept(nil)
                self?.authErrorRelay.accept(nil)
            }
            .store(in: &cancellables)
        
        // Bind Rx Relays back to SwiftUI @Published for the View to update
        isLoggedInRelay.asDriver()
            .drive(onNext: { [weak self] in
                self?.isLoggedIn = $0
                UserDefaults.standard.set($0, forKey: "is_logged_in")
            })
            .disposed(by: disposebag)
        
        errorRelay.asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] msg in
                self?.authError = msg
                self?.showAlert = !msg.isEmpty
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
        
        showAlertRelay.asDriver()
            .drive(onNext: { [weak self] in self?.showAlert = $0 })
            .disposed(by: disposebag)
        
        authErrorRelay.asDriver()
            .drive(onNext: { [weak self] in self?.authError = $0 })
            .disposed(by: disposebag)
        
    }
    func validateFields() -> Bool {
        emailErrorRelay.accept(nil)
        passwordErrorRelay.accept(nil)
        
        var isValid = true
        
        if email.isEmpty {
            emailErrorRelay.accept("Email cannot be empty")
            isValid = false
        } else if !email.contains("@") {
            emailErrorRelay.accept("Invalid email format")
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
            authError = nil
            showToast(message: "Welcome!", isValid: true)
            UIApplication.shared.endEditing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                       self.isLoggedIn = true
                   }
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
