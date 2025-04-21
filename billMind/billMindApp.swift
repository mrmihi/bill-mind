//import SwiftUI
//import SwiftData
//import UserNotifications
//import PhotosUI
//import Charts
//
//// MARK: - Notification Helper
//struct NotificationManager {
//    static let center = UNUserNotificationCenter.current()
//
//    static func requestAuthorization() {
//        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if let error = error {
//                print("⚠️ Notification auth error: \(error.localizedDescription)")
//            }
//            print("🔔 Notifications granted: \(granted)")
//        }
//    }
//
//    static func schedule(for bill: Bill) {
//        guard !bill.isPaid else { return }
//        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: bill.date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
//
//        let content = UNMutableNotificationContent()
//        let amountString = String(format: "%.2f", bill.amount)
//        content.title = "Bill due today"
//        content.body  = "\(bill.name) (LKR \(amountString)) is due now."
//        content.sound = .default
//
//        let req = UNNotificationRequest(identifier: bill.id.uuidString, content: content, trigger: trigger)
//        center.add(req)
//    }
//
//    static func cancel(for bill: Bill) {
//        center.removePendingNotificationRequests(withIdentifiers: [bill.id.uuidString])
//    }
//}
//
//// MARK: - Data Model
//@Model
//final class Bill: Identifiable {
//    enum Category: String, CaseIterable, Identifiable, Codable {
//        case general = "General"
//        case utilities = "Utilities"
//        case rent = "Rent"
//        case entertainment = "Entertainment"
//        case groceries = "Groceries"
//        var id: String { rawValue }
//        var symbol: String {
//            switch self {
//            case .general:       "doc.text"
//            case .utilities:     "bolt.fill"
//            case .rent:          "house.fill"
//            case .entertainment: "gamecontroller.fill"
//            case .groceries:     "cart.fill"
//            }
//        }
//    }
//
//    enum PaymentMode: String, CaseIterable, Identifiable, Codable {
//        case cash = "Cash"
//        case card = "Card"
//        case bank = "Bank Transfer"
//        case other = "Other"
//        var id: String { rawValue }
//    }
//
//    // persisted
//    var id: UUID
//    var name: String
//    var date: Date
//    var amount: Double
//    var categoryRaw: Category
//    var paymentModeRaw: PaymentMode
//    var isPaid: Bool
//    var paidDate: Date?
//    var receiptData: Data?
//
//    // computed
//    var category: Category { categoryRaw }
//    var paymentMode: PaymentMode { paymentModeRaw }
//    var isOverdue: Bool { !isPaid && date < .now }
//    var hasReceipt: Bool { receiptData != nil }
//
//    init(id: UUID = UUID(),
//         name: String,
//         date: Date,
//         amount: Double,
//         category: Category = .general,
//         paymentMode: PaymentMode = .cash,
//         isPaid: Bool = false,
//         paidDate: Date? = nil,
//         receiptData: Data? = nil) {
//        self.id = id
//        self.name = name
//        self.date = date
//        self.amount = amount
//        self.categoryRaw = category
//        self.paymentModeRaw = paymentMode
//        self.isPaid = isPaid
//        self.paidDate = paidDate
//        self.receiptData = receiptData
//    }
//}
//
//// MARK: - App Entry
//@main
//struct BillsApp: App {
//    init() { NotificationManager.requestAuthorization() }
//    var body: some Scene {
//        WindowGroup { ContentView() }
//            .modelContainer(for: Bill.self)
//    }
//}
//
//// MARK: - Root Tabs
//struct ContentView: View {
//    var body: some View {
//        TabView {
//            HomeDashboardView()
//                .tabItem { Label("Home", systemImage: "house") }
//
//            BillsListView()
//                .tabItem { Label("Bills", systemImage: "list.bullet") }
//
//            AddBillView()
//                .tabItem { Label("Add", systemImage: "plus.circle") }
//        }
//    }
//}
//
//// MARK: - Home Dashboard
//struct HomeDashboardView: View {
//    @Query(sort: \Bill.date, order: .forward) var bills: [Bill]
//
//    private var unpaid: [Bill] { bills.filter { !$0.isPaid } }
//    private var unpaidTotal: Double { unpaid.reduce(0) { $0 + $1.amount } }
//    private var overdueCount: Int { unpaid.filter(\Bill.isOverdue).count }
//
//    private var categoryTotals: [(Bill.Category, Double)] {
//        Dictionary(grouping: unpaid, by: \Bill.category)
//            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
//            .sorted { $0.0.rawValue < $1.0.rawValue }
//    }
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 24) {
//                    CardView {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Unpaid total")
//                                .font(.subheadline).foregroundStyle(.secondary)
//                            Text("LKR \(unpaidTotal, format: .number)")
//                                .font(.largeTitle.bold())
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    }
//
//                    CardView {
//                        VStack(alignment: .leading) {
//                            Text("By category")
//                                .font(.subheadline).foregroundStyle(.secondary)
//                            Chart(categoryTotals, id: \.0) { cat, total in
//                                BarMark(
//                                    x: .value("Category", cat.rawValue),
//                                    y: .value("Amount", total)
//                                )
//                            }
//                            .chartYAxis { AxisMarks(position: .leading) }
//                            .frame(height: 220)
//                        }
//                    }
//
//                    if overdueCount > 0 {
//                        CardView {
//                            HStack(spacing: 8) {
//                                Image(systemName: "exclamationmark.triangle.fill")
//                                    .foregroundColor(.orange)
//                                    .font(.title2)
//                                Text("\(overdueCount) bill\(overdueCount > 1 ? "s" : "") overdue!")
//                                    .font(.headline)
//                            }
//                        }
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("Overview")
//        }
//    }
//}
//
//// simple card wrapper
//struct CardView<Content: View>: View {
//    @ViewBuilder let content: () -> Content
//    var body: some View {
//        content()
//            .padding()
//            .background(.background)
//            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//            .shadow(radius: 2, y: 1)
//    }
//}
//
//// MARK: - Add Bill
//struct AddBillView: View {
//    @Environment(\.modelContext) private var context
//    @State private var name = ""
//    @State private var amountText = ""
//    @State private var date = Date()
//    @State private var category: Bill.Category = .general
//    @State private var paymentMode: Bill.PaymentMode = .cash
//    @State private var receiptItem: PhotosPickerItem?
//    @State private var receiptData: Data?
//    @Environment(\.dismiss) private var dismiss
//
//    private var amount: Double? { Double(amountText.replacingOccurrences(of: ",", with: ".")) }
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section("Details") {
//                    TextField("Bill name", text: $name)
//                    TextField("Amount (LKR)", text: $amountText).keyboardType(.decimalPad)
//                    DatePicker("Due date", selection: $date, displayedComponents: [.date, .hourAndMinute])
//                }
//                Section("Category") {
//                    Picker("Category", selection: $category) {
//                        ForEach(Bill.Category.allCases) { cat in
//                            Label(cat.rawValue, systemImage: cat.symbol).tag(cat)
//                        }
//                    }
//                }
//                Section("Payment Mode") {
//                    Picker("Payment", selection: $paymentMode) {
//                        ForEach(Bill.PaymentMode.allCases) { mode in
//                            Text(mode.rawValue).tag(mode)
//                        }
//                    }.pickerStyle(.segmented)
//                }
//                Section("Receipt (optional)") {
//                    if let data = receiptData, let img = UIImage(data: data) {
//                        Image(uiImage: img).resizable().scaledToFit().frame(maxHeight: 160)
//                    }
//                    PhotosPicker(selection: $receiptItem, matching: .images) {
//                        Label("Select Photo", systemImage: "photo")
//                    }
//                    .onChange(of: receiptItem) { newItem in
//                        Task {
//                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
//                                receiptData = data
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Add Bill")
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Save", action: save).disabled(name.isEmpty || amount == nil)
//                }
//            }
//        }
//    }
//
//    private func save() {
//        guard let amt = amount else { return }
//        let bill = Bill(name: name, date: date, amount: amt, category: category, paymentMode: paymentMode, receiptData: receiptData)
//        context.insert(bill)
//        try? context.save()
//        NotificationManager.schedule(for: bill)
//        dismiss()
//    }
//}
//
//// MARK: - Bills List
//struct BillsListView: View {
//    @Query(sort: \Bill.date, order: .forward) var bills: [Bill]
//    @Environment(\.modelContext) private var context
//    @State private var showPaidOnly = false
//
//    private var viewBills: [Bill] { bills.filter { showPaidOnly ? $0.isPaid : true } }
//
//    var body: some View {
//        NavigationStack {
//            List {
//                ForEach(viewBills) { bill in
//                    NavigationLink { BillDetailView(bill: bill) } label: { BillRowView(bill: bill) }
//                }
//                .onDelete(perform: delete)
//            }
//            .navigationTitle("Bills")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) { Toggle("Paid", isOn: $showPaidOnly) }
//                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
//            }
//        }
//    }
//
//    private func delete(at offsets: IndexSet) {
//        for index in offsets {
//            NotificationManager.cancel(for: bills[index])
//            context.delete(bills[index])
//        }
//        try? context.save()
//    }
//}
//
//// MARK: - Row
//struct BillRowView: View {
//    let bill: Bill
//    var body: some View {
//        HStack {
//            Image(systemName: bill.category.symbol).foregroundColor(.accentColor)
//            VStack(alignment: .leading) {
//                Text(bill.name).font(.headline)
//                Text("LKR \(String(format: "%.2f", bill.amount)) · \(bill.date, formatter: dateFormatter)")
//                    .font(.subheadline).foregroundStyle(.secondary)
//            }
//            Spacer()
//            if bill.isPaid {
//                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
//            } else if bill.isOverdue {
//                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
//            }
//        }
//    }
//}
//
//// MARK: - Detail Screen
//struct BillDetailView: View {
//    @Environment(\.modelContext) private var context
//    @Bindable var bill: Bill
//    @State private var photoItem: PhotosPickerItem?
//
//    var body: some View {
//        Form {
//            Section("Summary") {
//                HStack {
//                    Image(systemName: bill.category.symbol).font(.title2)
//                    VStack(alignment: .leading) {
//                        Text(bill.name).font(.headline)
//                        Text("LKR \(String(format: "%.2f", bill.amount))")
//                    }
//                }
//                DetailRow(label: "Due", value: dateFormatter.string(from: bill.date))
//                DetailRow(label: "Status", value: bill.isPaid ? "Paid" : bill.isOverdue ? "Overdue" : "Unpaid", valueColor: bill.isPaid ? .green : bill.isOverdue ? .orange : .primary)
//                DetailRow(label: "Payment", value: bill.paymentMode.rawValue)
//            }
//
//            if bill.hasReceipt, let data = bill.receiptData, let img = UIImage(data: data) {
//                Section("Receipt") { Image(uiImage: img).resizable().scaledToFit().frame(maxHeight: 250) }
//            }
//        }
//        .navigationTitle("Bill Details")
//        .toolbar {
//            ToolbarItemGroup(placement: .navigationBarTrailing) {
//                Button(bill.isPaid ? "Unpay" : "Mark Paid") { togglePaid() }
//                if bill.hasReceipt == false {
//                    PhotosPicker(selection: $photoItem, matching: .images) { Image(systemName: "plus.app") }
//                        .onChange(of: photoItem) { newItem in
//                            Task {
//                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
//                                    bill.receiptData = data
//                                    try? context.save()
//                                }
//                            }
//                        }
//                }
//            }
//        }
//    }
//
//    private func togglePaid() {
//        bill.isPaid.toggle()
//        bill.paidDate = bill.isPaid ? .now : nil
//        if bill.isPaid { NotificationManager.cancel(for: bill) } else { NotificationManager.schedule(for: bill) }
//        try? context.save()
//    }
//}
//
//struct DetailRow: View {
//    let label: String
//    let value: String
//    var valueColor: Color = .primary
//    var body: some View {
//        HStack { Text(label); Spacer(); Text(value).foregroundColor(valueColor) }
//    }
//}
//
//// MARK: - Helpers
//let dateFormatter: DateFormatter = {
//    let df = DateFormatter()
//    df.dateStyle = .medium
//    df.timeStyle = .short
//    return df
//}()
