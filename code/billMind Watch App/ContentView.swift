//
//  ContentView.swift
//  billMind Watch App
//
//  Created by Pasindu Dinal on 2025-06-28.
//

import SwiftUI
import SwiftData

struct NextBillView: View {
    @Query(
        filter: #Predicate<Bill> { !$0.isPaid },
        sort: \Bill.date
    ) private var pendingBills: [Bill]

    private var next: Bill? { pendingBills.first }

    var body: some View {
        VStack {
            if let bill = next {
                Text("Next Bill").font(.caption2).foregroundStyle(.secondary)
                Text(bill.name).font(.headline).lineLimit(1)
                Text(bill.date, style: .date)
                Text(bill.amount, format: .currency(code: "LKR"))
                    .font(.title3.bold())
            } else {
                Spacer()
                Text("No unpaid bills").font(.headline)
                Spacer()
            }
        }
        .padding()
    }
}
