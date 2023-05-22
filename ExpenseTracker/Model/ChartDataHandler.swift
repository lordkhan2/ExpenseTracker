//
//  ChartDataHandler.swift
//  ExpenseTracker
//
//  Created by Yangru Guo on 22/5/2023.
//

import Foundation
import Charts

struct SummarisedExpense{
    var legendName:String = ""
    var subtotal:Double = 0
}

class ChartDataHandler{
    
    func getCurrentMonthAndYear() -> (String,String,String){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let stringDate = dateFormatter.string(from: date)
        let components = stringDate.components(separatedBy: " ")
        
        let monthComponent:String
        if components[0].count >= 3{
            monthComponent = components[0]
        } else{
            monthComponent = components[1]
        }
        return (monthComponent,components[2],stringDate)
    }
    
    func filterDataForCharts(expenses:[Expense]) -> [Expense]{
        guard expenses.count > 0 else {
            return [Expense]()
        }
        var filteredExpensesForCharts = [Expense]()
        let timeTuple = getCurrentMonthAndYear()

        
        //Looping the 2D expense array to find expenses in the current month and adding the amounts to the monthly amount variable
        for expense in expenses{
            if(expense.expenseDate.contains(timeTuple.0) && expense.expenseDate.contains(timeTuple.1))
            {
                filteredExpensesForCharts.append(expense)
            }
        }
        return filteredExpensesForCharts
    }
    
    func prepareChartData(expenses:[Expense]) -> [SummarisedExpense]{
        guard expenses.count > 0 else{
            return [SummarisedExpense]()
        }
        //extract legend, expense is assumed not to be empty to trigger this function
        let extractedLengend = extractLengend(expenses: expenses)
        //summarise data according to date and category
        let summarisedExpenses = summariseData(expenses: expenses, legend: extractedLengend)
        //sort the array, extract top 3 elements, and sum all remaining up as the fourth components and added to the return data
        let preparedData = prepareDataForCharts(summarisedExpenses: summarisedExpenses)
        //for the pie chart, convert the value to percentage
        return preparedData
    }
    
    func extractLengend(expenses:[Expense]) -> [String]{
        guard expenses.count > 0 else{
            return [String]()
        }
        var legendArrary = [String]()
        legendArrary.append(expenses[0].category.uppercased())
        for expense in expenses {
            if let _ = legendArrary.firstIndex(of: expense.category.uppercased()){
            }else{
                legendArrary.append(expense.category.uppercased())
            }
        }
        return legendArrary
    }
    
    func summariseData(expenses:[Expense],legend:[String]) -> [SummarisedExpense]{
        guard expenses.count > 0 else{
            return [SummarisedExpense]()
        }
        var summarisedExpenses = [SummarisedExpense]()
        for legendName in legend{
            var summarisedExpense = SummarisedExpense()
            summarisedExpense.legendName = legendName
            for expense in expenses {
                if expense.category.uppercased() == legendName{
                    summarisedExpense.subtotal += expense.amount
                }
            }
            summarisedExpenses.append(summarisedExpense)
        }
        summarisedExpenses.sort(by: {$0.subtotal>$1.subtotal})
        return summarisedExpenses
    }
    
    func prepareDataForCharts(summarisedExpenses:[SummarisedExpense]) -> [SummarisedExpense]{
        guard summarisedExpenses.count > 0 else{
            return [SummarisedExpense]()
        }
        if summarisedExpenses.count <= 3{
            return summarisedExpenses
        }else{
            var preparedData = [SummarisedExpense]()
            for i in 0...2{
                preparedData.append(summarisedExpenses[i])
            }
            var otherExpenses = SummarisedExpense()
            otherExpenses.legendName = "OTHER"
            for i in 3...summarisedExpenses.count - 1 {
                otherExpenses.subtotal += summarisedExpenses[i].subtotal
            }
            preparedData.append(otherExpenses)
            return preparedData
        }
    }
    
    func getChartsLegends(preparedDataForCharts:[SummarisedExpense]) -> String{
        guard preparedDataForCharts.count > 0 else {
            return "No data now, please add first expense"
        }
        var legendsLabel = String()
        for i in 0...preparedDataForCharts.count - 1{
            legendsLabel += (String(i+1) + "." + preparedDataForCharts[i].legendName + " ")
        }
        let timeTuple = getCurrentMonthAndYear()
        return "[" + legendsLabel + "] For \(timeTuple.0), \(timeTuple.1)"
    }
    
    func prepareDataForPieChart(preparedDataForCharts:[SummarisedExpense]) -> [SummarisedExpense]{
        guard preparedDataForCharts.count > 0 else{
            return [SummarisedExpense]()
        }
        var total:Double = 0
        var preparedDataForPieChart = [SummarisedExpense]()
        for summarisedExpense in preparedDataForCharts{
            total += summarisedExpense.subtotal
        }
        for i in 0...preparedDataForCharts.count - 1 {
            var expenseForPie = SummarisedExpense()
            expenseForPie.subtotal = (preparedDataForCharts[i].subtotal / total * 100).rounded(digits: 1)
            preparedDataForPieChart.append(expenseForPie)
        }
        return preparedDataForPieChart
    }
    
    func preparePieChartEntry(preparedDataForPieChart:[SummarisedExpense]) -> [ChartDataEntry]{
        guard preparedDataForPieChart.count > 0 else{
            return [ChartDataEntry]()
        }
        var pieChartDataEntries = [ChartDataEntry]()
        for i in 0...preparedDataForPieChart.count - 1{
            pieChartDataEntries.append(ChartDataEntry(x:Double(i),y:preparedDataForPieChart[i].subtotal))
        }
        return pieChartDataEntries
    }
    
    func prepareBarChartEntry(preparedDataForCharts:[SummarisedExpense]) ->[BarChartDataEntry]{
        guard preparedDataForCharts.count > 0 else{
            return [BarChartDataEntry]()
        }
        var barChartDataEntries = [BarChartDataEntry]()
        for i in 0...preparedDataForCharts.count - 1 {
            barChartDataEntries.append(BarChartDataEntry(x: Double(i+1), y: preparedDataForCharts[i].subtotal))
        }
        return barChartDataEntries
    }
}

extension Double {
    func rounded(digits: Int) -> Double {
        let multiplier = pow(10.0, Double(digits))
        return (self * multiplier).rounded() / multiplier
    }
}
