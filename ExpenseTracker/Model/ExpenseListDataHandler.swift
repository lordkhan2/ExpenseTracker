//
//  ExpenseListDataHandler.swift
//  ExpenseTracker
//
//  Created by Yangru Guo on 15/6/2023.
//

import Foundation

struct ExpenseListDataHandler{
    
    func getNumberOfSectionsAndRowsInEachSection(expenses:[Expense]) -> (Int,[Int]){
        var uniqueMonthYears: [String] = [] // Array to store non-repetitive month-year combinations
        var expenseCountPerMonthYear: [String: Int] = [:] // Dictionary to store expense count per month-year combination

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"

        for expense in expenses {
            let monthYear = dateFormatter.string(from: expense.expenseDate)
            
            // Check if the month-year combination is already in the uniqueMonthYears array
            if !uniqueMonthYears.contains(monthYear) {
                uniqueMonthYears.append(monthYear)
            }
            
            // Increment the expense count for the month-year combination in the expenseCountPerMonthYear dictionary
            if let count = expenseCountPerMonthYear[monthYear] {
                expenseCountPerMonthYear[monthYear] = count + 1
            } else {
                expenseCountPerMonthYear[monthYear] = 1
            }
        }
        uniqueMonthYears.sort { (monthYear1, monthYear2) -> Bool in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            
            if let date1 = dateFormatter.date(from: monthYear1), let date2 = dateFormatter.date(from: monthYear2) {
                return date1 < date2
            }
            
            return false
        }
        
        let expenseCountArray = uniqueMonthYears.map { monthYear -> Int in
            return expenseCountPerMonthYear[monthYear] ?? 0
        }
        
        return (uniqueMonthYears.count,expenseCountArray)
    }
    
}
