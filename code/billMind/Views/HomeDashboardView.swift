import SwiftUI
import Charts
import SwiftData

struct HomeDashboardView: View {
    
    @Query(sort: \Bill.date, order: .forward) private var bills: [Bill]
    @Query private var txns: [Transaction]

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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    CardView {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Unpaid total")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text("LKR \(unpaidTotal, format: .number)")
                                .font(.system(size: 34, weight: .bold))
                            Text("\(unpaidBills.count) bill\(unpaidBills.count == 1 ? "" : "s") pending")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    CardView {
                        HStack(spacing: 32) {
                            StatBlock(title: "This month", value: billsThisMonth)
                            StatBlock(title: "Paid",       value: paidCount)
                            StatBlock(title: "Overdue",    value: overdueCount,
                                      color: overdueCount > 0 ? .orange : .secondary)
                        }
                    }

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
                                }
                                .chartYAxis { AxisMarks(position: .leading) }
                                .frame(height: 220)
                            }
                        }
                    }

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
        }
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
