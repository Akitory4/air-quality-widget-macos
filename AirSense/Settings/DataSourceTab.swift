// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import AppKit
import SwiftUI

private enum WAQIStatus: Equatable {
    case idle
    case testing
    case success(String)
    case failure(String)

    var text: String? {
        switch self {
        case .idle:              return nil
        case .testing:           return L10n.Common.loading
        case .success(let msg):  return msg
        case .failure(let msg):  return msg
        }
    }

    var tint: Color {
        switch self {
        case .success: return .green
        case .failure: return .red
        case .testing: return .secondary
        case .idle:    return .secondary
        }
    }
}

struct DataSourceTab: View {
    @Bindable var settings: SettingsStore
    let tokenStore: TokenStore
    let waqiService: AirQualityService

    @State private var tokenDraft: String = ""
    @State private var hasSavedToken: Bool = false
    @State private var status: WAQIStatus = .idle

    private static let signupURL = ServiceEndpoints.WAQI.tokenSignup

    var body: some View {
        Form {
            Section {
                LabeledContent(L10n.Settings.provider) {
                    VStack(alignment: .leading, spacing: 4) {
                        Picker(L10n.Settings.provider, selection: $settings.provider) {
                            Text(L10n.Settings.providerOpenMeteo).tag(AQIProvider.openMeteo)
                            Text(L10n.Settings.providerWAQI).tag(AQIProvider.waqi)
                        }
                        .pickerStyle(.radioGroup)
                        .labelsHidden()
                        Text(L10n.Settings.providerDescription)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            if settings.provider == .waqi {
                Section(L10n.Settings.providerWAQI) {
                    LabeledContent(L10n.Settings.waqiTokenLabel) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                SecureField(L10n.Settings.waqiTokenPlaceholder, text: $tokenDraft)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(minWidth: 220)
                                Button(L10n.Settings.waqiTokenSave) {
                                    saveToken()
                                }
                                .disabled(tokenDraft.trimmingCharacters(in: .whitespaces).isEmpty)
                                Button(L10n.Settings.waqiTokenClear) {
                                    clearToken()
                                }
                                .disabled(!hasSavedToken && tokenDraft.isEmpty)
                            }
                            HStack(spacing: 12) {
                                Button(L10n.Settings.waqiGetToken) {
                                    NSWorkspace.shared.open(Self.signupURL)
                                }
                                .buttonStyle(.link)
                                Button(L10n.Settings.waqiTestConnection) {
                                    Task { await testConnection() }
                                }
                                .disabled(!hasSavedToken || status == .testing)
                            }
                            if let text = status.text {
                                Text(text)
                                    .font(.system(size: 11))
                                    .foregroundStyle(status.tint)
                            } else {
                                Text(hasSavedToken
                                     ? L10n.Settings.waqiTokenSaved
                                     : L10n.Settings.waqiTokenMissing)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                            Text(L10n.Settings.waqiAttribution)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .onAppear { refreshTokenState() }
    }

    // MARK: - Actions

    private func refreshTokenState() {
        do {
            let existing = try tokenStore.get()
            hasSavedToken = (existing?.isEmpty == false)
            // Show placeholder dots — never the real token.
            tokenDraft = hasSavedToken ? String(repeating: "•", count: 12) : ""
        } catch {
            hasSavedToken = false
            status = .failure(L10n.Settings.waqiKeychainUnavailable)
        }
    }

    private func saveToken() {
        let trimmed = tokenDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.allSatisfy({ $0 == "•" }) else { return }
        do {
            try tokenStore.set(trimmed)
            hasSavedToken = true
            tokenDraft = String(repeating: "•", count: 12)
            status = .success(L10n.Settings.waqiTokenSaved)
        } catch {
            status = .failure(L10n.Settings.waqiKeychainUnavailable)
        }
    }

    private func clearToken() {
        do {
            try tokenStore.delete()
            hasSavedToken = false
            tokenDraft = ""
            status = .idle
        } catch {
            status = .failure(L10n.Settings.waqiKeychainUnavailable)
        }
    }

    private func testConnection() async {
        status = .testing
        let city = settings.selectedCity ?? .limassol
        do {
            _ = try await waqiService.fetchSnapshot(for: city, standard: .usEpa)
            status = .success(L10n.Settings.waqiConnectionOK)
        } catch {
            status = .failure(error.userFacingMessage)
        }
    }
}
