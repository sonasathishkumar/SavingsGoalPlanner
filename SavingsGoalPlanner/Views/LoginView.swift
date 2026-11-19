import SwiftUI

/// Launch screen: tries Face ID first, falls back to a local manual login.
struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "faceid").font(.system(size: 64)).foregroundStyle(.tint)
            Text("Savings Goal Planner").font(.title.bold())

            if auth.showManualLogin {
                VStack(spacing: 12) {
                    TextField("Username", text: $auth.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    SecureField("Password", text: $auth.password)
                        .textFieldStyle(.roundedBorder)
                    Button("Log In") { auth.manualLogin() }
                        .buttonStyle(.borderedProminent)
                    Button("Try Face ID again") { Task { await auth.authenticateWithBiometrics() } }
                        .font(.footnote)
                    Text("Demo login: admin / 1234").font(.caption).foregroundStyle(.secondary)
                }
            } else {
                ProgressView("Authenticating…")
            }

            if let message = auth.errorMessage {
                Text(message).font(.footnote).foregroundStyle(.red).multilineTextAlignment(.center)
            }

        }
        .padding(32)
        .task { await auth.authenticateWithBiometrics() }
    }
}
