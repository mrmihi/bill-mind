import SwiftUI
import SwiftData

struct TransactionsListView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var txns: [Transaction]
    init() {}   // expose public init

    var body: some View {
        NavigationStack {
            List {
                ForEach(txns) { txn in
                    NavigationLink {
                        TransactionDetailView(txn: txn)
                    } label: {
                        TransactionRow(txn: txn)
                    }
                }
            }
            .navigationTitle("Transactions")
        }
    }
}

private struct TransactionRow: View {
    let txn: Transaction
    var body: some View {
        HStack {
            Image(systemName: txn.category.symbol).foregroundColor(.accentColor)
            VStack(alignment: .leading) {
                Text(txn.payee).font(.headline)
                Text(txn.date, formatter: dateFormatter)
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Text("LKR \(String(format: "%.2f", txn.amount))")
        }
    }
}
