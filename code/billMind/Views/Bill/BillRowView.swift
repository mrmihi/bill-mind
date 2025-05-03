import SwiftUI

struct BillRowView: View {
    let bill: Bill
    var body: some View {
        HStack {
            Image(systemName: bill.category.symbol).foregroundColor(
                .accentColor
            )
            VStack(alignment: .leading) {
                Text(bill.name).font(.headline)
                Text(
                    "LKR \(String(format:"%.2f",bill.amount)) · \(bill.date,formatter:dateFormatter)"
                ).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            if bill.frequency != .none {
                Image(systemName: "repeat").foregroundColor(.blue)
            }
            if bill.isPaid {
                Image(systemName: "checkmark.circle.fill").foregroundColor(
                    .green
                )
            } else if bill.isOverdue {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
            }
        }
    }
}
