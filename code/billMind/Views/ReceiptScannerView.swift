import SwiftUI
import Vision
import VisionKit
import PencilKit
import PhotosUI

struct ReceiptScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var scannedImage: UIImage?
    @State private var scannedText: String = ""
    @State private var isScanning = false
    @State private var showingScanner = false
    @State private var showingAnnotationView = false
    @State private var canvasView = PKCanvasView()
    @State private var extractedBill: Bill?
    @State private var showingBillForm = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let scannedImage = scannedImage {
                    Image(uiImage: scannedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                    
                    if !scannedText.isEmpty {
                        ScrollView {
                            Text("Extracted Text:")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(scannedText)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .frame(maxHeight: 200)
                    }
                    
                    HStack(spacing: 16) {
                        Button("Annotate Receipt") {
                            showingAnnotationView = true
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Create Bill") {
                            createBillFromText()
                        }
                        .buttonStyle(.bordered)
                        .disabled(scannedText.isEmpty)
                    }
                } else {
                    VStack(spacing: 24) {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        
                        Text("Scan Receipt")
                            .font(.title2.bold())
                        
                        Text("Use your camera or select a photo to scan a receipt and automatically extract bill information.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            Button("Scan with Camera") {
                                showingScanner = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                Label("Choose Photo", systemImage: "photo.on.rectangle")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Receipt Scanner")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: selectedImage) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run { scannedImage = image }
                    await extractText(from: image)
                }
            }
        }
        .sheet(isPresented: $showingScanner) {
            DataScannerViewControllerRepresentable { result in
                switch result {
                case .success(let image):
                    scannedImage = image
                    Task {
                        await extractText(from: image)
                    }
                case .failure(let error):
                    print("Scanner error: \(error)")
                }
            }
        }
        .sheet(isPresented: $showingAnnotationView) {
            ReceiptAnnotationView(image: scannedImage, canvasView: $canvasView)
        }
        .sheet(isPresented: $showingBillForm) {
            AddBillView()
        }
    }
    
    private func extractText(from image: UIImage) async {
        isScanning = true
        
        guard let cgImage = image.cgImage else {
            isScanning = false
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                isScanning = false
                return
            }
            
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            DispatchQueue.main.async {
                self.scannedText = recognizedText
                self.isScanning = false
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            DispatchQueue.main.async {
                self.isScanning = false
                print("Text recognition error: \(error)")
            }
        }
    }
    
    private func createBillFromText() {
        // Simple parsing logic - in a real app, you'd use more sophisticated NLP
        let lines = scannedText.components(separatedBy: .newlines)
        var amount: Double = 0
        var name = "Receipt"
        var date = Date()
        
        for line in lines {
            let lowercased = line.lowercased()
            
            // Look for amount patterns
            if lowercased.contains("total") || lowercased.contains("amount") {
                let numbers = line.components(separatedBy: CharacterSet.decimalDigits.inverted)
                    .compactMap { Double($0) }
                if let firstNumber = numbers.first {
                    amount = firstNumber
                }
            }
            
            // Look for date patterns
            if lowercased.contains("date") || lowercased.contains("202") {
                // Simple date extraction - in real app, use DateFormatter
                if let dateRange = line.range(of: #"\d{1,2}[/-]\d{1,2}[/-]\d{2,4}"#, options: .regularExpression) {
                    let dateString = String(line[dateRange])
                    // Parse date string here
                }
            }
            
            // Look for business name (first non-empty line that's not a number)
            if !line.isEmpty && !line.contains("total") && !line.contains("amount") && amount == 0 {
                name = line.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        extractedBill = Bill(
            name: name,
            date: date,
            amount: amount,
            category: .general,
            receiptData: scannedImage?.jpegData(compressionQuality: 0.8)
        )
        
        showingBillForm = true
    }
}

struct ReceiptAnnotationView: View {
    let image: UIImage?
    @Binding var canvasView: PKCanvasView
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                CanvasView(canvasView: canvasView)
            }
            .navigationTitle("Annotate Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Clear") {
                        canvasView.drawing = PKDrawing()
                    }
                }
            }
        }
    }
}

struct CanvasView: UIViewRepresentable {
    let canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .red, width: 2)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

struct DataScannerViewControllerRepresentable: UIViewControllerRepresentable {
    let completion: (Result<UIImage, Error>) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let completion: (Result<UIImage, Error>) -> Void
        
        init(completion: @escaping (Result<UIImage, Error>) -> Void) {
            self.completion = completion
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            // Handle tap on recognized text
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            // Handle newly recognized items
        }
    }
} 
