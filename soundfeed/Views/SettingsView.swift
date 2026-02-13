import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    private var buttonTint: Color {
        colorScheme == .dark ? Color(.systemGray3) : Color(.darkGray)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                settingsGroup(header: "Appearance") {
                    Picker("Theme", selection: $appTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.label).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                settingsGroup(header: "Sync", footer: "Soundfeed automatically syncs periodically, but you can manually request syncing once every 15 minutes.") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sync Releases")
                                .font(.body)
                            if let lastSynced = viewModel.lastSynced {
                                Text("Last synced: \(lastSynced, style: .relative) ago")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Never synced")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        Button {
                            Task { await viewModel.syncReleases() }
                        } label: {
                            if viewModel.isSyncing {
                                ProgressView()
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .disabled(viewModel.isSyncing)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.circle)
                        .tint(buttonTint)
                    }
                }

                settingsGroup(header: "Recovery", footer: "This is your unique recovery code. If you delete the app, you can restore your artists using this code.") {
                    VStack(spacing: 12) {
                        if viewModel.recoveryCode.isEmpty && viewModel.isLoading {
                            ProgressView()
                        } else {
                            HStack {
                                Text("Your Code")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(viewModel.recoveryCode)
                                    .textSelection(.enabled)
                                    .monospaced()
                            }
                        }

                        Divider()

                        HStack {
                            TextField("Recovery code", text: $viewModel.recoveryInput)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .onChange(of: viewModel.recoveryInput) { oldValue, newValue in
                                    let filtered = newValue.uppercased().filter { $0.isLetter }

                                    var formatted = ""
                                    for (index, character) in filtered.enumerated() {
                                        if index > 0 && index % 3 == 0 {
                                            formatted.append("-")
                                        }
                                        formatted.append(character)
                                    }

                                    if formatted.count > 7 {
                                        formatted = String(formatted.prefix(7))
                                    }

                                    if formatted != newValue {
                                        viewModel.recoveryInput = formatted
                                    }
                                }

                            Button("Recover") {
                                Task { await viewModel.recover() }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(buttonTint)
                            .disabled(viewModel.recoveryInput.isEmpty)
                        }
                    }
                }

                settingsGroup(header: "Email", footer: "The email is not linked to your identity. It is only used to send a wrap of your recent releases, once a week.") {
                    VStack(spacing: 12) {
                        HStack {
                            TextField("Email address", text: $viewModel.email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()

                            Button("Save") {
                                Task { await viewModel.saveEmail() }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(buttonTint)
                            .disabled(viewModel.email.isEmpty)
                        }

                        Divider()

                        Toggle("Receive digest emails", isOn: Binding(
                            get: { viewModel.emailNotifications },
                            set: { newValue in
                                Task { await viewModel.toggleNotifications(newValue) }
                            }
                        ))
                            .tint(buttonTint)
                            .disabled(viewModel.email.isEmpty)
                    }
                }

                if let error = viewModel.error {
                    settingsGroup {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }

                if let success = viewModel.successMessage {
                    settingsGroup {
                        Label(success, systemImage: "checkmark.circle")
                            .foregroundStyle(.green)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await viewModel.loadUser()
            await viewModel.loadSync()
        }
    }

    private func settingsGroup<Content: View>(header: String? = nil, footer: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let header {
                Text(header)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            content()
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            if let footer {
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.top, 18)
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
