import XCTest
import SwiftData
@testable import billMind

final class BillModelTests: XCTestCase {
    
    var modelContext: ModelContext!
    var container: ModelContainer!
    
    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Bill.self, Transaction.self, configurations: config)
        modelContext = ModelContext(container)
    }
    
    override func tearDownWithError() throws {
        modelContext = nil
        container = nil
    }
    
    // MARK: - Bill Creation Tests
    
    func testBillCreation() throws {
        let bill = Bill(
            name: "Electricity Bill",
            date: Date(),
            amount: 1500.0,
            category: .utilities,
            paymentMode: .card,
            frequency: .monthly
        )
        
        XCTAssertEqual(bill.name, "Electricity Bill")
        XCTAssertEqual(bill.amount, 1500.0)
        XCTAssertEqual(bill.category, .utilities)
        XCTAssertEqual(bill.paymentMode, .card)
        XCTAssertEqual(bill.frequency, .monthly)
        XCTAssertFalse(bill.isPaid)
        XCTAssertEqual(bill.status, .pending)
    }
    
    func testBillDefaultValues() throws {
        let bill = Bill(
            name: "Test Bill",
            date: Date(),
            amount: 100.0
        )
        
        XCTAssertEqual(bill.category, .general)
        XCTAssertEqual(bill.paymentMode, .cash)
        XCTAssertEqual(bill.frequency, .none)
        XCTAssertFalse(bill.isPaid)
        XCTAssertEqual(bill.status, .pending)
        XCTAssertEqual(bill.reminderDays, 1)
    }
    
    // MARK: - Bill Status Tests
    
    func testBillMarkAsPaid() throws {
        let bill = Bill(
            name: "Test Bill",
            date: Date(),
            amount: 100.0
        )
        
        XCTAssertFalse(bill.isPaid)
        XCTAssertEqual(bill.status, .pending)
        XCTAssertNil(bill.paidDate)
        
        bill.markAsPaid()
        
        XCTAssertTrue(bill.isPaid)
        XCTAssertEqual(bill.status, .paid)
        XCTAssertNotNil(bill.paidDate)
    }
    
    func testBillMarkAsUnpaid() throws {
        let bill = Bill(
            name: "Test Bill",
            date: Date(),
            amount: 100.0,
            isPaid: true,
            paidDate: Date()
        )
        
        XCTAssertTrue(bill.isPaid)
        XCTAssertEqual(bill.status, .paid)
        XCTAssertNotNil(bill.paidDate)
        
        bill.markAsUnpaid()
        
        XCTAssertFalse(bill.isPaid)
        XCTAssertEqual(bill.status, .pending)
        XCTAssertNil(bill.paidDate)
    }
    
    func testBillUpdateStatus() throws {
        let bill = Bill(
            name: "Test Bill",
            date: Date(),
            amount: 100.0
        )
        
        bill.updateStatus(.disputed)
        XCTAssertEqual(bill.status, .disputed)
        
        bill.updateStatus(.cancelled)
        XCTAssertEqual(bill.status, .cancelled)
    }
    
    // MARK: - Bill Overdue Tests
    
    func testBillIsOverdue() throws {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let bill = Bill(
            name: "Overdue Bill",
            date: pastDate,
            amount: 100.0
        )
        
        XCTAssertTrue(bill.isOverdue)
    }
    
    func testBillIsNotOverdue() throws {
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let bill = Bill(
            name: "Future Bill",
            date: futureDate,
            amount: 100.0
        )
        
        XCTAssertFalse(bill.isOverdue)
    }
    
    func testPaidBillIsNotOverdue() throws {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let bill = Bill(
            name: "Paid Overdue Bill",
            date: pastDate,
            amount: 100.0,
            isPaid: true
        )
        
        XCTAssertFalse(bill.isOverdue)
    }
    
    // MARK: - Bill Frequency Tests
    
    func testNextDateCalculation() throws {
        let baseDate = Date()
        
        // Daily frequency
        let dailyBill = Bill(
            name: "Daily Bill",
            date: baseDate,
            amount: 10.0,
            frequency: .daily
        )
        
        if let nextDate = dailyBill.nextDate() {
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: baseDate, to: nextDate).day ?? 0
            XCTAssertEqual(days, 1)
        } else {
            XCTFail("Next date should not be nil for daily frequency")
        }
        
        // Monthly frequency
        let monthlyBill = Bill(
            name: "Monthly Bill",
            date: baseDate,
            amount: 100.0,
            frequency: .monthly
        )
        
        if let nextDate = monthlyBill.nextDate() {
            let calendar = Calendar.current
            let months = calendar.dateComponents([.month], from: baseDate, to: nextDate).month ?? 0
            XCTAssertEqual(months, 1)
        } else {
            XCTFail("Next date should not be nil for monthly frequency")
        }
    }
    
    func testOneOffBillNextDate() throws {
        let bill = Bill(
            name: "One-off Bill",
            date: Date(),
            amount: 100.0,
            frequency: .none
        )
        
        XCTAssertNil(bill.nextDate())
    }
    
    // MARK: - Bill Category Tests
    
    func testBillCategorySymbols() throws {
        XCTAssertEqual(Bill.Category.general.symbol, "doc.text")
        XCTAssertEqual(Bill.Category.utilities.symbol, "bolt.fill")
        XCTAssertEqual(Bill.Category.rent.symbol, "house.fill")
        XCTAssertEqual(Bill.Category.entertainment.symbol, "gamecontroller.fill")
        XCTAssertEqual(Bill.Category.groceries.symbol, "cart.fill")
        XCTAssertEqual(Bill.Category.healthcare.symbol, "cross.fill")
        XCTAssertEqual(Bill.Category.transportation.symbol, "car.fill")
        XCTAssertEqual(Bill.Category.insurance.symbol, "shield.fill")
        XCTAssertEqual(Bill.Category.education.symbol, "book.fill")
        XCTAssertEqual(Bill.Category.dining.symbol, "fork.knife")
    }
    
    func testBillCategoryColors() throws {
        XCTAssertEqual(Bill.Category.general.color, "gray")
        XCTAssertEqual(Bill.Category.utilities.color, "blue")
        XCTAssertEqual(Bill.Category.rent.color, "purple")
        XCTAssertEqual(Bill.Category.entertainment.color, "pink")
        XCTAssertEqual(Bill.Category.groceries.color, "green")
        XCTAssertEqual(Bill.Category.healthcare.color, "red")
        XCTAssertEqual(Bill.Category.transportation.color, "orange")
        XCTAssertEqual(Bill.Category.insurance.color, "indigo")
        XCTAssertEqual(Bill.Category.education.color, "teal")
        XCTAssertEqual(Bill.Category.dining.color, "yellow")
    }
    
    // MARK: - Bill Receipt Tests
    
    func testBillReceiptData() throws {
        let receiptData = "test receipt data".data(using: .utf8)
        let bill = Bill(
            name: "Bill with Receipt",
            date: Date(),
            amount: 100.0,
            receiptData: receiptData
        )
        
        XCTAssertTrue(bill.hasReceipt)
        XCTAssertEqual(bill.receiptData, receiptData)
    }
    
    func testBillWithoutReceipt() throws {
        let bill = Bill(
            name: "Bill without Receipt",
            date: Date(),
            amount: 100.0
        )
        
        XCTAssertFalse(bill.hasReceipt)
        XCTAssertNil(bill.receiptData)
    }
    
    // MARK: - Bill Days Until Due Tests
    
    func testDaysUntilDue() throws {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let bill = Bill(
            name: "Tomorrow's Bill",
            date: tomorrow,
            amount: 100.0
        )
        
        XCTAssertEqual(bill.daysUntilDue, 1)
    }
    
    func testDaysUntilDuePast() throws {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let bill = Bill(
            name: "Yesterday's Bill",
            date: yesterday,
            amount: 100.0
        )
        
        XCTAssertEqual(bill.daysUntilDue, -1)
    }
    
    // MARK: - Bill Tags Tests
    
    func testBillTags() throws {
        let tags = ["urgent", "home", "monthly"]
        let bill = Bill(
            name: "Tagged Bill",
            date: Date(),
            amount: 100.0,
            tags: tags
        )
        
        XCTAssertEqual(bill.tags, tags)
        XCTAssertEqual(bill.tags.count, 3)
    }
    
    // MARK: - Bill Notes Tests
    
    func testBillNotes() throws {
        let notes = "This is a test note for the bill"
        let bill = Bill(
            name: "Bill with Notes",
            date: Date(),
            amount: 100.0,
            notes: notes
        )
        
        XCTAssertEqual(bill.notes, notes)
    }
    
    // MARK: - Bill Custom Frequency Tests
    
    func testCustomFrequency() throws {
        let bill = Bill(
            name: "Custom Frequency Bill",
            date: Date(),
            amount: 100.0,
            frequency: .custom,
            customFrequencyDays: 15
        )
        
        XCTAssertEqual(bill.frequency, .custom)
        XCTAssertEqual(bill.customFrequencyDays, 15)
        
        if let nextDate = bill.nextDate() {
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: bill.date, to: nextDate).day ?? 0
            XCTAssertEqual(days, 15)
        } else {
            XCTFail("Next date should not be nil for custom frequency")
        }
    }
    
    func testCustomFrequencyWithoutDays() throws {
        let bill = Bill(
            name: "Custom Frequency Bill",
            date: Date(),
            amount: 100.0,
            frequency: .custom
        )
        
        XCTAssertNil(bill.nextDate())
    }
} 