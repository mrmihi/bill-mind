import XCTest
import SwiftData
@testable import billMind

final class BillTests: XCTestCase {
  
  func testNextDateForFrequencies() {
    let base = Date(timeIntervalSince1970: 0) // Jan 1, 1970 00:00 UTC
    let billNone = Bill(name: "One‑off", date: base, amount: 1, frequency: .none)
    XCTAssertNil(billNone.nextDate())

    let billDaily = Bill(name: "Daily", date: base, amount: 1, frequency: .daily)
    let nextDaily = billDaily.nextDate()!
    XCTAssertEqual(Calendar.current.dateComponents([.day], from: base, to: nextDaily).day, 1)

    let billWeekly = Bill(name: "Weekly", date: base, amount: 1, frequency: .weekly)
    XCTAssertEqual(Calendar.current.dateComponents([.weekOfYear], from: base, to: billWeekly.nextDate()!).weekOfYear, 1)

    let billMonthly = Bill(name: "Monthly", date: base, amount: 1, frequency: .monthly)
    XCTAssertEqual(Calendar.current.dateComponents([.month], from: base, to: billMonthly.nextDate()!).month, 1)

    let billYearly = Bill(name: "Yearly", date: base, amount: 1, frequency: .yearly)
    XCTAssertEqual(Calendar.current.dateComponents([.year], from: base, to: billYearly.nextDate()!).year, 1)
  }

  func testIsOverdueFlag() {
    let pastDate = Date(timeIntervalSinceNow: -3600)
    let futureDate = Date(timeIntervalSinceNow:  3600)
    let unpaidPast = Bill(name: "A", date: pastDate, amount: 1)
    XCTAssertTrue(unpaidPast.isOverdue)
    let unpaidFuture = Bill(name: "B", date: futureDate, amount: 1)
    XCTAssertFalse(unpaidFuture.isOverdue)
    let paidPast = Bill(name: "C", date: pastDate, amount: 1, isPaid: true)
    XCTAssertFalse(paidPast.isOverdue)
  }

    @MainActor func testSwiftDataInsertAndFetch() throws {
    let container = try ModelContainer(for: Bill.self)
    let context = container.mainContext
    
    let bill = Bill(name: "Test", date: .now, amount: 42, frequency: .daily)
    context.insert(bill)
    try context.save()

    let descriptor = FetchDescriptor<Bill>(
      sortBy: [ SortDescriptor<Bill>(\Bill.date) ]
    )
    let fetched = try context.fetch(descriptor)
    
    XCTAssertEqual(fetched.count, 1)
    XCTAssertEqual(fetched.first?.name, "Test")
    XCTAssertEqual(fetched.first?.frequency, .daily)
  }
}
