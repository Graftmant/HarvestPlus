//
//  HolidaysSettingsTab.swift
//  HarvestPlus
//
//  Created by Razvan Politic on 14/04/2026.
//
//  Holidays settings: the holiday task names used to recognize holiday entries,
//  custom non-working dates, and an optional ICS URL.
//

import SwiftUI

// MARK: - Holidays Settings Tab

struct HolidaysSettingsTab: View {
    @EnvironmentObject var appState: AppState

    @State private var icsURL: String = ""
    @State private var customDates: [Date] = []
    @State private var holidayTaskNames: String = "Holiday"
    @State private var newCustomDate: Date = Date()

    var body: some View {
        Form {
            Section("External Calendar") {
                TextField("Holiday .ics URL", text: $icsURL)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: icsURL) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "holidayICSUrl")
                        appState.settings.holidayICSUrl = newValue
                    }

                Text("Paste a URL to an .ics calendar feed for additional non-working days.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Custom Non-Working Days") {
                ForEach(customDates, id: \.self) { date in
                    HStack {
                        Text(formatDate(date))
                        Spacer()
                        Button {
                            customDates.removeAll { $0 == date }
                            saveCustomDates()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack {
                    DatePicker("Add date", selection: $newCustomDate, displayedComponents: .date)
                        .labelsHidden()

                    Button("Add") {
                        let startOfDay = Calendar.current.startOfDay(for: newCustomDate)
                        if !customDates.contains(startOfDay) {
                            customDates.append(startOfDay)
                            customDates.sort()
                            saveCustomDates()
                        }
                    }
                }
            }

            Section("Holiday Task Names") {
                TextField("Comma-separated task names", text: $holidayTaskNames)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: holidayTaskNames) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "holidayTaskNames")
                        appState.settings.holidayTaskNames = newValue
                    }

                Text("Time entries with these task names are treated as vacation/holiday hours. Case-insensitive.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .onAppear { loadSettings() }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // MARK: - Persistence

    private func loadSettings() {
        let ud = UserDefaults.standard
        icsURL = ud.string(forKey: "holidayICSUrl") ?? ""
        holidayTaskNames = ud.string(forKey: "holidayTaskNames") ?? "Holiday"

        let dateStrings = ud.stringArray(forKey: "customNonWorkingDates") ?? []
        let formatter = ISO8601DateFormatter()
        customDates = dateStrings.compactMap { formatter.date(from: $0) }.sorted()
    }

    private func saveCustomDates() {
        let formatter = ISO8601DateFormatter()
        let dateStrings = customDates.map { formatter.string(from: $0) }
        UserDefaults.standard.set(dateStrings, forKey: "customNonWorkingDates")
        HolidayEngine.invalidateCache()
    }
}
