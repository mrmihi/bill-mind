import SwiftUI
import SwiftData

struct AddBillViewWatch: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name = ""
    @State private var amountText = ""
    @State private var date = Date()

    private var amount: Double? { Double(amountText.replacingOccurrences(of: ",", with: ".")) }

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Amount", text: $amountText)
            DatePicker("Due", selection: $date, displayedComponents: [.date])
        }
        .navigationTitle("Add Bill")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: { dismiss() }) }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(name.isEmpty || amount == nil)
            }
        }
    }

    private func save() {
        guard let amt = amount else { return }
        let bill = Bill(name: name, date: date, amount: amt)
        context.insert(bill)
        try? context.save()
        dismiss()
    }
} 