//
//  DBManager.swift
//  ExpenseTracker
//
//  Created by Cube on 5/6/23.
//

import Foundation
import SQLite3

class DBManager
{
    init()
    {
        db = openDatabase()
        createTable()
        createAlertsTable()
    }
    
    let dbPath: String = "myDb.sqlite"
    var db: OpaquePointer?
    
    //Open Database Connection
    func openDatabase() -> OpaquePointer?
    {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(filePath.path, &db) != SQLITE_OK
        {
            debugPrint("can't open database")
            return nil
        }
        else{
            print("Successfully created connection to database at \(dbPath)")
            return db
        }
    }
    
    //Create an Expense table if it does not exist
    func createTable(){
        let createTableString = "CREATE TABLE IF NOT EXISTS Expense(Id INTEGER PRIMARY KEY, expenseDate TEXT, amount DOUBLE, category TEXT, paymentType TEXT, description TEXT, imageLink TEXT, notes TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("Expense Table Created!")
            } else {
                print("Expense Table could not be Created!")
            }
        }else{
            print("Create Table Statement could not be prepared!")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    //Create an Alert table if does not exist
    func createAlertsTable(){
        let createAlertTableString = "CREATE TABLE IF NOT EXISTS Alert(Id INTEGER PRIMARY KEY, alertDate TEXT, amount Double, description TEXT);"
        var createAlertTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createAlertTableString, -1, &createAlertTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createAlertTableStatement) == SQLITE_DONE
            {
                print("Alerts Table Created!")
            }else{
                print("Alert table creation error!")
            }
        }else{
            print("Create Table Statement could not be prepared!")
        }
        sqlite3_finalize(createAlertTableStatement)
    }
    
    //Insert Expense data into the database
    func insert(expenseDate: String, amount: Double, category: String, paymentType: String, description: String, imageLink: String, notes: String){
        
        let insertStatementString = "INSERT INTO Expense(expenseDate, amount, category, paymentType, description, imageLink, notes) VALUES(?,?,?,?,?,?,?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK{
            sqlite3_bind_text(insertStatement, 1, (expenseDate as NSString).utf8String, -1, nil)
            sqlite3_bind_double(insertStatement, 2, amount)
            sqlite3_bind_text(insertStatement, 3, (category as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (paymentType as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, (description as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, (imageLink as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, (notes as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE{
                print("Successfully Insertd Row.")
            } else {
                print("Count not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    //Insert Alert data into the database
    func insertAlert(alertDate: String, amount: Double, description: String){
        let insertAlertString = "INSERT INTO Alert(alertDate, amount, description)VALUES(?,?,?);"
        var insertAlertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertAlertString, -1, &insertAlertStatement, nil) == SQLITE_OK{
            sqlite3_bind_text(insertAlertStatement, 1, (alertDate as NSString).utf8String, -1, nil)
            sqlite3_bind_double(insertAlertStatement, 2, amount)
            sqlite3_bind_text(insertAlertStatement, 3, (description as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertAlertStatement) == SQLITE_DONE{
                print("Successfully Inserted Alert Data.")
            }else{
                print("Data insertion error!")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertAlertStatement)
        
    }
    
    //Read Data from the Expense Table
    func read() -> [Expense] {
        let queryStatementString = "SELECT * FROM Expense;"
        
        var queryStatement: OpaquePointer? = nil
        var expenses: [Expense] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let expenseDate = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let amount = sqlite3_column_double(queryStatement, 2)
                let category = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let paymentType = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let description = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let imageLink = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                let notes = String(describing: String(cString: sqlite3_column_text(queryStatement, 7)))
                expenses.append(Expense(id: Int(id), expenseDate: expenseDate, amount: amount, category: category, paymentType: paymentType, description: description, imageLink: imageLink, notes: notes))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        return expenses
    }
    
    //Read Data from the Alerts Table
    func readAlerts() -> [Alert] {
        let queryAlertStatementString = "SELECT * FROM Alert;"
        
        var queryAlertStatement: OpaquePointer? = nil
        var alerts: [Alert] = []
        if sqlite3_prepare_v2(db, queryAlertStatementString, -1, &queryAlertStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryAlertStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryAlertStatement, 0)
                let alertDate = String(describing: String(cString: sqlite3_column_text(queryAlertStatement, 1)))
                let amount = sqlite3_column_double(queryAlertStatement, 2)
                let description = String(describing: String(cString: sqlite3_column_text(queryAlertStatement, 3)))
                alerts.append(Alert(id: Int(id), alertDate: alertDate, amount: amount, description: description))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryAlertStatement)
        return alerts
    }
    
    //Delete a specific Alert record from the Alert table based on the id
    func deleteAlertByID(id: Int){
        let deleteAlertStatementString = "DELETE FROM Alert WHERE Id =?;"
        var deleteAlertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteAlertStatementString, -1, &deleteAlertStatement, nil) == SQLITE_OK{
            sqlite3_bind_int(deleteAlertStatement, 1, Int32(id))
            if sqlite3_step(deleteAlertStatement) == SQLITE_DONE{
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteAlertStatement)
    }
    
    //Delete a specific expense record from the Expense table based on the id
    func deleteByID(id:Int) {
          let deleteStatementString = "DELETE FROM Expense WHERE Id = ?;"
          var deleteStatement: OpaquePointer? = nil
          if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
              sqlite3_bind_int(deleteStatement, 1, Int32(id))
              if sqlite3_step(deleteStatement) == SQLITE_DONE {
                  print("Successfully deleted row.")
              } else {
                  print("Could not delete row.")
              }
          } else {
              print("DELETE statement could not be prepared")
          }
          sqlite3_finalize(deleteStatement)

      }
}
