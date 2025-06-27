import Foundation
import CloudKit
import SwiftUI

/// A class that monitors CloudKit sync status and provides updates to the UI
@MainActor
class CloudKitSyncMonitor: ObservableObject {
    enum SyncStatus {
        case notStarted
        case inProgress
        case succeeded
        case failed(Error)
        
        var description: String {
            switch self {
            case .notStarted: return "Not started"
            case .inProgress: return "Syncing..."
            case .succeeded: return "Synced"
            case .failed(let error): return "Failed: \(error.localizedDescription)"
            }
        }
        
        var icon: String {
            switch self {
            case .notStarted: return "icloud"
            case .inProgress: return "arrow.clockwise"
            case .succeeded: return "checkmark.icloud"
            case .failed: return "exclamationmark.icloud"
            }
        }
        
        var color: Color {
            switch self {
            case .notStarted: return .secondary
            case .inProgress: return .blue
            case .succeeded: return .green
            case .failed: return .red
            }
        }
    }
    
    static let shared = CloudKitSyncMonitor()
    
    @Published var syncStatus: SyncStatus = .notStarted
    @Published var lastSyncTime: Date?
    @Published var isSignedInToiCloud = false
    @Published var error: String?
    
    private lazy var container: CKContainer? = {
        // Check if iCloud is available; if not, return nil to avoid runtime crash
        guard FileManager.default.ubiquityIdentityToken != nil else {
            return nil
        }
        return CKContainer(identifier: "iCloud.com.yourcompany.billMind")
    }()
    
    init() {
        Task { @MainActor in
            await getiCloudStatus()
        }
    }
    
    func getiCloudStatus() async {
        guard let container else {
            isSignedInToiCloud = false
            syncStatus = .notStarted
            return
        }
        do {
            let status = try await container.accountStatus()
            isSignedInToiCloud = status == .available
            if status == .available {
                syncStatus = .succeeded
                lastSyncTime = Date()
            } else {
                syncStatus = .failed(NSError(domain: "CloudKitSyncMonitor", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud account not available"]))
            }
        } catch {
            self.error = error.localizedDescription
            self.syncStatus = .failed(error)
        }
    }
    
    func requestiCloudAccess() async {
        guard let container else { return }
        do {
            _ = try await container.requestApplicationPermission(.userDiscoverability)
            await getiCloudStatus()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func fetchUserRecord() async -> CKRecord.ID? {
        guard let container else { return nil }
        do {
            let recordID = try await container.userRecordID()
            return recordID
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }
    
    func checkSyncStatus() async {
        guard let container else { return }
        syncStatus = .inProgress
        do {
            let status = try await container.accountStatus()
            if status == .available {
                _ = try await container.userRecordID()
                syncStatus = .succeeded
                lastSyncTime = Date()
                isSignedInToiCloud = true
            } else {
                syncStatus = .failed(NSError(domain: "CloudKitSyncMonitor", code: 1, userInfo: [NSLocalizedDescriptionKey: "iCloud account not available"]))
                isSignedInToiCloud = false
            }
        } catch {
            syncStatus = .failed(error)
            self.error = error.localizedDescription
        }
    }
}

struct CloudKitSyncStatusView: View {
    @ObservedObject private var monitor = CloudKitSyncMonitor.shared
    
    var body: some View {
        HStack {
            Image(systemName: monitor.syncStatus.icon)
                .foregroundColor(monitor.syncStatus.color)
                .imageScale(.medium)
            
            VStack(alignment: .leading) {
                Text("iCloud Sync: \(monitor.syncStatus.description)")
                    .font(.caption)
                    .foregroundColor(monitor.syncStatus.color)
                
                if let lastSync = monitor.lastSyncTime {
                    Text("Last sync: \(lastSync, formatter: dateFormatter)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if !monitor.isSignedInToiCloud {
                Button("Sign In") {
                    Task { @MainActor in
                        await monitor.requestiCloudAccess()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.horizontal)
        .onAppear {
            Task { @MainActor in
                await monitor.checkSyncStatus()
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}
