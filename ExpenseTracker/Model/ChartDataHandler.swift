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
    var subExpenses:[Expense] = [Expense]()
}

struct CategoryCountExpense{
    var category: String = ""
    var count: Int = 0
    var subExpenses:[Expense] = [Expense]()
}

struct DailyTotalExpense{
    var dailyTotal: Double = 0.0
    var date: Int = 0
    var subExpenses:[Expense] = [Expense]()
}

struct CumulativeExpense{
    var cumulativeAmount: Double = 0.0
    var date: Int = 0
    var subExpenses:[Expense] = [Expense]()
}

class ChartDataHandler{
    
    
    let MONTHLY_EXPENSE_CAP_KEY = "MonthlyExpenseCap"
    var setCap: Double = 0.0
    
    //Function to configure and manipulate the date returned by the system and into a tuple and return it with all necessary information in the correct format
    
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
    
    // Function to filter expenses according to the current month and return the filtered expenses
    func filterDataForCharts(expenses:[Expense]) -> [Expense]{
        guard expenses.count > 0 else {
            return [Expense]()
        }
        var filteredExpensesForCharts = [Expense]()
        let timeTuple = getCurrentMonthAndYear()
        
        //Looping the 2D expense array to find expenses in the current month and adding the amounts to the monthly amount variable
        for expense in expenses{
            if(expense.expenseDateString.contains(timeTuple.0) && expense.expenseDateString.contains(timeTuple.1))
            {
                filteredExpensesForCharts.append(expense)
            }
        }
        return filteredExpensesForCharts
    }
    
    //Function to prepare the data to the required format that can be fed into different charts by calling corresponding additional functions
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
    
    //Function to capture all the expense categories from the extracted array from database and create a string that contains all categories in non repetive format and return the string
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
    
    // Function to generate a sum of each category.
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
                    summarisedExpense.subExpenses.append(expense)
                }
            }
            summarisedExpenses.append(summarisedExpense)
        }
        summarisedExpenses.sort(by: {$0.subtotal>$1.subtotal})
        return summarisedExpenses
    }
    
    // Function to convert expense subtotal to the required whole number values for generic charts.
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
                otherExpenses.subExpenses += summarisedExpenses[i].subExpenses
            }
            preparedData.append(otherExpenses)
            return preparedData
        }
    }
    
    // Function to geneate the legends description for all charts.
    func getChartsLegends(preparedDataForCharts:[SummarisedExpense]) -> String{
        guard preparedDataForCharts.count > 0 else {
            return "No data now, please add first expense"
        }
        var legendsLabel = String()
        for i in 0...preparedDataForCharts.count - 1{
            legendsLabel += (String(i+1) + "." + preparedDataForCharts[i].legendName + " ")
        }
        return legendsLabel
    }
    
    // Function to convert expense subtotal to the required percentile values for the pie-chart.
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
            preparedDataForPieChart[i].subExpenses = preparedDataForCharts[i].subExpenses
        }
        return preparedDataForPieChart
    }
    
    // Function to convert the prepared data to the piecharts data entries according to the required format.
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
    
    // Function to convert the prepared data to the barcharts data entries according to the required format.
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
    
    //Function to process the expense retrieve from database, get counts of each expense category and retrieve
    //all exisiting expenses as a category - count dictionary
    // x = Count
    // y = Dates of current month ( say july, 1 - 31 of july)
    // each category will be a line and there should be dots on each date - count
    
    func getCategories(expenses: [Expense]) -> [CategoryCountExpense]{
        var categorizedCountArray: [CategoryCountExpense] = []
        let categoryOptions:[String] = ["Food & Dining", "Transportation", "Utilities", "Housing", "Entertainment", "Health & Wellness", "Personal Care", "Travel", "Shopping", "Education", "Debt Payments", "Gifts & Donations", "Miscellaneous","Business","Groceries","Transfer Payments","Other"]
        
        for category in categoryOptions{
            var count = 0
            var subExpenses:[Expense] = [Expense]()
            for expense in expenses{
                if expense.category == category{
                    count += 1
                    subExpenses.append(expense)
                }
            }
            if count != 0{
                let catCount = CategoryCountExpense(category: category, count: count,subExpenses: subExpenses)
                categorizedCountArray.append(catCount)
            }
            count = 0
        }
        return categorizedCountArray
    }
    
    // Function to prepare the date according to required format for the Category - Count Bar Chart
    func prepareCategoryCountChartEntry(preparedDataForCharts:[CategoryCountExpense]) ->[BarChartDataEntry]{
        guard preparedDataForCharts.count > 0 else{
            return [BarChartDataEntry]()
        }
        var barChartDataEntries = [BarChartDataEntry]()
        for i in 0...preparedDataForCharts.count - 1 {
            barChartDataEntries.append(BarChartDataEntry(x: Double(i+1), y: Double(preparedDataForCharts[i].count)))
        }
        return barChartDataEntries
    }
    
    func getGroupedMonthExpenses(expenses: [Expense]) -> [DailyTotalExpense]{
        var dailyTotalExpenseArray: [DailyTotalExpense] = []
        let date: [String] = ["1", "2", "3", "4", "5", "6", "7",
                    "8", "9", "10", "11", "12", "13",
                    "14", "15", "16", "17", "18", "19",
                    "20", "21", "22", "23", "24", "25",
                    "26", "27", "28", "29", "30", "31"]
        
        var dailyTotalExpenditure: Double = 0.0
        
        for item in date{
            var subExpenses:[Expense] = [Expense]()
            for expense in expenses{
                let components = expense.expenseDateString.components(separatedBy: " ")
                if Int(components[0]) == Int(item) {
                    dailyTotalExpenditure += expense.amount
                    subExpenses.append(expense)
                }
            }
            let expenseObj = DailyTotalExpense(dailyTotal: dailyTotalExpenditure, date: Int(item)!,subExpenses: subExpenses)
            dailyTotalExpenseArray.append(expenseObj)
            dailyTotalExpenditure = 0.0
        }
        return dailyTotalExpenseArray
    }
    
    func prepareGroupedMonthExpenses(preparedDataForCharts:[DailyTotalExpense]) ->[ChartDataEntry]{
        guard preparedDataForCharts.count > 0 else{
            return [ChartDataEntry]()
        }
        var barChartDataEntries = [ChartDataEntry]()
        for i in 0...preparedDataForCharts.count - 1
        {
            barChartDataEntries.append(ChartDataEntry(x: Double(preparedDataForCharts[i].date), y: Double(preparedDataForCharts[i].dailyTotal)))
        }
        return barChartDataEntries
    }
    
    func getCurrentMonthCumulativeExpenses(dailyTotalExpenses: [DailyTotalExpense]) -> [CumulativeExpense]{
        var cumulativeArray: [CumulativeExpense] = []
        var cumulativeAmount: Double = 0
        var subexpenses:[Expense] = [Expense]()
        
        for dailyExp in dailyTotalExpenses{
            cumulativeAmount += dailyExp.dailyTotal
            subexpenses += dailyExp.subExpenses
            //print(subexpenses.count)
            let cumulativeObj = CumulativeExpense(cumulativeAmount: cumulativeAmount, date: dailyExp.date,subExpenses: subexpenses)
            cumulativeArray.append(cumulativeObj)
        }
        return cumulativeArray
    }
    
    func prepareCumulativeExpenses(preparedDataForCharts:[CumulativeExpense]) -> [ChartDataEntry]{
        guard preparedDataForCharts.count > 0 else {
            return [ChartDataEntry]()
        }
        var lineChartDataEntries = [ChartDataEntry]()
        for i in 0...preparedDataForCharts.count - 1 {
            lineChartDataEntries.append(ChartDataEntry(x: Double(preparedDataForCharts[i].date), y: Double(preparedDataForCharts[i].cumulativeAmount)))
        }
        return lineChartDataEntries
    }
    
    func prepareSecondCumulativeExpensesLine(preparedDataForCharts:[CumulativeExpense])-> [ChartDataEntry]{
        
        guard preparedDataForCharts.count > 0 else{
            return [ChartDataEntry]()
        }
        
        if let monthlyCapRecord = UserDefaults.standard.value(forKey: self.MONTHLY_EXPENSE_CAP_KEY) as? Data{
            let expenseCapRecord = try! PropertyListDecoder().decode(ExpenseCap.self,from: monthlyCapRecord)
            setCap = expenseCapRecord.monthlyCapAmount
        }
        var lineChartDataEntries = [ChartDataEntry]()
        for i in 0...preparedDataForCharts.count-1{
            lineChartDataEntries.append(ChartDataEntry(x: Double(preparedDataForCharts[i].date), y: setCap))
        }
        return lineChartDataEntries
    }
}

// An extended protocol with a function that resolves all Double related values to the targeted decimal places for the Charts
extension Double {
    func rounded(digits: Int) -> Double {
        let multiplier = pow(10.0, Double(digits))
        return (self * multiplier).rounded() / multiplier
    }
}
