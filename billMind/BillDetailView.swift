import SwiftUI
import PhotosUI

struct BillDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var bill: Bill
    @State private var photoItem: PhotosPickerItem?
    var body: some View{
        Form{
            Section("Summary"){
                HStack{ Image(systemName:bill.category.symbol).font(.title2); VStack(alignment:.leading){ Text(bill.name).font(.headline); Text("LKR \(String(format:"%.2f",bill.amount))") } }
                DetailRow(label: "Due", value: dateFormatter.string(from: bill.date))
                DetailRow(label: "Frequency", value: bill.frequency.rawValue)
                DetailRow(label: "Status", value: bill.isPaid ? "Paid" : bill.isOverdue ? "Overdue" : "Unpaid", valueColor: bill.isPaid ? .green : bill.isOverdue ? .orange : .primary)
                DetailRow(label: "Payment", value: bill.paymentMode.rawValue)
            }
            if bill.hasReceipt, let data=bill.receiptData, let img=UIImage(data:data){ Section("Receipt"){ Image(uiImage:img).resizable().scaledToFit().frame(maxHeight:250) } }
        }
        .navigationTitle("Bill Details")
        .toolbar{
            ToolbarItemGroup(placement:.navigationBarTrailing){
                Button(bill.isPaid ? "Unpay" : "Mark Paid"){ togglePaid() }
                if !bill.hasReceipt{
                    PhotosPicker(selection:$photoItem,matching:.images){ Image(systemName:"plus.app") }
                        .onChange(of:photoItem){ item in Task{ if let d=try? await item?.loadTransferable(type:Data.self){ bill.receiptData=d; try? context.save() } } }
                }
            }
        }
    }
    private func togglePaid(){
        bill.isPaid.toggle()
        bill.paidDate = bill.isPaid ? Date() : nil
        if bill.isPaid {
            NotificationManager.cancel(for: bill)
            if let next = bill.nextDate(){
                let newBill = Bill(name: bill.name, date: next, amount: bill.amount, category: bill.category, paymentMode: bill.paymentMode, frequency: bill.frequency)
                context.insert(newBill)
                NotificationManager.schedule(for: newBill)
            }
        } else {
            NotificationManager.schedule(for: bill)
        }
        try? context.save()
    }
}
