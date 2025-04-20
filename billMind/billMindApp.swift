import SwiftUI
import SwiftData

@main
struct BillsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Bill.self)
    }
}

// MARK: - Data Model
@Model
final class Bill: Identifiable {
    var id: UUID
    var name: String
    var date: Date

    init(id: UUID = UUID(), name: String, date: Date) {
        self.id = id
        self.name = name
        self.date = date
    }
}

// MARK: - Root TabView
struct ContentView: View {
    var body: some View {
        TabView {
            BillsListView()
                .tabItem {
                    Label("Bills", systemImage: "list.bullet")
                }

            AddBillView()
                .tabItem {
                    Label("Add Bill", systemImage: "plus.circle")
                }
        }
    }
}

// MARK: - Add Bill Screen
struct AddBillView: View {
    @Environment(\.modelContext) private var context
    @State private var name = ""
    @State private var date = Date()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Bill name", text: $name)
                    DatePicker("Due date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Add Bill")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let bill = Bill(name: name, date: date)
                        context.insert(bill)
                        try? context.save()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Bills List Screen
struct BillsListView: View {
    @Query(sort: \Bill.date, order: .forward) private var bills: [Bill]
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            List {
                ForEach(bills) { bill in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(bill.name)
                                .font(.headline)
                            Text(bill.date, style: .date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        context.delete(bills[index])
                    }
                    try? context.save()
                }
            }
            .navigationTitle("Bills")
            .toolbar { EditButton() }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(for: Bill.self, inMemory: true)
}
