//
//  billMindApp.swift
//  billMind Watch App
//
//  Created by Pasindu Dinal on 2025-06-28.
//

import SwiftUI
import SwiftData

@main
struct BillsWatchApp: App {
    // Insert demo bill if store empty (watch-only convenience)
    init() {
        #if os(watchOS)
        let context = ModelContainer.shared.mainContext
        let descriptor = FetchDescriptor<Bill>()
        if (try? context.fetch(descriptor).isEmpty) == true {
            let sample = Bill(
                name: "Demo Electricity Bill",
                date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                amount: 2450,
                category: .utilities
            )
            context.insert(sample)
            try? context.save()
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            BillsListViewWatch()
                .modelContainer(ModelContainer.shared)
        }
    }
}
