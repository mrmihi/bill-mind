import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeDashboardView().tabItem { Label("Home", systemImage: "house") }
            BillsListView().tabItem { Label("Bills", systemImage: "list.bullet") }
            AddBillView().tabItem { Label("Add", systemImage: "plus.circle") }
        }
    }
}
