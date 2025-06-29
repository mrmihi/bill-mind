import SwiftUI
import SwiftData

struct BillDetailWatchView: View {
    @Environment(\.modelContext) private var context
    @Bindable var bill: Bill

    var body: some View {
        Form {
            Section("Summary") {
                Text(bill.name)
                Text(bill.date, style: .date)
                Text(bill.amount, format: .currency(code: "LKR"))
            }
            Section {
                Button(bill.isPaid ? "Mark Unpaid" : "Mark Paid") {
                    bill.isPaid.toggle()
                    if bill.isPaid { bill.paidDate = Date() } else { bill.paidDate = nil }
                    try? context.save()
                }
                .tint(bill.isPaid ? .orange : .green)
            }
        }
        .navigationTitle("Details")
    }
} 