import SwiftUI
import Combine

/// Handles Face ID and the local manual-login fallback.
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showManualLogin = false
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage: String?

    private let biometric = BiometricService()
    // Demo credentials for the local fallback login.
    private let validUsername = "admin"
    private let validPassword = "1234"

    func authenticateWithBiometrics() async {
        switch await biometric.authenticate() {
        case .success:
            errorMessage = nil
            isAuthenticated = true
        case .failed(let message):
            errorMessage = "Face ID failed: \(message)"
            showManualLogin = true
        case .unavailable:
            errorMessage = "Face ID is not available. Please log in manually."
            showManualLogin = true
        }
    }

    func manualLogin() {
        let user = username.trimmingCharacters(in: .whitespaces)
        guard !user.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password are required."
            return
        }
        guard password.count >= 4 else {
            errorMessage = "Password must be at least 4 characters."
            return
        }
        if user == validUsername && password == validPassword {
            errorMessage = nil
            isAuthenticated = true
        } else {
            errorMessage = "Invalid username or password."
        }
    }

    func logout() {
        isAuthenticated = false
        username = ""
        password = ""
        errorMessage = nil
        showManualLogin = false
    }
}
