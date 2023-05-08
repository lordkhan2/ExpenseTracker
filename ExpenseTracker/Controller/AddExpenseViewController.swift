//
//  AddExpense.swift
//  ExpenseTracker
//
//  Created by Cube on 5/1/23.
//

import Foundation
import UIKit

class AddExpenseViewController : UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

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
    let manager = LocalFileManager.fileManagerInstance
    let userDefault = UserDefaults.standard
    var receiptImageIdentifier:Int = -1
    let RECEIPT_IMAGE_IDENTIFIER_KEY = "receiptImageIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatepicker()
        // Do any additional setup after loading the view.
        //initialize image view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        recieptImageView.isUserInteractionEnabled = true
        recieptImageView.addGestureRecognizer(tapGestureRecognizer)
        recieptImageView.backgroundColor = .systemGray
        
        //initialize the image identifier each time when add expense view is switched to
        if let receiptImageIdentifier = userDefault.value(forKey: RECEIPT_IMAGE_IDENTIFIER_KEY) as? Data {
            self.receiptImageIdentifier = try! PropertyListDecoder().decode(Int.self,from: receiptImageIdentifier)
        } else{
            self.receiptImageIdentifier = 0
        }
        
        print(receiptImageIdentifier)
        //recieptImageView.image = manager.getImage(identifier: "0")
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
        
        print("| EZPROGAMER \(expenseDate)| \(expenseAmount)| \(expenseCategory)| \(expensePaymentType)| \(expenseDescription)| \(expenseRecieptImage)| \(expenseNotes)")
        
        db.insert(expenseDate: expenseDate, amount: expenseAmount, category: expenseCategory, paymentType: expensePaymentType, description: expenseDescription, imageLink: expenseRecieptImage, notes: expenseNotes)
        
        //open a dialog alert to inform the user the item has been added
        var dialogMessage = UIAlertController(title: "Expense Item Added", message: "Expense item has been added, tap ok to continue", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
         })
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
        resetAllViewItems()
        print(receiptImageIdentifier)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //_ = tapGestureRecognizer.view as! UIImageView
        // Your action
        print("View Tapped")
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController){
        picker.dismiss(animated:true, completion: nil)
    }
    
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true,completion: nil)
        guard let receiptImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        recieptImageView.image = receiptImage
    }
    
    func resetAllViewItems(){
        dateTextField.text = nil
        amountTextField.text = nil
        categoryTextField.text = nil
        paymentTypeTextField.text = nil
        descriptionTextField.text = nil
        recieptImageView.image = nil
        notesTextField.text = nil
    }
}
