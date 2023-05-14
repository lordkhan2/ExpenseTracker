//
//  Alert.swift
//  ExpenseTracker
//
//  Created by Cube on 5/13/23.
//

import Foundation

class Alert{
    var id: Int = 0
    var alertDate : String = ""
    var amount: Double = 0.0
    var description: String = ""
    
    init(id: Int, alertDate: String, amount: Double, description: String){
        
        self.id = id
        self.alertDate = alertDate
        self.amount = amount
        self.description = description
    }
}
