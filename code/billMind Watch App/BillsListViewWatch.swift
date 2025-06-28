import SwiftUI
import SwiftData

struct BillsListViewWatch: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Bill.date) private var bills: [Bill]
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                if bills.isEmpty {
                    Text("No bills yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(bills) { bill in
                        NavigationLink(value: bill) {
                            BillRow(bill: bill)
                        }
                    }
                }
            }
            .navigationTitle("Bills")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Bill")
                }
            }
            .sheet(isPresented: $showAdd) {
                AddBillViewWatch()
            }
            .navigationDestination(for: Bill.self) { bill in
                BillDetailWatchView(bill: bill)
            }
        }
    }
}

private struct BillRow: View {
    let bill: Bill
    var body: some View {
        VStack(alignment: .leading) {
            Text(bill.name)
            Text(bill.date, style: .date)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        Spacer()
        Text(bill.amount, format: .currency(code: "LKR"))
            .font(.footnote)
    }
} 