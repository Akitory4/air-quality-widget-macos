// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alex Efimov

import SwiftUI

struct AboutTab: View {
    @Bindable var viewModel: AirQualityViewModel

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }
    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }

    /// Station-level credits from the current snapshot. Required by WAQI ToS.
    private var currentAttributions: [String] {
        switch viewModel.state {
        case .loaded(let s), .refreshing(let s), .stale(let s, _):
            return s.attributions ?? []
        case .error(_, let last):
            return last?.attributions ?? []
        case .empty, .loading:
            return []
        }
    }

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "aqi.medium")
                .font(.system(size: 48, weight: .regular))
                .foregroundStyle(Color(hex: 0xF7C948))
                .padding(.top, 20)
            Text(L10n.Common.appName)
                .font(.system(size: 22, weight: .semibold))
            Text(L10n.About.version(version, build))
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            VStack(spacing: 4) {
                Text(L10n.About.tagline)
                HStack(spacing: 4) {
                    Text(L10n.Common.dataBy)
                    Link(L10n.Common.openMeteo, destination: ServiceEndpoints.OpenMeteo.website)
                    Text("·")
                    Link(L10n.Common.waqi, destination: ServiceEndpoints.WAQI.website)
                }
            }
            .font(.system(size: 12))
            .foregroundStyle(.secondary)

            if !currentAttributions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Common.attributions)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                    ForEach(currentAttributions, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 10.5))
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.top, 6)
                .padding(.horizontal, 24)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}
