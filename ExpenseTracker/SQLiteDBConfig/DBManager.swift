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
    }
    
    let dbPath: String = "myDb.sqlite"
    var db: OpaquePointer?
    
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
    
    //Create a table if it does not exist
    func createTable(){
        let createTableString = "CREATE TABLE IF NOT EXISTS Expense(Id INTEGER PRIMARY KEY, expenseDate TEXT, amount DOUBLE, category TEXT, paymentType TEXT, description TEXT, imageLink TEXT, notes TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("Expense Table Created!")
            } else {
                print("Expense Table Count not be Created!")
            }
        }else{
            print("Create Table Statement could not be prepared!")
        }
        sqlite3_finalize(createTableStatement)
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
            print("INSERT statement coult not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    //Read Data from the Database
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
                print("Query Result")
                print("\(id)| \(expenseDate) | \(amount) | \(category) | \(paymentType) | \(description) | \(imageLink) | \(notes)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        return expenses
    }
    
    //Delete a specific expense record from the Expense table based on the id
    func deleteByID(id:Int) {
          let deleteStatementString = "DELETE FROM Expenses WHERE Id = ?;"
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
