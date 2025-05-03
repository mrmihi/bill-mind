import Foundation
import SwiftData

enum ExportService {
    
    static func exportBills(_ bills: [Bill]) -> String {
        var csv = "ID,Name,Date,Amount,Category,PaymentMode,IsPaid\n"
        let formatter = ISO8601DateFormatter()

        for bill in bills {
            let row = [
                bill.id.uuidString,
                bill.name,
                formatter.string(from: bill.date),
                String(bill.amount),
                bill.category.rawValue,
                bill.paymentMode.rawValue,
                bill.isPaid ? "Yes" : "No"
            ].joined(separator: ",")
            csv += row + "\n"
        }
        return csv
    }
    
    static func exportTransactions(_ txns: [Transaction]) -> String {
        var csv = "ID,Payee,Date,Amount,Category\n"
        let formatter = ISO8601DateFormatter()

        for txn in txns {
            let row = [
                txn.id.uuidString,
                txn.payee,
                formatter.string(from: txn.date),
                String(txn.amount),
                txn.category.rawValue
            ].joined(separator: ",")
            csv += row + "\n"
        }
        return csv
    }
}
