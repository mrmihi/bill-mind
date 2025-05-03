import SwiftUI
import Charts
import SwiftData

struct HomeDashboardView: View {
    @Query(sort: \Bill.date, order: .forward) private var bills: [Bill]
    init() {}

    private var unpaid: [Bill] { bills.filter { !$0.isPaid } }
    private var unpaidTotal: Double { unpaid.reduce(0) { $0 + $1.amount } }
    private var overdueCount: Int { unpaid.filter(\Bill.isOverdue).count }
    private var categoryTotals: [(Bill.Category, Double)] {
        Dictionary(grouping: unpaid, by: \Bill.category)
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.0.rawValue < $1.0.rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    CardView {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unpaid total")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("LKR \(unpaidTotal, format: .number)")
                                .font(.largeTitle.bold())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    CardView {
                        VStack(alignment: .leading) {
                            Text("By category")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Chart(categoryTotals, id: \.0) { cat, total in
                                BarMark(
                                    x: .value("Category", cat.rawValue),
                                    y: .value("Amount", total)
                                )
                            }
                            .chartYAxis { AxisMarks(position: .leading) }
                            .frame(height: 220)
                        }
                    }

                    if overdueCount > 0 {
                        CardView {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                                Text("\(overdueCount) bill\(overdueCount > 1 ? "s" : "") overdue!")
                                    .font(.headline)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Overview")
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
