import LocalAuthentication

enum BiometricResult {
    case success
    case failed(String)
    case unavailable
}

/// Wraps LocalAuthentication (Face ID / Touch ID).
struct BiometricService {
    func authenticate() async -> BiometricResult {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .unavailable
        }
        do {
            let ok = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock your savings goals")
            return ok ? .success : .failed("Authentication failed.")
        } catch {
            return .failed(error.localizedDescription)
        }
    }
}

