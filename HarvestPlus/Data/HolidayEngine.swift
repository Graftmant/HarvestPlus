//
//  HolidayEngine.swift
//  HarvestPlus
//
//  Created by Razvan Politic on 14/04/2026.
//
//  Computes non-working days from weekends (per the work schedule) plus the
//  user's own custom non-working dates, behind a per-year cache. The overtime
//  calculator uses it to zero out targets on days off.
//

import Foundation

// MARK: - Holiday Engine

struct HolidayEngine {

    // MARK: - Cache

    /// Cached non-working date keys per year ("yyyy-MM-dd" -> Set lookup).
    /// Built once per year on first access; avoids repeated UserDefaults reads
    /// and ISO-8601 parsing on every isNonWorkingDay() call.
    private static var nonWorkingDaysCache: [Int: Set<String>] = [:]

    private static let dateKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// Invalidate the non-working days cache (call when holiday settings change).
    static func invalidateCache() {
        nonWorkingDaysCache.removeAll()
    }

    /// Build or retrieve the set of custom non-working date keys for a year.
    /// On cache miss: reads UserDefaults once, parses once, caches the result.
    /// On cache hit: returns immediately (O(1)).
    private static func nonWorkingDateKeys(year: Int) -> Set<String> {
        if let cached = nonWorkingDaysCache[year] {
            return cached
        }

        let customDateStrings = UserDefaults.standard.stringArray(forKey: "customNonWorkingDates") ?? []

        var days = Set<String>()

        // Custom non-working dates (stored for all years, keyed by yyyy-MM-dd
        // so only the matching year's dates hit on lookup).
        let isoFormatter = ISO8601DateFormatter()
        for dateStr in customDateStrings {
            if let date = isoFormatter.date(from: dateStr) {
                days.insert(dateKeyFormatter.string(from: date))
            }
        }

        nonWorkingDaysCache[year] = days
        return days
    }

    // MARK: - Non-Working Day Check

    /// Returns true if the given date is a non-working day: a weekend (a day
    /// whose target is 0) or one of the user's custom non-working dates. Uses a
    /// per-year cache so repeated calls (e.g. 365 days) only compute once.
    static func isNonWorkingDay(_ date: Date, settings: AppSettings) -> Bool {
        // Zero-target day (weekend) - no I/O, instant.
        if settings.workSchedule.dailyTarget(for: date) == 0 { return true }

        // Custom non-working date - cached set lookup.
        let year = Calendar.current.component(.year, from: date)
        let days = nonWorkingDateKeys(year: year)
        let key = dateKeyFormatter.string(from: date)
        return days.contains(key)
    }

    /// Returns the expected work hours for a given date, accounting for days off.
    static func expectedHours(for date: Date, settings: AppSettings) -> Double {
        if isNonWorkingDay(date, settings: settings) {
            return 0
        }
        return settings.workSchedule.dailyTarget(for: date)
    }

    // MARK: - Holiday Task Detection

    /// Returns true if the given task name matches one of the configured holiday task names.
    static func isHolidayTask(taskName: String, settings: AppSettings) -> Bool {
        let names = settings.holidayTaskNames
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        return names.contains(taskName.lowercased())
    }
}
