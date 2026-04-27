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
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind SwiftUI TextFields to Rx Relays
        $email
            .sink { [weak self] in self?.emailRelay.accept($0)}
            .store(in: &cancellables)
        $password
            .sink { [weak self] in self?.passwordRelay.accept($0)}
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
    private func validateFields() -> Bool {
        emailErrorRelay.accept(nil)
        passwordErrorRelay.accept(nil)
        
        var isValid = true
        
        if email.isEmpty {
            emailErrorRelay.accept("Email cannot be empty")
            isValid = false
        } else if !email.contains("@"){
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
            showError("Fields cannot be empty.")
            return false
        }
        if !isValid {
            showError("Please fix the errors above")
        }
        
        return isValid
    }
    
    // MARK: - Actions
    func registerAction() {
        guard validateFields() else { return } // Exit if validation fails
        
        let users = getSavedUsers()
        if users[email] != nil {
            showError("User already exists!")
            return
        }
        
        var updatedUsers = users
        updatedUsers[email] = password
        saveUsers(updatedUsers)
        showError("Registration Successful! Please Login.")
        print("Updated user: \(email) \(password)")
    }
    
    func loginAction() {
        guard validateFields() else { return } // Exit if validation fails
        
        let users = getSavedUsers()
        if let savedPassword = users[email], savedPassword == password {
            authError = nil
            isLoggedIn = true
        } else {
            
            showError("Invalid email or password.")
            
        }
    }
    func logout() {
        isLoggedIn = false
        isSideMenuOpen = false
        email = ""
        password = ""
    }
    
    private func showError(_ message: String) {
        errorRelay.accept(message)
        DispatchQueue.main.async {
            self.authError = message
            self.showAlert = true
        }
        
    }
    
    private func getSavedUsers() -> [String: String] {
        return UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: String] ?? [:]
    }
    
    private func saveUsers(_ users: [String: String]) {
        UserDefaults.standard.set(users, forKey: userDefaultsKey)
    }
}
