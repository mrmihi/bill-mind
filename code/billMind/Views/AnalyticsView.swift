import SwiftUI
import Charts
import SwiftData
import CoreML

struct AnalyticsView: View {
    @Query(sort: \Bill.date, order: .forward) private var bills: [Bill]
    @Query(sort: \Transaction.date, order: .forward) private var transactions: [Transaction]
    
    @State private var selectedTimeframe: Timeframe = .month
    @State private var selectedCategory: Bill.Category?
    @State private var showingPredictions = false
    
    private var filteredBills: [Bill] {
        bills.filter { bill in
            let isInTimeframe = bill.date >= selectedTimeframe.startDate
            let isInCategory = selectedCategory == nil || bill.category == selectedCategory
            return isInTimeframe && isInCategory
        }
    }
    
    private var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            transaction.date >= selectedTimeframe.startDate
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Picker("Timeframe", selection: $selectedTimeframe) {
                            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                                Text(timeframe.displayName).tag(timeframe)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Spacer()
                        
                        Menu("Category") {
                            Button("All Categories") {
                                selectedCategory = nil
                            }
                            
                            ForEach(Bill.Category.allCases, id: \.self) { category in
                                Button(category.rawValue) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Key Metrics
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        MetricCard(
                            title: "Total Spent",
                            value: totalSpent,
                            format: .currency,
                            trend: spendingTrend,
                            color: .red
                        )
                        
                        MetricCard(
                            title: "Avg per Bill",
                            value: averageBillAmount,
                            format: .currency,
                            trend: nil,
                            color: .blue
                        )
                        
                        MetricCard(
                            title: "Bills Count",
                            value: Double(filteredBills.count),
                            format: .number,
                            trend: billsTrend,
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Spending Trends Chart
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Spending Trends")
                                .font(.headline)
                            
                            Chart(spendingData, id: \.date) { data in
                                LineMark(
                                    x: .value("Date", data.date),
                                    y: .value("Amount", data.amount)
                                )
                                .foregroundStyle(.blue)
                                .interpolationMethod(.catmullRom)
                                
                                AreaMark(
                                    x: .value("Date", data.date),
                                    y: .value("Amount", data.amount)
                                )
                                .foregroundStyle(.blue.opacity(0.1))
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .frame(height: 200)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Category Breakdown
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category Breakdown")
                                .font(.headline)
                            
                            Chart(categoryData, id: \.category) { data in
                                BarMark(
                                    x: .value("Category", data.category.rawValue),
                                    y: .value("Amount", data.amount)
                                )
                                .foregroundStyle(by: .value("Category", data.category.rawValue))
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .frame(height: 200)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Payment Method Analysis
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Payment Methods")
                                .font(.headline)
                            
                            Chart(paymentMethodData, id: \.method) { data in
                                SectorMark(
                                    angle: .value("Amount", data.amount),
                                    innerRadius: .ratio(0.6),
                                    angularInset: 2
                                )
                                .foregroundStyle(by: .value("Method", data.method))
                            }
                            .frame(height: 200)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Predictions Section
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("AI Predictions")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button("View Details") {
                                    showingPredictions = true
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                PredictionRow(
                                    title: "Next Month Spending",
                                    value: predictedNextMonthSpending,
                                    format: .currency,
                                    confidence: 0.85
                                )
                                
                                PredictionRow(
                                    title: "Overdue Risk",
                                    value: overdueRiskPercentage,
                                    format: .percentage,
                                    confidence: 0.72
                                )
                                
                                PredictionRow(
                                    title: "Savings Potential",
                                    value: savingsPotential,
                                    format: .currency,
                                    confidence: 0.78
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
            .sheet(isPresented: $showingPredictions) {
                PredictionsDetailView(bills: filteredBills, transactions: filteredTransactions)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalSpent: Double {
        filteredBills.reduce(0) { $0 + $1.amount }
    }
    
    private var averageBillAmount: Double {
        filteredBills.isEmpty ? 0 : totalSpent / Double(filteredBills.count)
    }
    
    private var spendingTrend: Double {
        // Calculate trend based on previous period
        let currentPeriod = totalSpent
        let previousPeriod = calculatePreviousPeriodSpending()
        return previousPeriod == 0 ? 0 : ((currentPeriod - previousPeriod) / previousPeriod) * 100
    }
    
    private var billsTrend: Double {
        let currentCount = filteredBills.count
        let previousCount = calculatePreviousPeriodBillCount()
        return previousCount == 0 ? 0 : Double(currentCount - previousCount) / Double(previousCount) * 100
    }
    
    private var spendingData: [SpendingData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredBills) { bill in
            calendar.startOfDay(for: bill.date)
        }
        
        return grouped.map { date, bills in
            SpendingData(
                date: date,
                amount: bills.reduce(0) { $0 + $1.amount }
            )
        }.sorted { $0.date < $1.date }
    }
    
    private var categoryData: [CategoryData] {
        let grouped = Dictionary(grouping: filteredBills, by: \.category)
        return grouped.map { category, bills in
            CategoryData(
                category: category,
                amount: bills.reduce(0) { $0 + $1.amount }
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    private var paymentMethodData: [PaymentMethodData] {
        let grouped = Dictionary(grouping: filteredBills, by: \.paymentMode)
        return grouped.map { method, bills in
            PaymentMethodData(
                method: method.rawValue,
                amount: bills.reduce(0) { $0 + $1.amount }
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    // MARK: - Prediction Properties (powered by Core ML)
    
    private var predictions: AnalyticsPredictor.Output {
        AnalyticsPredictor.predict(bills: bills, transactions: transactions)
    }
    
    private var predictedNextMonthSpending: Double { predictions.nextMonthSpending }
    private var overdueRiskPercentage: Double { predictions.overdueRisk * 100 }
    private var savingsPotential: Double { predictions.savingsPotential }
    
    // MARK: - Helper Methods
    
    private func calculatePreviousPeriodSpending() -> Double {
        let previousStartDate = selectedTimeframe.previousStartDate
        return bills.filter { $0.date >= previousStartDate && $0.date < selectedTimeframe.startDate }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func calculatePreviousPeriodBillCount() -> Int {
        let previousStartDate = selectedTimeframe.previousStartDate
        return bills.filter { $0.date >= previousStartDate && $0.date < selectedTimeframe.startDate }.count
    }
    
    private func calculateMonthlyAverages() -> [Double] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: bills) { bill in
            calendar.dateInterval(of: .month, for: bill.date)?.start ?? bill.date
        }
        
        return grouped.values.map { bills in
            bills.reduce(0) { $0 + $1.amount }
        }.sorted()
    }
}

// MARK: - Supporting Types

enum Timeframe: CaseIterable {
    case week, month, quarter, year
    
    var displayName: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .quarter: return "Quarter"
        case .year: return "Year"
        }
    }
    
    var startDate: Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .week:
            return calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case .month:
            return calendar.dateInterval(of: .month, for: now)?.start ?? now
        case .quarter:
            return calendar.dateInterval(of: .quarter, for: now)?.start ?? now
        case .year:
            return calendar.dateInterval(of: .year, for: now)?.start ?? now
        }
    }
    
    var previousStartDate: Date {
        let calendar = Calendar.current
        let currentStart = startDate
        
        switch self {
        case .week:
            return calendar.date(byAdding: .weekOfYear, value: -1, to: currentStart) ?? currentStart
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: currentStart) ?? currentStart
        case .quarter:
            return calendar.date(byAdding: .quarter, value: -1, to: currentStart) ?? currentStart
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: currentStart) ?? currentStart
        }
    }
}

struct SpendingData {
    let date: Date
    let amount: Double
}

struct CategoryData {
    let category: Bill.Category
    let amount: Double
}

struct PaymentMethodData {
    let method: String
    let amount: Double
}

struct MetricCard: View {
    let title: String
    let value: Double
    let format: MetricFormat
    let trend: Double?
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(formattedValue)
                .font(.title2.bold())
                .foregroundStyle(color)
            
            if let trend = trend {
                HStack(spacing: 4) {
                    Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(String(format: "%.1f", abs(trend)))%")
                }
                .font(.caption2)
                .foregroundStyle(trend >= 0 ? .red : .green)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2, y: 1)
    }
    
    private var formattedValue: String {
        switch format {
        case .currency:
            return "LKR \(String(format: "%.2f", value))"
        case .number:
            return "\(Int(value))"
        case .percentage:
            return "\(String(format: "%.1f", value))%"
        }
    }
}

enum MetricFormat {
    case currency, number, percentage
}

struct PredictionRow: View {
    let title: String
    let value: Double
    let format: MetricFormat
    let confidence: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(formattedValue)
                    .font(.headline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(confidence * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("Confidence")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var formattedValue: String {
        switch format {
        case .currency:
            return "LKR \(String(format: "%.2f", value))"
        case .number:
            return "\(Int(value))"
        case .percentage:
            return "\(String(format: "%.1f", value))%"
        }
    }
}

struct PredictionsDetailView: View {
    let bills: [Bill]
    let transactions: [Transaction]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Detailed AI Predictions")
                        .font(.title2.bold())
                        .padding(.top)
                    
                    Text("Advanced machine learning predictions based on your spending patterns and historical data.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Predictions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 
