//
//  SavedLocationsView.swift
//  WeatherApp
//
//  Displays persisted favorite locations and exposes selection and deletion actions.
//

import SwiftUI

struct SavedLocationsView: View {
    let savedLocations: [SavedLocation]
    let onSelect: (SavedLocation) -> Void
    let onDelete: (SavedLocation) -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if savedLocations.isEmpty {
                    emptyState
                } else {
                    List(savedLocations) { savedLocation in
                        Button {
                            onSelect(savedLocation)
                        } label: {
                            SavedLocationRow(savedLocation: savedLocation)
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(role: .destructive) {
                                onDelete(savedLocation)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .accessibilityLabel("Delete \(savedLocation.locationName)")
                        }
                    }
                }
            }
            .navigationTitle("Saved Locations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done", action: onDismiss)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "heart")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text("No Saved Locations")
                .font(.title3.weight(.bold))

            Text("Save a location from the current weather card to return to it quickly.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

struct SavedLocationRow: View {
    let savedLocation: SavedLocation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(savedLocation.locationName)
                .font(.headline)
                .foregroundStyle(.primary)

            if !savedLocation.regionDescription.isEmpty {
                Text(savedLocation.regionDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(savedLocation.coordinateText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        [savedLocation.locationName, savedLocation.regionDescription]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}
