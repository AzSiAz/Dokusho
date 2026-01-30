//
//  TsundokuConfiguration.swift
//  Dokusho
//
//  Created by Claude on 30/01/2026.
//

import Foundation
import CryptoKit
import Security

public final class TsundokuConfiguration: @unchecked Sendable {
    public static let shared = TsundokuConfiguration()

    private let defaults = UserDefaults.standard

    private let apiUrlKey = "TSUNDOKU_API_URL"
    private let apiKeyKeychainKey = "com.dokusho.tsundoku.apikey"
    private let displayNameKey = "TSUNDOKU_DISPLAY_NAME"

    public var apiUrl: String {
        get {
            var url = defaults.string(forKey: apiUrlKey) ?? ""
            url = url.trimmingCharacters(in: .whitespacesAndNewlines)
            while url.hasSuffix("/") {
                url.removeLast()
            }
            return url
        }
        set {
            var url = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            while url.hasSuffix("/") {
                url.removeLast()
            }
            defaults.set(url, forKey: apiUrlKey)
        }
    }

    public var apiKey: String {
        get { KeychainHelper.get(key: apiKeyKeychainKey) ?? "" }
        set {
            if newValue.isEmpty {
                KeychainHelper.delete(key: apiKeyKeychainKey)
            } else {
                KeychainHelper.set(key: apiKeyKeychainKey, value: newValue)
            }
        }
    }

    public var displayName: String {
        get { defaults.string(forKey: displayNameKey) ?? "" }
        set { defaults.set(newValue, forKey: displayNameKey) }
    }

    public var isConfigured: Bool {
        !apiUrl.isEmpty && !apiKey.isEmpty
    }

    public func validate() -> ValidationResult {
        if apiUrl.isEmpty {
            return .failure("Server URL is required")
        }

        guard let url = URL(string: apiUrl) else {
            return .failure("Invalid URL format")
        }

        guard url.scheme == "http" || url.scheme == "https" else {
            return .failure("URL must start with http:// or https://")
        }

        if apiKey.isEmpty {
            return .failure("API key is required")
        }

        return .success
    }

    public func generateSourceId(suffix: String = "") -> UUID {
        let key = "tsundoku/\(apiUrl)\(suffix)"
        let data = Data(key.utf8)
        let hash = Insecure.MD5.hash(data: data)

        let hashBytes = Array(hash)
        var uuidBytes = [UInt8](repeating: 0, count: 16)
        for i in 0..<min(16, hashBytes.count) {
            uuidBytes[i] = hashBytes[i]
        }

        return UUID(uuid: (
            uuidBytes[0], uuidBytes[1], uuidBytes[2], uuidBytes[3],
            uuidBytes[4], uuidBytes[5], uuidBytes[6], uuidBytes[7],
            uuidBytes[8], uuidBytes[9], uuidBytes[10], uuidBytes[11],
            uuidBytes[12], uuidBytes[13], uuidBytes[14], uuidBytes[15]
        ))
    }

    public func clear() {
        defaults.removeObject(forKey: apiUrlKey)
        defaults.removeObject(forKey: displayNameKey)
        KeychainHelper.delete(key: apiKeyKeychainKey)
    }

    public enum ValidationResult: Equatable {
        case success
        case failure(String)

        public var isValid: Bool {
            if case .success = self { return true }
            return false
        }

        public var errorMessage: String? {
            if case .failure(let message) = self { return message }
            return nil
        }
    }
}

// MARK: - Keychain Helper

private enum KeychainHelper {
    static func set(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
