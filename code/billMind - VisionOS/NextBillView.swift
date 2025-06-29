import SwiftUI
import SwiftData

/// Simple watchOS view that surfaces the next unpaid bill.
struct NextBillView: View {
    // Fetch all unpaid bills, sorted by date ascending (soonest first)
    @Query(
        filter: #Predicate<Bill> { !$0.isPaid },
        sort: \Bill.date,
        order: .forward,
        animation: .default
    ) private var pendingBills: [Bill]

    private var nextBill: Bill? { pendingBills.first }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let bill = nextBill {
                Text("Next Bill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(bill.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(bill.date, style: .date)
                    .font(.body)
                Text("LKR \(String(format: "%.2f", bill.amount))")
                    .font(.title3.bold())
            } else {
                Spacer()
                Text("No unpaid bills")
                    .font(.headline)
                Spacer()
            }
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    NextBillView()
        .modelContainer(ModelContainer.shared)
}
#endif 