import SwiftUI
import SwiftData

struct BillsListView: View {
    @Query(sort: \Bill.date, order: .forward) private var bills: [Bill]
    @Environment(\.modelContext) private var context

    enum Filter: String, CaseIterable, Identifiable { case unpaid, paid; var id: Self { self } }
    @State private var filter: Filter = .unpaid
    @State private var showAddBill  = false
    @State private var editMode: EditMode = .inactive

    private var viewBills: [Bill] {
        switch filter {
        case .unpaid: bills.filter { !$0.isPaid }
        case .paid:   bills.filter(\.isPaid)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if viewBills.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.quaternary)
                        Text(filter == .paid ? "No paid bills yet" : "No unpaid bills")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                }

                ForEach(viewBills) { bill in
                    NavigationLink { BillDetailView(bill: bill) } label: {
                        BillRowView(bill: bill)
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Bills")
            .environment(\.editMode, $editMode)
            .safeAreaInset(edge: .top) {
                Picker("Filter", selection: $filter) {
                    Text("Unpaid").tag(Filter.unpaid)
                    Text("Paid").tag(Filter.paid)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .background(.bar)
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddBill = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel("Add Bill")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("View", selection: $filter) {
                            Text("Unpaid").tag(Filter.unpaid)
                            Text("Paid").tag(Filter.paid)
                        }

                        Button(editMode.isEditing ? "Done Editing" : "Edit") {
                            editMode = editMode.isEditing ? .inactive : .active
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
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
            NotificationManager.cancel(for: viewBills[index])
            context.delete(viewBills[index])
        }
        try? context.save()
    }
}
