//
//  LocationResultsView.swift
//  WeatherApp
//
//  Presents multiple Open-Meteo geocoding matches so the user can choose the intended location.
//

import SwiftUI

struct LocationResultsView: View {
    let locations: [LocationResult]
    let onSelect: (LocationResult) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            List(locations) { location in
                Button {
                    onSelect(location)
                } label: {
                    LocationResultRow(location: location)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

struct LocationResultRow: View {
    let location: LocationResult

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(location.name)
                .font(.headline)
                .foregroundStyle(.primary)

            if !location.coordinateDescription.isEmpty {
                Text(location.coordinateDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(location.detailDescription.isEmpty ? location.coordinateText : location.detailDescription)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(location.coordinateText)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        [location.name, location.coordinateDescription, location.timeZone]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

struct LocationResultsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationResultsView(
            locations: [
                LocationResult(openMeteoID: 1, name: "Murfreesboro", latitude: 35.8456, longitude: -86.3903, country: "United States", admin1: "Tennessee", timeZone: "America/Chicago", population: 165430),
                LocationResult(openMeteoID: 2, name: "Murfreesboro", latitude: 36.442, longitude: -76.608, country: "United States", admin1: "North Carolina", timeZone: "America/New_York", population: 2800)
            ],
            onSelect: { _ in },
            onCancel: {}
        )
    }
}
