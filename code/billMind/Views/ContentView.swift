import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TabView {
                HomeDashboardView()
                    .tabItem { Label("Home", systemImage: "house") }

                BillsListView()
                    .tabItem { Label("Bills", systemImage: "list.bullet") }

                TransactionsListView()
                    .tabItem { Label("Transactions", systemImage: "creditcard") }

                AddBillView()
                    .tabItem { Label("Add Bill", systemImage: "plus.circle") }

                AddTransactionView()                        
                    .tabItem { Label("Add Txn", systemImage: "plus.rectangle") }
            }
        }
    }
}
