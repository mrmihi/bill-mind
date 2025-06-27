import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultCurrency") private var defaultCurrency = "LKR"
    @AppStorage("reminderDays") private var reminderDays = 1
    @AppStorage("autoCategorize") private var autoCategorize = true
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("exportFormat") private var exportFormat = ExportFormat.csv
    
    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    Picker("Default Currency", selection: $defaultCurrency) {
                        Text("Sri Lankan Rupee (LKR)").tag("LKR")
                        Text("US Dollar (USD)").tag("USD")
                        Text("Euro (EUR)").tag("EUR")
                        Text("British Pound (GBP)").tag("GBP")
                    }
                    
                    Stepper("Reminder Days: \(reminderDays)", value: $reminderDays, in: 1...7)
                    
                    Toggle("Auto-categorize bills", isOn: $autoCategorize)
                    
                    Toggle("Enable notifications", isOn: $enableNotifications)
                }
                
                Section("Export") {
                    Picker("Default Export Format", selection: $exportFormat) {
                        Text("CSV").tag(ExportFormat.csv)
                        Text("PDF").tag(ExportFormat.pdf)
                        Text("Excel").tag(ExportFormat.excel)
                    }
                    
                    Button("Export All Data") {
                        // Handle export
                    }
                    .buttonStyle(.bordered)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://yourcompany.com/privacy")!)
                    
                    Link("Terms of Service", destination: URL(string: "https://yourcompany.com/terms")!)
                }
            }
            .navigationTitle("Settings")
            .formStyle(.grouped)
        }
    }
}

enum ExportFormat: String, CaseIterable {
    case csv = "CSV"
    case pdf = "PDF"
    case excel = "Excel"
} 