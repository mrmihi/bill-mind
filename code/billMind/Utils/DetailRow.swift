import SwiftUI

struct DetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundColor(valueColor)
        }
    }
}

let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    df.timeStyle = .short
    return df
}()
