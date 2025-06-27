import SwiftUI

struct ContentView: View {
    @State private var showingReceiptScanner = false
    @State private var showingAnalytics = false
    
    var body: some View {
        #if os(iOS)
        TabView {
            HomeDashboardView()
                .tabItem { Label("Home", systemImage: "house") }
            
            BillsListView()
                .tabItem { Label("Bills", systemImage: "list.bullet") }
            
            TransactionsListView()
                .tabItem { Label("Transactions", systemImage: "creditcard") }
            
            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.bar") }
        }
        .sheet(isPresented: $showingReceiptScanner) {
            ReceiptScannerView()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingReceiptScanner = true
                } label: {
                    Image(systemName: "doc.text.viewfinder")
                }
            }
        }
        #else
        NavigationSplitView {
            SidebarView(
                showingReceiptScanner: $showingReceiptScanner,
                showingAnalytics: $showingAnalytics
            )
        } detail: {
            HomeDashboardView()
        }
        .sheet(isPresented: $showingReceiptScanner) {
            ReceiptScannerView()
        }
        .sheet(isPresented: $showingAnalytics) {
            AnalyticsView()
        }
        #endif
    }
}

#if os(macOS)
struct SidebarView: View {
    @Binding var showingReceiptScanner: Bool
    @Binding var showingAnalytics: Bool
    @State private var selectedTab: NavigationItem = .home
    
    var body: some View {
        List(NavigationItem.allCases, id: \.self, selection: $selectedTab) { item in
            NavigationLink(value: item) {
                Label(item.title, systemImage: item.icon)
            }
        }
        .navigationTitle("billMind")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    showingReceiptScanner = true
                } label: {
                    Image(systemName: "doc.text.viewfinder")
                }
                .help("Scan Receipt")
                
                Button {
                    showingAnalytics = true
                } label: {
                    Image(systemName: "chart.bar")
                }
                .help("Analytics")
            }
        }
    }
}

enum NavigationItem: CaseIterable {
    case home, bills, transactions, analytics
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .bills: return "Bills"
        case .transactions: return "Transactions"
        case .analytics: return "Analytics"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .bills: return "list.bullet"
        case .transactions: return "creditcard"
        case .analytics: return "chart.bar"
        }
    }
}
#endif
