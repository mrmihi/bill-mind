import SwiftUI
import SwiftData
import PhotosUI   // optional if you want a receipt photo too

struct AddTransactionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var payee = ""
    @State private var amountText = ""
    @State private var date = Date()
    @State private var category: Transaction.Category = .other

    private var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: ""))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Payee / Description", text: $payee)
                TextField("Amount (LKR)", text: $amountText)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])

                Picker("Category", selection: $category) {
                    ForEach(Transaction.Category.allCases) { cat in
                        Label(cat.rawValue, systemImage: cat.symbol).tag(cat)
                    }
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(payee.isEmpty || amount == nil)
                }
            }
        }
    }

    private func save() {
        guard let amt = amount else { return }
        let txn = Transaction(date: date,
                              payee: payee,
                              amount: amt,
                              category: category)
        context.insert(txn)
        try? context.save()
        dismiss()
    }
}
