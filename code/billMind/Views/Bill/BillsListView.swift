import SwiftUI
import SwiftData

struct BillsListView: View {
    @Query private var bills: [Bill]
    @Environment(\.modelContext) private var context
    @State private var showPaidOnly = false
    @State private var showAddBill  = false
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
                               ToolbarItem(placement: .navigationBarTrailing) {
                                   HStack {
                                       Toggle("Paid", isOn: $showPaidOnly)
                                       Button {
                                           showAddBill = true
                                       } label: {
                                           Image(systemName: "plus")
                                       }
                                       .accessibilityLabel("Add Bill")
                                   }
                               }
            }
            .sheet(isPresented: $showAddBill) {
                            AddBillView()
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
