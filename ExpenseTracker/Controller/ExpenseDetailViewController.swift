//
//  ExpenseDetailViewController.swift
//  ExpenseTracker
//
//  Created by Yan Hua on 15/5/2023.
//

import UIKit

class ExpenseDetailViewController: UIViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var expenseDateTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var expenseCategoryTextField: UITextField!
    @IBOutlet weak var paymentTypeTextField: UITextField!
    @IBOutlet weak var receiptImageView: UIImageView!
    @IBOutlet weak var notesTextView: UITextView!
    
    var expense:Expense?
    let manager = LocalFileManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        noteTextView.layer.borderWidth = 1
        noteTextView.layer.borderColor = UIColor.black.cgColor
        print(self.expense!.imageLink)
        if let expense = self.expense {
            expenseDateTextField.text = expense.expenseDate
            amountTextField.text = String(expense.amount)
            expenseCategoryTextField.text = expense.category
            paymentTypeTextField.text = expense.paymentType
            descriptionTextView.text = expense.description
            if expense.imageLink != "nil"{
                receiptImageView.image = manager.getImage(identifier: expense.imageLink)
            }
            notesTextView.text = expense.notes
        }
        
    }
    

}
