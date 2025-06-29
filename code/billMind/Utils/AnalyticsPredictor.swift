import Foundation
import CoreML

@MainActor
enum AnalyticsPredictor {
    struct Output {
        let nextMonthSpending: Double
        let overdueRisk: Double
        let savingsPotential: Double
    }

    private static var model: SpendingPatterns? = {
        try? SpendingPatterns(configuration: MLModelConfiguration())
    }()

    static func predict(bills: [Bill], transactions: [Transaction]) -> Output {
        var heuristic = heuristicPrediction(bills: bills)
        if let model {
            do {
                let input = try createTypedInput(bills: bills, transactions: transactions)
                let output = try model.prediction(input: input)
                heuristic = Output(
                    nextMonthSpending: heuristic.nextMonthSpending,
                    overdueRisk: output.overdueRisk,
                    savingsPotential: heuristic.savingsPotential)
            } catch {
                print("⚠️ CoreML prediction failed – using heuristics. Error: \(error)")
            }
        }

        return heuristic
    }

    private static func createTypedInput(bills: [Bill], transactions: [Transaction]) throws -> SpendingPatternsInput {
        let totalSpent = bills.reduce(0) { $0 + $1.amount }
        let averageBill = bills.isEmpty ? 0 : totalSpent / Double(bills.count)
        let overdueCount = Int64(bills.filter { $0.isOverdue }.count)

        func spent(for category: Bill.Category) -> Double {
            bills.filter { $0.category == category }.reduce(0) { $0 + $1.amount }
        }

        let groceries      = spent(for: .groceries)
        let utilities      = spent(for: .utilities)
        let entertainment  = spent(for: .entertainment)
        let transportation = spent(for: .transportation)

        let calendar = Calendar.current
        let today = Date()
        let day = calendar.component(.day, from: today)
        let payDayImpact: Int64 = (22...28).contains(day) ? 1 : 0

        let month: Int64 = Int64(calendar.component(.month, from: today))

        return SpendingPatternsInput(
            totalSpent: totalSpent,
            averageBill: averageBill,
            overdueCount: overdueCount,
            category_groceries_spent: groceries,
            category_utilities_spent: utilities,
            category_entertainment_spent: entertainment,
            category_transportation_spent: transportation,
            payDayImpact: payDayImpact,
            month: month)
    }

    private static func heuristicPrediction(bills: [Bill]) -> Output {
        let totalSpent = bills.reduce(0) { $0 + $1.amount }
        let avgBillAmount = bills.isEmpty ? 0 : totalSpent / Double(bills.count)
        let monthlyAverages = calculateMonthlyAverages(from: bills)
        let nextMonthSpending = monthlyAverages.last ?? totalSpent
        let overdueBills = bills.filter { $0.isOverdue }
        let overdueRisk = bills.isEmpty ? 0 : Double(overdueBills.count) / Double(bills.count)
        let highSpendingCategories = Dictionary(grouping: bills, by: { $0.category }).values.filter { group in
            group.reduce(0) { $0 + $1.amount } > avgBillAmount * 2
        }
        let savingsPotential = highSpendingCategories.flatMap { $0 }.reduce(0) { $0 + $1.amount * 0.1 }
        return Output(nextMonthSpending: nextMonthSpending, overdueRisk: overdueRisk, savingsPotential: savingsPotential)
    }

    private static func calculateMonthlyAverages(from bills: [Bill]) -> [Double] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: bills) { bill in
            calendar.dateInterval(of: .month, for: bill.date)?.start ?? bill.date
        }
        return grouped.values.map { monthBills in
            monthBills.reduce(0) { $0 + $1.amount }
        }.sorted()
    }
} 
