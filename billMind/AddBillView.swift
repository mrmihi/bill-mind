import SwiftUI
import PhotosUI

struct AddBillView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name=""; @State private var amountText=""; @State private var date=Date(); @State private var category:Bill.Category = .general; @State private var paymentMode:Bill.PaymentMode = .cash; @State private var frequency:Bill.Frequency = .none; @State private var receiptItem:PhotosPickerItem?; @State private var receiptData:Data?
    private var amount:Double?{ Double(amountText.replacingOccurrences(of:",",with:".")) }
    var body: some View{
        NavigationStack{
            Form{
                Section("Details"){ TextField("Bill name",text:$name); TextField("Amount (LKR)",text:$amountText).keyboardType(.decimalPad); DatePicker("Due date",selection:$date,displayedComponents:[.date,.hourAndMinute]) }
                Section("Category"){ Picker("Category",selection:$category){ ForEach(Bill.Category.allCases){ Label($0.rawValue,systemImage:$0.symbol).tag($0) } } }
                Section("Payment Mode"){ Picker("Payment",selection:$paymentMode){ ForEach(Bill.PaymentMode.allCases){ Text($0.rawValue).tag($0) } }.pickerStyle(.segmented) }
                Section("Repeat"){ Picker("Frequency",selection:$frequency){ ForEach(Bill.Frequency.allCases){ Text($0.rawValue).tag($0) } } }
                Section("Receipt (optional)"){ if let data=receiptData, let img=UIImage(data:data){ Image(uiImage:img).resizable().scaledToFit().frame(maxHeight:160) }; PhotosPicker(selection:$receiptItem,matching:.images){ Label("Select Photo",systemImage:"photo") }.onChange(of:receiptItem){ item in Task{ if let d=try? await item?.loadTransferable(type:Data.self){ receiptData=d } } } }
            }.navigationTitle("Add Bill").toolbar{ ToolbarItem(placement:.confirmationAction){ Button("Save"){ save() }.disabled(name.isEmpty||amount==nil) } }
        }
    }
    private func save(){ guard let amt=amount else{return}; let bill=Bill(name:name, date:date, amount:amt, category:category, paymentMode:paymentMode, frequency:frequency, receiptData:receiptData); context.insert(bill); try? context.save(); NotificationManager.schedule(for: bill); dismiss() }
}
