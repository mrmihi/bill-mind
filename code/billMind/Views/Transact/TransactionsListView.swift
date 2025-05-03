import SwiftData
import SwiftUI

struct TransactionsListView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var txns:
        [Transaction]
    @Environment(\.modelContext) private var context

    enum Filter: String, CaseIterable, Identifiable {
        case all, month
        var id: Self { self }
    }
    @State private var filter: Filter = .all
    @State private var showAddTxn = false
    @State private var selectedTxn: Transaction?
    @State private var editMode: EditMode = .inactive

    private var viewTxns: [Transaction] {
        switch filter {
        case .all: return txns
        case .month:
            return txns.filter {
                Calendar.current.isDate(
                    $0.date,
                    equalTo: .now,
                    toGranularity: .month
                )
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if viewTxns.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.quaternary)
                        Text(
                            filter == .month
                                ? "No transactions this month"
                                : "No transactions yet"
                        )
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                }

                ForEach(viewTxns) { txn in
                    NavigationLink {
                        TransactionDetailView(txn: txn)
                    } label: {
                        TransactionRow(txn: txn)
                    }
                    .swipeActions(edge: .leading) {
                        Button("Edit") { selectedTxn = txn }.tint(.blue)
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Transactions")
            .environment(\.editMode, $editMode)
            .safeAreaInset(edge: .top) {
                Picker("Filter", selection: $filter) {
                    Text("All").tag(Filter.all)
                    Text("This Month").tag(Filter.month)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .background(.bar)
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddTxn = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel("Add Transaction")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("View", selection: $filter) {
                            Text("All").tag(Filter.all)
                            Text("This Month").tag(Filter.month)
                        }
                        Button(editMode.isEditing ? "Done Editing" : "Edit") {
                            editMode = editMode.isEditing ? .inactive : .active
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showAddTxn) { AddTransactionView() }
            .sheet(item: $selectedTxn) { txn in EditTransactionView(txn: txn) }
        }
    }
    private func delete(at offsets: IndexSet) {
        for index in offsets { context.delete(viewTxns[index]) }
        try? context.save()
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
