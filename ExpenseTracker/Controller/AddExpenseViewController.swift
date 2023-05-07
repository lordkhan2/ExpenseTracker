//
//  AddExpense.swift
//  ExpenseTracker
//
//  Created by Cube on 5/1/23.
//

import Foundation
import UIKit

class AddExpenseViewController : UIViewController {

    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var paymentTypeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var recieptImageView: UIImageView!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var addExpenseButton: UIButton!
    
    var db = DBManager()
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatepicker()
        // Do any additional setup after loading the view.
    }
    
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        return toolbar
    }
    
    func createDatepicker(){
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = createToolbar()
    }
    
    @objc func donePressed(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        self.dateTextField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }

    @IBAction func AddExpense(_ sender: Any) {
        var id = 1
        var expenseDate = dateTextField.text ?? ""
        var expenseAmount = Double(amountTextField.text ?? "0") ?? 0.0
        var expenseCategory = categoryTextField.text ?? ""
        var expensePaymentType = paymentTypeTextField.text ?? ""
        var expenseDescription = descriptionTextField.text ?? ""
        var expenseRecieptImage = ""
        var expenseNotes = notesTextField.text ?? ""
        
        print("| EZPROGAMER \(id)| \(expenseDate)| \(expenseAmount)| \(expenseCategory)| \(expensePaymentType)| \(expenseDescription)| \(expenseRecieptImage)| \(expenseNotes)")
        
        db.insert(expenseDate: expenseDate, amount: expenseAmount, category: expenseCategory, paymentType: expensePaymentType, description: expenseDescription, imageLink: expenseRecieptImage, notes: expenseNotes)
    }
}
