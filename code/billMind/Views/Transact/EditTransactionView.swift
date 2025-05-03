import SwiftUI
import SwiftData

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var txn: Transaction           
    var body: some View {
        NavigationStack {
            Form {
                TextField("Payee / Description", text: $txn.payee)

                TextField("Amount (LKR)",
                          value: $txn.amount,
                          format: .number.precision(.fractionLength(2)))
                    .keyboardType(.decimalPad)

                DatePicker("Date",
                           selection: $txn.date,
                           displayedComponents: [.date, .hourAndMinute])

                Picker("Category", selection: $txn.categoryRaw) {
                    ForEach(Transaction.Category.allCases) { cat in
                        Label(cat.rawValue, systemImage: cat.symbol).tag(cat)
                    }
                }
            }
            .navigationTitle("Edit Transaction")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
