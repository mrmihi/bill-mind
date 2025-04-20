import SwiftUI
import SwiftData
import UserNotifications

// MARK: - Notification Helper
struct NotificationManager {
    static let center = UNUserNotificationCenter.current()

    static func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("⚠️ Notification auth error: \(error.localizedDescription)")
            }
            print("🔔 Notifications granted: \(granted)")
        }
    }

    /// One‑shot alert for the bill’s due date (only if it isn’t paid yet)
    static func schedule(for bill: Bill) {
        guard !bill.isPaid else { return }
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: bill.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = "Bill due today"
        let amountString = String(format: "%.2f", bill.amount)
        content.body = "\(bill.name) (LKR \(amountString)) is due now."
        content.sound = .default

        let request = UNNotificationRequest(identifier: bill.id.uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    static func cancel(for bill: Bill) {
        center.removePendingNotificationRequests(withIdentifiers: [bill.id.uuidString])
    }
}

// MARK: - Data Model
@Model
final class Bill: Identifiable {
    enum Category: String, CaseIterable, Identifiable, Codable {
        case general = "General"
        case utilities = "Utilities"
        case rent = "Rent"
        case entertainment = "Entertainment"
        case groceries = "Groceries"
        
        var id: String { rawValue }
        var symbol: String {
            switch self {
            case .general: return "doc.text"
            case .utilities: return "bolt.fill"
            case .rent: return "house.fill"
            case .entertainment: return "gamecontroller.fill"
            case .groceries: return "cart.fill"
            }
        }
    }

    enum PaymentMode: String, CaseIterable, Identifiable, Codable {
        case cash = "Cash"
        case card = "Card"
        case bank = "Bank Transfer"
        case other = "Other"
        var id: String { rawValue }
    }

    // persisted properties
    var id: UUID
    var name: String
    var date: Date
    var amount: Double
    var categoryRaw: Category
    var paymentModeRaw: PaymentMode
    var isPaid: Bool
    var paidDate: Date?

    // computed helpers
    var category: Category { categoryRaw }
    var paymentMode: PaymentMode { paymentModeRaw }
    var isOverdue: Bool { !isPaid && date < .now }

    init(id: UUID = UUID(),
         name: String,
         date: Date,
         amount: Double,
         category: Category = .general,
         paymentMode: PaymentMode = .cash,
         isPaid: Bool = false,
         paidDate: Date? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.amount = amount
        self.categoryRaw = category
        self.paymentModeRaw = paymentMode
        self.isPaid = isPaid
        self.paidDate = paidDate
    }
}

@main
struct BillsApp: App {
//    init() { NotificationManager.requestAuthorization() }
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: Bill.self)
    }
}

// MARK: - Root TabView
struct ContentView: View {
    var body: some View {
        TabView {
            BillsListView()
                .tabItem { Label("Bills", systemImage: "list.bullet") }

            AddBillView()
                .tabItem { Label("Add Bill", systemImage: "plus.circle") }
        }
    }
}

// MARK: - Add Bill Screen
struct AddBillView: View {
    @Environment(\.modelContext) private var context
    @State private var name = ""
    @State private var amountText = ""
    @State private var date = Date()
    @State private var category: Bill.Category = .general
    @State private var paymentMode: Bill.PaymentMode = .cash
    @Environment(\.dismiss) private var dismiss

    var amount: Double? { Double(amountText) }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Bill name", text: $name)
                    TextField("Amount (LKR)", text: $amountText)
                        .keyboardType(.decimalPad)
                    DatePicker("Due date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        ForEach(Bill.Category.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.symbol).tag(cat)
                        }
                    }
                }

                Section(header: Text("Payment Mode")) {
                    Picker("Payment", selection: $paymentMode) {
                        ForEach(Bill.PaymentMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }.pickerStyle(.segmented)
                }
            }
            .navigationTitle("Add Bill")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty || amount == nil)
                }
            }
        }
    }

    private func save() {
        guard let amt = amount else { return }
        let bill = Bill(name: name, date: date, amount: amt, category: category, paymentMode: paymentMode)
        context.insert(bill)
        try? context.save()
//        NotificationManager.schedule(for: bill)
        dismiss()
    }
}

// MARK: - Bills List Screen
struct BillsListView: View {
    @Query(sort: \Bill.date, order: .forward) private var bills: [Bill]
    @Environment(\.modelContext) private var context

    @State private var filterPaid = false

    var filteredBills: [Bill] { bills.filter { filterPaid ? $0.isPaid : true } }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredBills) { bill in
                    HStack {
                        Image(systemName: bill.category.symbol)
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading) {
                            Text(bill.name)
                                .font(.headline)
                            Text("LKR \(bill.amount, specifier: "%.2f") · \(bill.date, formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if bill.isPaid {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else if bill.isOverdue {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        if bill.isPaid {
                            Button("Unpay", role: .destructive) { togglePaid(bill, paid: false) }
                        } else {
                            Button("Paid") { togglePaid(bill, paid: true) }
                                .tint(.green)
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Bills")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $filterPaid) { Text("Paid only") }
                }
                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
            }
        }
    }

    // Helpers
    private func togglePaid(_ bill: Bill, paid: Bool) {
        bill.isPaid = paid
        bill.paidDate = paid ? .now : nil
//        if paid { NotificationManager.cancel(for: bill) } else { NotificationManager.schedule(for: bill) }
        try? context.save()
    }

    private func delete(at offsets: IndexSet) {
//        for index in offsets { NotificationManager.cancel(for: bills[index]); context.delete(bills[index]) }
        try? context.save()
    }
}

// Date formatter for list
private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    df.timeStyle = .short
    return df
}()

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(for: Bill.self, inMemory: true)
}
