//
//  TsundokuSettingsView.swift
//  Dokusho
//
//  Created by Claude on 30/01/2026.
//

import SwiftUI
import MangaScraper

public struct TsundokuSettingsView: View {
    @State private var serverUrl: String = ""
    @State private var apiKey: String = ""
    @State private var displayName: String = ""
    @State private var connectionStatus: ConnectionStatus = .idle
    @State private var showApiKey: Bool = false

    private let config = TsundokuConfiguration.shared

    public init() {}

    public var body: some View {
        Form {
            headerSection
            serverConfigSection
            connectionTestSection
            saveSection
            clearSection
        }
        .navigationTitle("Tsundoku")
        .navigationBarTitleDisplayMode(.large)
        .onAppear(perform: loadConfiguration)
    }

    // MARK: - Sections

    private var headerSection: some View {
        Section {
            ServerHeaderView(status: connectionStatus)
        }
        .listRowBackground(Color.clear)
    }

    private var serverConfigSection: some View {
        Section {
            TextField("https://tsundoku.example.com", text: $serverUrl)
                .keyboardType(.URL)
                .textContentType(.URL)
                .autocapitalization(.none)
                .autocorrectionDisabled()

            HStack {
                Group {
                    if showApiKey {
                        TextField("API Key", text: $apiKey)
                    } else {
                        SecureField("API Key", text: $apiKey)
                    }
                }
                .textContentType(.password)
                .autocapitalization(.none)
                .autocorrectionDisabled()

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showApiKey.toggle()
                    }
                } label: {
                    Image(systemName: showApiKey ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
            }

            TextField("Display Name (optional)", text: $displayName)
                .autocapitalization(.none)
        } header: {
            Text("Server Configuration")
        } footer: {
            Text("Enter your Tsundoku server URL and API key. The display name customizes how this source appears in the app.")
        }
    }

    private var connectionTestSection: some View {
        Section {
            Button(action: testConnection) {
                HStack {
                    Label("Test Connection", systemImage: "antenna.radiowaves.left.and.right")
                    Spacer()
                    ConnectionStatusBadge(status: connectionStatus)
                }
            }
            .disabled(serverUrl.isEmpty || apiKey.isEmpty || connectionStatus == .testing)
        }
    }

    private var saveSection: some View {
        Section {
            Button(action: saveConfiguration) {
                HStack {
                    Spacer()
                    Label("Save Configuration", systemImage: "checkmark.circle.fill")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .disabled(!canSave)
        }
    }

    private var clearSection: some View {
        Section {
            Button(role: .destructive, action: clearConfiguration) {
                HStack {
                    Spacer()
                    Label("Clear Configuration", systemImage: "trash")
                    Spacer()
                }
            }
            .disabled(!config.isConfigured && serverUrl.isEmpty && apiKey.isEmpty)
        }
    }

    // MARK: - Computed Properties

    private var canSave: Bool {
        !serverUrl.isEmpty && !apiKey.isEmpty && hasChanges
    }

    private var hasChanges: Bool {
        serverUrl != config.apiUrl ||
        apiKey != config.apiKey ||
        displayName != config.displayName
    }

    // MARK: - Actions

    private func loadConfiguration() {
        serverUrl = config.apiUrl
        apiKey = config.apiKey
        displayName = config.displayName

        if config.isConfigured {
            connectionStatus = .idle
        }
    }

    private func testConnection() {
        guard !serverUrl.isEmpty, !apiKey.isEmpty else { return }

        connectionStatus = .testing
        triggerHaptic(.light)

        Task {
            do {
                let testUrl = "\(normalizedUrl)/api/v1/serie?page=1&pageSize=1"
                guard let url = URL(string: testUrl) else {
                    throw ConnectionError.invalidUrl
                }

                var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
                request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
                request.setValue("DokushoiOS/1.0", forHTTPHeaderField: "User-Agent")
                request.setValue("application/json", forHTTPHeaderField: "Accept")

                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw ConnectionError.invalidResponse
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                        throw ConnectionError.unauthorized
                    }
                    throw ConnectionError.serverError(httpResponse.statusCode)
                }

                let decoder = JSONDecoder()
                let result = try decoder.decode(TsundokuConnectionTestResponse.self, from: data)

                await MainActor.run {
                    let count = result.pagination?.total ?? 0
                    connectionStatus = .success(seriesCount: count)
                    triggerHaptic(.success)
                }
            } catch {
                await MainActor.run {
                    let message = errorMessage(for: error)
                    connectionStatus = .error(message: message)
                    triggerHaptic(.error)
                }
            }
        }
    }

    private func saveConfiguration() {
        config.apiUrl = normalizedUrl
        config.apiKey = apiKey
        config.displayName = displayName

        triggerHaptic(.success)

        if case .success = connectionStatus {
            // Keep success status
        } else {
            connectionStatus = .idle
        }
    }

    private func clearConfiguration() {
        config.clear()
        serverUrl = ""
        apiKey = ""
        displayName = ""
        connectionStatus = .idle
        triggerHaptic(.light)
    }

    private var normalizedUrl: String {
        var url = serverUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        if url.hasSuffix("/") {
            url.removeLast()
        }
        return url
    }

    private func errorMessage(for error: Error) -> String {
        if let connectionError = error as? ConnectionError {
            return connectionError.localizedDescription
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection"
            case .timedOut:
                return "Connection timed out"
            case .cannotFindHost:
                return "Server not found"
            default:
                return "Network error"
            }
        }
        return "Connection failed"
    }

    private func triggerHaptic(_ type: HapticType) {
        switch type {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }

    // MARK: - Types

    enum HapticType {
        case light, success, error
    }

    enum ConnectionError: LocalizedError {
        case invalidUrl
        case invalidResponse
        case unauthorized
        case serverError(Int)

        var errorDescription: String? {
            switch self {
            case .invalidUrl:
                return "Invalid server URL"
            case .invalidResponse:
                return "Invalid server response"
            case .unauthorized:
                return "Invalid API key"
            case .serverError(let code):
                return "Server error (\(code))"
            }
        }
    }
}

// MARK: - Connection Status

enum ConnectionStatus: Equatable {
    case idle
    case testing
    case success(seriesCount: Int)
    case error(message: String)

    var statusText: String {
        switch self {
        case .idle:
            return "Not tested"
        case .testing:
            return "Testing..."
        case .success(let count):
            return "\(count) series"
        case .error(let message):
            return message
        }
    }

    var statusColor: Color {
        switch self {
        case .idle:
            return .secondary
        case .testing:
            return .blue
        case .success:
            return .green
        case .error:
            return .red
        }
    }

    var statusGradient: LinearGradient {
        switch self {
        case .idle:
            return LinearGradient(
                colors: [.gray.opacity(0.6), .gray.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .testing:
            return LinearGradient(
                colors: [.blue.opacity(0.8), .blue.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .success:
            return LinearGradient(
                colors: [.green.opacity(0.8), .green.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .error:
            return LinearGradient(
                colors: [.red.opacity(0.8), .red.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Server Header View

struct ServerHeaderView: View {
    let status: ConnectionStatus

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(status.statusGradient)
                    .frame(width: 56, height: 56)

                Image(systemName: "server.rack")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
            }
            .animation(.easeInOut(duration: 0.3), value: status)

            VStack(alignment: .leading, spacing: 4) {
                Text("Tsundoku Server")
                    .font(.headline)

                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private var statusMessage: String {
        switch status {
        case .idle:
            return "Configure your server connection"
        case .testing:
            return "Testing connection..."
        case .success(let count):
            return "Connected - \(count) series available"
        case .error(let message):
            return message
        }
    }
}

// MARK: - Connection Status Badge

struct ConnectionStatusBadge: View {
    let status: ConnectionStatus

    var body: some View {
        HStack(spacing: 6) {
            statusIndicator

            Text(status.statusText)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(status.statusColor.opacity(0.12))
        .foregroundStyle(status.statusColor)
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.2), value: status)
    }

    @ViewBuilder
    private var statusIndicator: some View {
        switch status {
        case .idle:
            Circle()
                .fill(status.statusColor)
                .frame(width: 6, height: 6)
        case .testing:
            ProgressView()
                .scaleEffect(0.6)
                .frame(width: 12, height: 12)
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
        case .error:
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 12))
        }
    }
}

#Preview {
    NavigationStack {
        TsundokuSettingsView()
    }
}
