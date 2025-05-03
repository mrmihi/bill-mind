import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var txn: Transaction

    var body: some View {
        Form {
            DetailRow(label: "Payee",    value: txn.payee)
            DetailRow(label: "Amount",   value: "LKR \(String(format: "%.2f", txn.amount))")
            DetailRow(label: "Date",     value: dateFormatter.string(from: txn.date))
            DetailRow(label: "Category", value: txn.category.rawValue)
        }
        .navigationTitle("Transaction")
    }
}
