//
//  AddExpense.swift
//  ExpenseTracker
//
//  Created by Cube on 5/1/23.
//

import Foundation
import UIKit

class AddExpenseViewController : UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var paymentTypeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var recieptImageView: UIImageView!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var addExpenseButton: UIButton!
    
    var db = DBManager()
    
    let manager = LocalFileManager.fileManagerInstance
    
    let userDefault = UserDefaults.standard
    let RECEIPT_IMAGE_IDENTIFIER_KEY = "receiptImageIdentifier"
    let MONTHLY_EXPENSE_CAP_KEY = "MonthlyExpenseCap"
    
    let datePicker = UIDatePicker()
    var receiptImageIdentifier:Int = -1
    var expenses = Array<Expense>()
    
    var setCap: Double = 0.0
    var monthlyAmount: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatepicker()
        
        //initialize image view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        recieptImageView.isUserInteractionEnabled = true
        recieptImageView.addGestureRecognizer(tapGestureRecognizer)
        recieptImageView.backgroundColor = .systemGray
        
        //enable dismissing the keyboard when the user tapping the area outside the field
        let tapToHideKeyboardGesture = UITapGestureRecognizer(target: self.view, action:#selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapToHideKeyboardGesture)
        
        //Initializing delegates
        amountTextField.delegate = self
        categoryTextField.delegate = self
        paymentTypeTextField.delegate = self
        descriptionTextField.delegate = self
        notesTextField.delegate = self
        //initialize the image identifier each time when add expense view is switched to
        if let receiptImageIdentifier = userDefault.value(forKey: RECEIPT_IMAGE_IDENTIFIER_KEY) as? Data {
            self.receiptImageIdentifier = try! PropertyListDecoder().decode(Int.self,from: receiptImageIdentifier)
        } else{
            self.receiptImageIdentifier = 0
        }
    }
    
    //enable dismissing the keyboard by tapping return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //Creating a toolbar to handle the view for datepicker
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        return toolbar
    }
    
    //Datepicket function
    func createDatepicker(){
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = createToolbar()
    }
    
    //Function to show necessary steps to take once done is pressed after date has been picked
    @objc func donePressed(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        self.dateTextField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
        
        //check date is no later than today

        guard dateFormatter.date(from: self.dateTextField.text!)! <= Date() else{
            let dialogMessage = UIAlertController(title: "Wrong Date Alert", message: "The expense date should not later than today! Please check...", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
             })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
            self.dateTextField.text = nil
            return
        }
    }

    //Button click event to add all data from form into database
    @IBAction func AddExpense(_ sender: Any) {
        let expenseDate = dateTextField.text ?? ""
        let expenseAmount = Double(amountTextField.text ?? "0") ?? 0.0
        let expenseCategory = categoryTextField.text ?? ""
        let expensePaymentType = paymentTypeTextField.text ?? ""
        let expenseDescription = descriptionTextField.text ?? ""
        let expenseRecieptImage:String
        let expenseNotes = notesTextField.text ?? ""

        //empty field check
        guard !dateTextField.text!.isEmpty && !amountTextField.text!.isEmpty && !categoryTextField.text!.isEmpty && !paymentTypeTextField.text!.isEmpty else{
            let dialogMessage = UIAlertController(title: "Empty Fields Alert", message: "Required fields cannot be empty! Please check...", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
             })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
            return
        }

        //check expense is a two decimal number
        guard isTwoDecimalNumber(testStr: amountTextField.text!) else{
            let dialogMessage = UIAlertController(title: "Wrong Amount", message: "The expense must be a number with up to two decimal places!Please check...", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
             })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
            return
        }

        //only save image and update identifier if user has taken a photo
        if let recieptImage = recieptImageView.image {
            //for data storage guideline, refer to https://developer.apple.com/documentation/foundation/optimizing_your_app_s_data_for_icloud_backup/index.html
            //the image is user generated but cannot be re-generated or downloaded. This image should be saved in <Application_Home>/Documents directory so that it can be backed up to the icloud automatically.
            //save image file manager return the url and assign to a global variable.
            manager.saveImage(image: recieptImage, identifier: String(receiptImageIdentifier))
            expenseRecieptImage = String(receiptImageIdentifier)
            //update image identifer
            receiptImageIdentifier += 1
            //update the latest usable identifier to the user default
            userDefault.setValue(try? PropertyListEncoder().encode(receiptImageIdentifier), forKey: RECEIPT_IMAGE_IDENTIFIER_KEY)
        } else{
            expenseRecieptImage = "nil"
        }

        db.insert(expenseDate: expenseDate, amount: expenseAmount, category: expenseCategory, paymentType: expensePaymentType, description: expenseDescription, imageLink: expenseRecieptImage, notes: expenseNotes)
        
        expenses = db.read()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let stringDate = dateFormatter.string(from: date)
        let components = stringDate.components(separatedBy: " ")
        let month = components[0]
        let year = components[2]
        
        //Looping the 2D expense array to find expenses in the current month and adding the amounts to the monthly amount variable
        monthlyAmount = 0.0
        for expense in expenses{
            if(expense.expenseDate.contains(month) && expense.expenseDate.contains(year))
            {

                monthlyAmount += expense.amount
            }
        }
        
        //Getting acccess to the cap record value in User Defaults
        if let monthlyCapRecord = self.userDefault.value(forKey: self.MONTHLY_EXPENSE_CAP_KEY) as? Data{
            let expenseCapRecord = try! PropertyListDecoder().decode(ExpenseCap.self,from: monthlyCapRecord)
            setCap = expenseCapRecord.monthlyCapAmount
        }
        
        //Checking if current monthly expense amount has breached the threshold set by User, if so sending an alert.
        let difference = setCap - monthlyAmount
        
        if( difference < 100 && difference >= 0)
        {
            let alertDate = stringDate
            let amount = monthlyAmount
            let description = "Your Monthly Expense is almost surpassing the limit set. Currently $\(setCap-monthlyAmount) is left. Please expend carefully."
            db.insertAlert(alertDate: alertDate, amount: amount, description: description)
        }
        else if (difference < 0) {
            let alertDate = stringDate
            let amount = monthlyAmount
            let description = "Your Monthly Expense has surpassed the set cap. Currently you have exceed your expense by $\(-difference) Please expend carefully."
            db.insertAlert(alertDate: alertDate, amount: amount, description: description)
        }
        
        //open a dialog alert to inform the user the item has been added
        let dialogMessage = UIAlertController(title: "Expense Item Added", message: "Expense item has been added, tap ok to continue", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in

         })
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
        
        resetAllViewItems()
    }
    
    //Function to activate camera when image view is tapped
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    //Function to handle tapping cancel button
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController){
        picker.dismiss(animated:true, completion: nil)
    }
    
    //Function to retrieve the image and put it in the editor to allow the user to do some basic editing (crop, etc) and then return the edited photo to the image view
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true,completion: nil)
        guard let receiptImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        recieptImageView.image = receiptImage
    }
    
    //Function to reset all elements of the view once an expense is added
    func resetAllViewItems(){
        dateTextField.text = nil
        amountTextField.text = nil
        categoryTextField.text = nil
        paymentTypeTextField.text = nil
        descriptionTextField.text = nil
        recieptImageView.image = nil
        notesTextField.text = nil
    }
    
    //Validation to check if amount has 2 decimal place (e.g $20.00)
    func isTwoDecimalNumber(testStr:String) -> Bool {
        return testStr.range(of: "^[0-9]+(?:.[0-9]{1,2})?$",options: .regularExpression, range: nil,locale: nil) != nil
    }
}
