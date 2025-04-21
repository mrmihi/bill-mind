import SwiftUI
import SwiftData

struct BillsListView: View {
    // Fetch all bills; sorting handled in view if needed
    @Query private var bills: [Bill]
    @Environment(\.modelContext) private var context
    @State private var showPaidOnly = false
    init() {}

    private var viewBills: [Bill] {
        showPaidOnly ? bills.filter { $0.isPaid } : bills
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewBills) { bill in
                    NavigationLink(destination: BillDetailView(bill: bill)) {
                        BillRowView(bill: bill)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Bills")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
                ToolbarItem(placement: .navigationBarTrailing) { Toggle("Paid", isOn: $showPaidOnly) }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let billToDelete = viewBills[index]
            NotificationManager.cancel(for: billToDelete)
            context.delete(billToDelete)
        }
        try? context.save()
    }
}
