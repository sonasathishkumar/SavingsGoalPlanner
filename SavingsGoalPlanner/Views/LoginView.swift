import SwiftUI

/// Entry screen. First-time users create an account; existing users log in (Face ID or email and password).
struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var showPassword = false
    @State private var showResetAlert = false

    private var isSignUp: Bool { auth.mode == .signUp }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                formCard
                footer
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .task { await auth.startLaunchAuthentication() }
        .alert("Reset account?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) { auth.resetAccount() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the saved login on this device so you can create a new account. Your savings goals are not deleted.")
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "indianrupeesign.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.tint)
            Text("Savings Goal Planner")
                .font(.title.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 24)
    }

    private var subtitle: String {
        if isSignUp { return "Create your account to get started" }
        if auth.currentUserName.isEmpty { return "Welcome back" }
        return "Welcome back, \(auth.currentUserName)"
    }

    private var formCard: some View {
        VStack(spacing: 14) {
            Text(isSignUp ? "Create Account" : "Log In")
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            if isSignUp {
                AuthTextField(icon: "person", placeholder: "Full name",
                              text: $auth.fullName, capitalization: .words)
            }
            AuthTextField(icon: "envelope", placeholder: "Email",
                          text: $auth.email, keyboard: .emailAddress)
            AuthSecureField(placeholder: "Password",
                            text: $auth.password, isVisible: $showPassword)
            if isSignUp {
                AuthSecureField(placeholder: "Confirm password",
                                text: $auth.confirmPassword, isVisible: $showPassword)
                Text("Use at least 6 characters with a letter and a number.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let message = auth.errorMessage {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                if isSignUp { auth.signUp() } else { auth.login() }
            } label: {
                Text(isSignUp ? "Create Account" : "Log In")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            if !isSignUp {
                Button {
                    Task { await auth.authenticateWithBiometrics() }
                } label: {
                    Label("Log in with Face ID", systemImage: "faceid")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(auth.isCheckingBiometrics)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }

    @ViewBuilder
    private var footer: some View {
        if !isSignUp {
            Button("Forgot password? Reset account") { showResetAlert = true }
                .font(.footnote)
        }
    }
}
