import SwiftUI
import Combine

/// Which form the login screen shows.
enum AuthMode {
    case login
    case signUp
}

/// Handles Face ID, account creation (first-time user) and email/password login (existing user).
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var mode: AuthMode
    @Published var isCheckingBiometrics = false
    @Published var fullName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?
    @Published var currentUserName = ""

    private let biometric = BiometricService()
    private let store = CredentialStore()

    init() {
        mode = store.hasAccount ? .login : .signUp
        currentUserName = store.savedName ?? ""
    }

    var hasAccount: Bool { store.hasAccount }

    private var normalizedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    // MARK: - Face ID

    /// Runs when the login screen appears. Only existing users are asked for Face ID.
    func startLaunchAuthentication() async {
        guard store.hasAccount else { return }
        await authenticateWithBiometrics()
    }

    func authenticateWithBiometrics() async {
        guard store.hasAccount else { return }
        isCheckingBiometrics = true
        let result = await biometric.authenticate()
        isCheckingBiometrics = false
        switch result {
        case .success:
            completeLogin()
        case .failed:
            errorMessage = "Face ID did not match. Please log in with your email and password."
        case .unavailable:
            errorMessage = "Face ID is not available. Please log in with your email and password."
        }
    }

    // MARK: - Sign up and log in

    /// Creates the account for a first-time user after validating every field.
    func signUp() {
        let name = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let mail = normalizedEmail
        guard name.count >= 2 else {
            errorMessage = "Please enter your full name."
            return
        }
        guard isValidEmail(mail) else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard password.count >= 6,
              password.contains(where: \.isLetter),
              password.contains(where: \.isNumber) else {
            errorMessage = "Password must be at least 6 characters and include a letter and a number."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        if store.save(name: name, email: mail, password: password) {
            completeLogin()
        } else {
            errorMessage = "Could not create the account. Please try again."
        }
    }

    /// Logs in an existing user with email and password.
    func login() {
        let mail = normalizedEmail
        guard !mail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        guard isValidEmail(mail) else {
            errorMessage = "Please enter a valid email address."
            return
        }
        if store.verify(email: mail, password: password) {
            completeLogin()
        } else {
            errorMessage = "Invalid email or password."
        }
    }

    /// Removes the saved account so a new one can be created.
    func resetAccount() {
        store.deleteAccount()
        clearFields()
        currentUserName = ""
        mode = .signUp
    }

    func logout() {
        isAuthenticated = false
        clearFields()
        mode = store.hasAccount ? .login : .signUp
    }

    // MARK: - Helpers

    private func completeLogin() {
        currentUserName = store.savedName ?? ""
        clearFields()
        isAuthenticated = true
    }

    private func clearFields() {
        fullName = ""
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
    }

    private func isValidEmail(_ value: String) -> Bool {
        value.range(of: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$",
                    options: .regularExpression) != nil
    }
}
