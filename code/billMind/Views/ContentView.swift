import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
       
                HomeDashboardView()
                    .tabItem { Label("Home", systemImage: "house") }

                BillsListView()
                    .tabItem { Label("Bills", systemImage: "list.bullet") }

                TransactionsListView()
                    .tabItem { Label("Transactions", systemImage: "creditcard") }
            
        }
    }
}
