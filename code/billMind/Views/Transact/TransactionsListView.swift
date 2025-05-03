import SwiftUI
import SwiftData

struct TransactionsListView: View {
    @Query(sort: \Transaction.date, order: .reverse)
    private var txns: [Transaction]
    @State private var showAddTxn = false
    init() {}

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
            .toolbar {
                           ToolbarItem(placement: .navigationBarTrailing) {
                               Button {
                                   showAddTxn = true
                               } label: {
                                   Image(systemName: "plus")
                               }
                               .accessibilityLabel("Add Transaction")
                           }
                       }
                       .sheet(isPresented: $showAddTxn) {         // ← sheet
                           AddTransactionView()
                       }
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
