// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

@MainActor
struct CityPicker: View {
    @Bindable var settings: SettingsStore
    @State var search: CitySearchViewModel

    @State private var pendingCity: City?
    @State private var showConfirmation: Bool = false

    private let fallbackCities: [City] = [.limassol, .nicosia, .paphos]

    private var displayedCities: [City] {
        if search.searchQuery.trimmingCharacters(in: .whitespaces).count >= 2 {
            return search.results
        }
        if let selected = settings.selectedCity, !fallbackCities.contains(where: { $0.id == selected.id }) {
            return [selected] + fallbackCities
        }
        return fallbackCities
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            searchField
            Divider()
            citiesListView
                .frame(height: 180)
                .background(Color(nsColor: .textBackgroundColor))
            Divider()
            bottomBar
                .animation(.easeInOut(duration: 0.2), value: pendingCity)
                .animation(.easeInOut(duration: 0.2), value: showConfirmation)
        }
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .task(id: search.searchQuery) {
            await search.search()
        }
    }

    // MARK: - Subviews

    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.system(size: 11))
            TextField(L10n.Settings.searchCities, text: $search.searchQuery)
                .textFieldStyle(.plain)
                .font(.system(size: 12.5))
                .frame(maxWidth: .infinity, alignment: .leading)
            if search.isSearching {
                ProgressView().controlSize(.small)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color(nsColor: .textBackgroundColor))
    }

    @ViewBuilder
    private var citiesListView: some View {
        if let searchError = search.searchError {
            placeholderText(searchError)
        } else if displayedCities.isEmpty {
            placeholderText(L10n.Settings.noMatches)
        } else {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 2) {
                    ForEach(displayedCities) { city in
                        CityRow(
                            city: city,
                            state: rowState(for: city),
                            onTap: { tap(city) }
                        )
                    }
                }
                .padding(4)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func placeholderText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
    }

    @ViewBuilder
    private var bottomBar: some View {
        if let pendingCity {
            ConfirmBar(
                city: pendingCity,
                onConfirm: { confirm(pendingCity) },
                onCancel: { self.pendingCity = nil }
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        } else if showConfirmation {
            SuccessToast(cityName: settings.selectedCity?.name ?? "")
                .transition(.opacity.combined(with: .move(edge: .top)))
        } else {
            UseMyLocationBar(search: search, settings: settings)
                .transition(.opacity)
        }
    }

    // MARK: - Row state

    private func rowState(for city: City) -> CityRow.State {
        if let pendingCity, pendingCity.id == city.id {
            return .pending
        }
        if pendingCity == nil, settings.selectedCity?.id == city.id {
            return .active
        }
        return .inactive
    }

    private func tap(_ city: City) {
        if pendingCity == nil, settings.selectedCity?.id == city.id {
            return
        }
        pendingCity = city
        showConfirmation = false
    }

    private func confirm(_ city: City) {
        settings.selectedCity = city
        pendingCity = nil
        showConfirmation = true
        search.searchQuery = ""
        Task {
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            await MainActor.run {
                showConfirmation = false
            }
        }
    }
}

// MARK: - Row

struct CityRow: View {
    enum State {
        case active
        case pending
        case inactive
    }

    let city: City
    let state: State
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                checkmarkSlot
                VStack(alignment: .leading, spacing: 1) {
                    Text(city.name)
                        .font(.system(size: 12.5, weight: .medium))
                    if let region = city.region, !region.isEmpty {
                        Text(region)
                            .font(.system(size: 10.5))
                            .foregroundStyle(regionColor)
                    }
                }
                Spacer(minLength: 6)
                Text(city.formattedCoordinates)
                    .font(.system(size: 10.5).monospacedDigit())
                    .foregroundStyle(coordinateColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(rowBackground, in: RoundedRectangle(cornerRadius: 4))
            .foregroundStyle(foreground)
            .contentShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
    }

    private var checkmarkSlot: some View {
        ZStack {
            if state == .active {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(width: 16, height: 16)
    }

    private var rowBackground: Color {
        switch state {
        case .pending:  return Color.accentColor
        case .active, .inactive: return .clear
        }
    }

    private var foreground: Color {
        switch state {
        case .pending: return .white
        case .active, .inactive: return .primary
        }
    }

    private var regionColor: Color {
        switch state {
        case .pending: return Color.white.opacity(0.85)
        case .active, .inactive: return .secondary
        }
    }

    private var coordinateColor: Color {
        switch state {
        case .pending: return Color.white.opacity(0.85)
        case .active, .inactive: return Color.primary.opacity(0.35)
        }
    }
}

// MARK: - Confirm bar

private struct ConfirmBar: View {
    let city: City
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 1) {
                Text(L10n.Settings.switchToCityPrompt(city.name))
                    .font(.system(size: 12, weight: .medium))
                Text(L10n.Settings.switchToCitySubtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(L10n.Settings.cancel, action: onCancel)
                .buttonStyle(.bordered)
                .controlSize(.small)
            Button(L10n.Settings.setCity, action: onConfirm)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.accentColor.opacity(0.09))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(height: 0.5)
        }
    }
}

// MARK: - Success toast

private struct SuccessToast: View {
    let cityName: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 12, weight: .medium))
            Text(L10n.Settings.locationUpdatedToast(cityName))
                .font(.system(size: 11.5, weight: .medium))
            Spacer()
        }
        .foregroundStyle(Color.green)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.green.opacity(0.1))
    }
}

// MARK: - Use-my-location footer

private struct UseMyLocationBar: View {
    @State var search: CitySearchViewModel
    @Bindable var settings: SettingsStore

    var body: some View {
        HStack {
            Spacer()
            Button {
                Task { await search.useCurrentLocation(applyingTo: settings) }
            } label: {
                HStack(spacing: 6) {
                    if search.isLocating {
                        ProgressView().controlSize(.small)
                    }
                    Label(
                        search.isLocating ? L10n.Settings.locating : L10n.Settings.useMyLocation,
                        systemImage: search.isLocating ? "location.fill" : "location"
                    )
                    .labelStyle(.titleAndIcon)
                    .font(.system(size: 12))
                }
            }
            .disabled(search.isLocating)
        }
        .padding(6)
    }
}
