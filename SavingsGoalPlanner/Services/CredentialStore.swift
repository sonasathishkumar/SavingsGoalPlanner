import Foundation
import Security

/// Stores the local account. Name and email live in UserDefaults; the password lives in the Keychain.
struct CredentialStore {
    private let service = "SavingsGoalPlanner"
    private let emailKey = "account_email"
    private let nameKey = "account_name"

    var savedEmail: String? { UserDefaults.standard.string(forKey: emailKey) }
    var savedName: String? { UserDefaults.standard.string(forKey: nameKey) }
    var hasAccount: Bool { savedEmail != nil }

    /// Saves a new account, replacing any previous one. Returns false if the Keychain write fails.
    func save(name: String, email: String, password: String) -> Bool {
        deleteKeychainItems()
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: email,
            kSecValueData as String: Data(password.utf8)
        ]
        guard SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess else { return false }
        UserDefaults.standard.set(email, forKey: emailKey)
        UserDefaults.standard.set(name, forKey: nameKey)
        return true
    }

    /// Checks the email and password against the saved account.
    func verify(email: String, password: String) -> Bool {
        guard email == savedEmail else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: email,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let stored = String(data: data, encoding: .utf8) else { return false }
        return stored == password
    }

    /// Removes the saved account (used by "Reset account").
    func deleteAccount() {
        deleteKeychainItems()
        UserDefaults.standard.removeObject(forKey: emailKey)
        UserDefaults.standard.removeObject(forKey: nameKey)
    }

    private func deleteKeychainItems() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }
}
