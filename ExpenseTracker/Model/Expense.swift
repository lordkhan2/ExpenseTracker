//
//  Expense.swift
//  ExpenseTracker
//
//  Created by Cube on 5/2/23.
//

import Foundation

class Expense{
    var id: Int = 0
    var expenseDateString : String = ""
    var expenseDate: Date
    var amount: Double = 0.0
    var category: String = ""
    var paymentType: String = ""
    var description: String = ""
    var imageLink: String = ""
    var notes: String = ""
    
    init(id: Int, expenseDate: String, amount: Double, category: String, paymentType: String,
         description: String, imageLink: String, notes: String){
        
        self.id = id
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yy"
        self.expenseDate = dateFormatter.date(from: expenseDate)!
        self.expenseDateString = expenseDate
        self.amount = amount
        self.category = category
        self.paymentType = paymentType
        self.description = description
        self.imageLink = imageLink
        self.notes = notes
    }
}
