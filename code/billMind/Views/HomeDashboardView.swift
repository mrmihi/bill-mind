import SwiftUI
import Charts
import SwiftData

struct HomeDashboardView: View {
    
    @Query(sort: \Bill.date, order: .forward) private var bills: [Bill]
    @Query private var txns: [Transaction]
    @EnvironmentObject private var cloudKitMonitor: CloudKitSyncMonitor
    
    @State private var showingQuickAdd = false
    @State private var selectedTimeframe: Timeframe = .month

    private var unpaidBills: [Bill] { bills.filter { !$0.isPaid } }
    private var unpaidTotal: Double { unpaidBills.reduce(0) { $0 + $1.amount } }
    private var overdueCount: Int  { unpaidBills.filter(\.isOverdue).count }
    private var paidCount: Int     { bills.filter(\.isPaid).count }

    private var billsThisMonth: Int {
        bills.filter { Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month) }.count
    }

    private var billCategoryTotals: [(Bill.Category, Double)] {
        Dictionary(grouping: unpaidBills, by: \Bill.category)
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.0.rawValue < $1.0.rawValue }
    }

    private var txnCategoryTotals: [(Transaction.Category, Double)] {
        Dictionary(grouping: txns, by: \Transaction.category)
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.0.rawValue < $1.0.rawValue }
    }
    
    private var upcomingBills: [Bill] {
        let calendar = Calendar.current
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return unpaidBills
            .filter { $0.date <= nextWeek && $0.date >= Date() }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick Actions
                    HStack(spacing: 16) {
                        Button {
                            showingQuickAdd = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Quick Add")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            // Export functionality
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                Text("Export")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.green.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)

                    // Main Metrics
                    CardView {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Unpaid total")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text("LKR \(String(format: "%.2f", unpaidTotal))")
                                .font(.system(size: 34, weight: .bold))
                                .accessibilityLabel("Unpaid total: LKR \(String(format: "%.2f", unpaidTotal))")
                            Text("\(unpaidBills.count) bill\(unpaidBills.count == 1 ? "" : "s") pending")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Statistics Grid
                    CardView {
                        HStack(spacing: 32) {
                            StatBlock(title: "This month", value: billsThisMonth)
                            StatBlock(title: "Paid",       value: paidCount)
                            StatBlock(title: "Overdue",    value: overdueCount,
                                      color: overdueCount > 0 ? .orange : .secondary)
                        }
                    }

                    // Upcoming Bills
                    if !upcomingBills.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Upcoming Bills")
                                    .font(.headline)
                                
                                ForEach(upcomingBills.prefix(3)) { bill in
                                    HStack {
                                        Image(systemName: bill.category.symbol)
                                            .foregroundStyle(Color(bill.category.color))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading) {
                                            Text(bill.name)
                                                .font(.subheadline)
                                            Text("Due \(bill.date, formatter: dateFormatter)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("LKR \(String(format: "%.2f", bill.amount))")
                                            .font(.subheadline.bold())
                                    }
                                    .padding(.vertical, 4)
                                }
                                
                                if upcomingBills.count > 3 {
                                    Button("View all \(upcomingBills.count) upcoming bills") {
                                        // Navigate to bills list
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Charts Section
                    if !txnCategoryTotals.isEmpty {
                        CardView {
                            VStack(alignment: .leading) {
                                Text("Spending by category")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                PieChart(totals: txnCategoryTotals)
                                    .frame(height: 220)
                            }
                        }
                        .padding(.horizontal)
                    }

                    if !billCategoryTotals.isEmpty {
                        CardView {
                            VStack(alignment: .leading) {
                                Text("Unpaid bills by category")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Chart(billCategoryTotals, id: \.0) { cat, total in
                                    BarMark(
                                        x: .value("Category", cat.rawValue),
                                        y: .value("Amount", total)
                                    )
                                    .foregroundStyle(Color(cat.color))
                                }
                                .chartYAxis { AxisMarks(position: .leading) }
                                .frame(height: 220)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Export Section
                    HStack {
                        Button("Export Bills CSV") {
                            print(ExportService.exportBills(bills))
                        }
                        Spacer(minLength: 20)
                        Button("Export Txns CSV") {
                            print(ExportService.exportTransactions(txns))
                        }
                    }
                    .font(.subheadline)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Overview")
            .sheet(isPresented: $showingQuickAdd) {
                QuickAddView()
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

private struct StatBlock: View {
    let title: String
    let value: Int
    var color: Color = .accentColor
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.title.bold())
                .foregroundStyle(color)
                .accessibilityLabel("\(title): \(value)")
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct PieChart: View {
    let totals: [(Transaction.Category, Double)]
    var body: some View {
        VStack {
            Chart(totals, id: \.0) { cat, total in
                SectorMark(
                    angle: .value("Amount", total),
                    innerRadius: .ratio(0.55),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Cat", cat.rawValue))
            }
            .chartLegend(.visible)
            .chartLegend(position: .bottom)
        }
    }
}

struct CardView<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(radius: 2, y: 1)
    }
}

struct QuickAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var category: Bill.Category = .general
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Bill Details") {
                    TextField("Bill name", text: $name)
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Due date", selection: $date, displayedComponents: .date)
                    
                    Picker("Category", selection: $category) {
                        ForEach(Bill.Category.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.symbol)
                                .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Quick Add Bill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addBill()
                    }
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func addBill() {
        guard let amountValue = Double(amount) else { return }
        
        let bill = Bill(
            name: name,
            date: date,
            amount: amountValue,
            category: category
        )
        
        modelContext.insert(bill)
        NotificationManager.schedule(for: bill)
        
        dismiss()
    }
}
