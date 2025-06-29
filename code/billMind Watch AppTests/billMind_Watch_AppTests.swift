//
//  billMind_Watch_AppTests.swift
//  billMind Watch AppTests
//
//  Created by Pasindu Dinal on 2025-06-28.
//

import XCTest
import SwiftData
@testable import billMind_Watch_App

/// Basic unit tests for shared business-logic running on the watchOS target.
/// These tests focus on the `Bill` model which is shared across all platforms.
final class billMind_Watch_AppTests: XCTestCase {

    /// Verifies that an unpaid bill dated in the past is reported as overdue on watchOS.
    func testBillIsOverdue() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let bill = Bill(name: "Overdue", date: pastDate, amount: 100.0)
        XCTAssertTrue(bill.isOverdue)
    }

    /// Ensures the `nextDate()` helper correctly advances the date for daily recurring bills.
    func testNextDateDailyFrequency() {
        let baseDate = Date()
        let bill = Bill(name: "Daily", date: baseDate, amount: 42.0, frequency: .daily)

        guard let next = bill.nextDate() else {
            return XCTFail("nextDate() returned nil for daily frequency")
        }

        let days = Calendar.current.dateComponents([.day], from: baseDate, to: next).day ?? 0
        XCTAssertEqual(days, 1)
    }
}
