//
//  ExpenseDetailViewController.swift
//  ExpenseTracker
//
//  Created by Yangru Guo on 15/5/2023.
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
    @IBOutlet weak var receiptImageViewLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var descriptionlabel: UILabel!
    @IBOutlet weak var backgroundPaneView: UIView!
    @IBOutlet weak var notesLabel: UILabel!
    
    var expense:Expense?
    let manager = LocalFileManager()
    var notesTextViewAppear = true
    var descriptionTextViewAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        backgroundPaneView.layer.cornerRadius = backgroundPaneView.frame.size.height / 40
        
        descriptionTextView.layer.borderWidth = 1

        noteTextView.layer.borderWidth = 1

        if let expense = self.expense {
            expenseDateTextField.text = expense.expenseDateString
            amountTextField.text = String(expense.amount)
            expenseCategoryTextField.text = expense.category
            paymentTypeTextField.text = expense.paymentType
            if expense.description == ""{
                descriptionTextView.removeFromSuperview()
                descriptionlabel.removeFromSuperview()
                descriptionTextViewAppear = false
            }else{
                descriptionTextView.text = expense.description
            }
            if expense.imageLink != "nil"{
                receiptImageView.image = manager.getImage(identifier: expense.imageLink)
            } else{
                receiptImageView.removeFromSuperview()
                receiptImageViewLabel.removeFromSuperview()
            }
            if expense.notes != ""{
                notesTextView.text = expense.notes
            } else{
                notesLabel.removeFromSuperview()
                notesTextView.removeFromSuperview()
                notesTextViewAppear = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if traitCollection.userInterfaceStyle == .light {
            if descriptionTextViewAppear{
                descriptionTextView.layer.borderColor = UIColor.black.cgColor
            }
            if notesTextViewAppear{
                noteTextView.layer.borderColor = UIColor.black.cgColor
            }
        } else{
            if descriptionTextViewAppear{
                descriptionTextView.layer.borderColor = UIColor.white.cgColor
            }
            if notesTextViewAppear{
                noteTextView.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
    

}
