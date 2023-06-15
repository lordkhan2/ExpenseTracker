//
//  AddExpense.swift
//  ExpenseTracker
//
//  Created by Cube on 5/1/23.
//

import Foundation
import UIKit
import UserNotifications

//ML Technics
import CoreImage
import VisionKit
import Vision
import CoreML

class AddExpenseViewController : UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate, VNDocumentCameraViewControllerDelegate {
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var paymentTypeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var recieptImageView: UIImageView!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var addExpenseButton: UIButton!
    @IBOutlet weak var resetImageButton: UIButton!
    
    var db = DBManager()
    
    let manager = LocalFileManager.fileManagerInstance
    
    let userDefault = UserDefaults.standard
    let alertDefault: Void = UserDefaults.standard.set("", forKey: "capAlertOption")
    
    let RECEIPT_IMAGE_IDENTIFIER_KEY = "receiptImageIdentifier"
    let MONTHLY_EXPENSE_CAP_KEY = "MonthlyExpenseCap"
    
    let datePicker = UIDatePicker()
    
    let paymentTypePicker = UIPickerView()
    var paymentTyplePickerOptions = ["","Card","Cash","Gift Card","Voucher","Bank Transfer","Cheque", "Digital Wallet","Other"]
    
    let categoryPicker = UIPickerView()
    let categoryPickerOptions:[String] = ["","Food & Dining", "Transportation", "Utilities", "Housing", "Entertainment", "Health & Wellness", "Personal Care", "Travel", "Shopping", "Education", "Debt Payments", "Gifts & Donations", "Miscellaneous","Business","Groceries","Transfer Payments","Other"]
    
    var receiptImageIdentifier:Int = -1
    var expenses = Array<Expense>()
    var imageTaken = false
    
    var setCap: Double = 0.0
    var monthlyAmount: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatepicker()
        
        //payment type picker view
        paymentTypePicker.delegate = self
        paymentTypePicker.dataSource = self
        paymentTypeTextField.inputView = paymentTypePicker
        
        //
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryTextField.inputView = categoryPicker
        
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
        dateFormatter.dateFormat = "d MMM yyyy"
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
    
    //Clear image when button pressed
    
    @IBAction func resetImageButtonPressed(_ sender: Any) {
        recieptImageView.image = UIImage(named: "Tap To Add")
        imageTaken = false
        resetImageButton.isHidden = true
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
        
        let datahandler = ChartDataHandler()
        let timeTuple = datahandler.getCurrentMonthAndYear()
        let month = timeTuple.0
        let year = timeTuple.1
        let stringDate = timeTuple.2
        
        //Looping the 2D expense array to find expenses in the current month and adding the amounts to the monthly amount variable
        monthlyAmount = 0.0
        for expense in expenses{
            if(expense.expenseDateString.contains(month) && expense.expenseDateString.contains(year))
            {
                monthlyAmount += expense.amount
            }
        }
        
        //Getting acccess to the cap record value in User Defaults
        if let monthlyCapRecord = self.userDefault.value(forKey: self.MONTHLY_EXPENSE_CAP_KEY) as? Data{
            let expenseCapRecord = try! PropertyListDecoder().decode(ExpenseCap.self,from: monthlyCapRecord)
            setCap = expenseCapRecord.monthlyCapAmount
        }
        
        if setCap > 0 {
            //Checking if current monthly expense amount has breached the threshold set by User, if so sending an alert.
            let difference = Double(round((setCap - monthlyAmount*100)/100))
            
            if( difference < 100 && difference >= 0)
            {
                print("The difference is between 0 and 100")
                let alertDate = stringDate
                let amount = monthlyAmount
                let description = "Your Monthly Expense is almost surpassing the $\(setCap) limit set. Currently $\(setCap-monthlyAmount) is left. Please expend carefully."
                checkForPermission(title: "Expense Threshold Update", body: description)
                db.insertAlert(alertDate: alertDate, amount: amount, description: description)
            }
            
            else if (difference < 0) {
                print("The difference is less than 0 or negative")
                if (-difference > 500)
                {
                    print("The -difference is more than $500")
                    let getCap = UserDefaults.standard.string(forKey: "capAlertOption")
                    capLogic: if (getCap == "")
                    {
                        print("The user has not said anything yet")
                        let alertDate = stringDate
                        let amount = monthlyAmount
                        let description = "Your Monthly Expense has surpassed the set $\(setCap) cap. Currently you have exceed your expense by $\(-difference) Please expend carefully."
                        checkForPermission(title: "Expense Threshold Surpassed", body: description)
                        db.insertAlert(alertDate: alertDate, amount: amount, description: description)
                        
                        let capAlert = UIAlertController(title: "Expense Cap Alerts", message: "Do you want to continue receiving alerts?", preferredStyle: UIAlertController.Style.alert)

                        capAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                            UserDefaults.standard.set("Yes", forKey: "capAlertOption")
                        }))

                        capAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                            UserDefaults.standard.set("No", forKey: "capAlertOption")
                        }))

                        present(capAlert, animated: true, completion: nil)
                    }
                    else if ( getCap == "Yes")
                    {
                        print("The user said NO to prompt, they want to keep receiving alerts.")
                        let alertDate = stringDate
                        let amount = monthlyAmount
                        let description = "Your Monthly Expense has surpassed the set $\(setCap) cap. Currently you have exceed your expense by $\(-difference) Please expend carefully."
                        checkForPermission(title: "Expense Threshold Surpassed", body: description)
                        db.insertAlert(alertDate: alertDate, amount: amount, description: description)
                    }
                    else
                    {
                        print("The user said YES to the prompt, they don't want any more alerts")
                        break capLogic
                    }
                }
                else
                {
                    print("-difference is still less than $500")
                    let alertDate = stringDate
                    let amount = monthlyAmount
                    let description = "Your Monthly Expense has surpassed the set $\(setCap) cap. Currently you have exceed your expense by $\(-difference) Please expend carefully."
                    checkForPermission(title: "Expense Threshold Surpassed", body: description)
                    db.insertAlert(alertDate: alertDate, amount: amount, description: description)
                }
            }
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
        //**start processing image
        let ciImage = CIImage(cgImage: receiptImage.cgImage!)
        var requestHandler = VNImageRequestHandler(ciImage: ciImage)
        let documentDetectionRequest = VNDetectDocumentSegmentationRequest()
        var recognizedString = ""
        do {try requestHandler.perform([documentDetectionRequest])} catch{print(error)}
        guard let document = documentDetectionRequest.results?.first,
              let documentImage = perspectiveCorrectedImage(from:ciImage,rectangleObservation:document) else {
            fatalError("Unable to get document image.")
        }
        recieptImageView.image = UIImage(ciImage: documentImage)
        imageTaken = true
        resetImageButton.isHidden = false
        
        //
        var receiptRegexHandler = ReceiptRegexHandler()
        //text detection
        requestHandler = VNImageRequestHandler(ciImage: documentImage)
        let ocrRequest = VNRecognizeTextRequest{request, error in
            guard let textBlocks = request.results as? [VNRecognizedTextObservation] else {return}
            for textObservation in textBlocks{
                let topCandidate = textObservation.topCandidates(1)
                if let recognizedText = topCandidate.first {
                    receiptRegexHandler.recordRecognizedInformation(sourceString: recognizedText.string)
                    recognizedString += recognizedText.string
                    //print(recognizedText.string)
                }
            }
        }
        ocrRequest.recognitionLevel = .accurate
        try? requestHandler.perform([ocrRequest])
        dateTextField.text = receiptRegexHandler.expenseDate
        amountTextField.text = receiptRegexHandler.amount
    }
    
    //**ML function
    public func perspectiveCorrectedImage(from inputImage: CIImage, rectangleObservation: VNRectangleObservation ) -> CIImage? {
        let imageSize = inputImage.extent.size
        
        // Verify detected rectangle is valid.
        let boundingBox = rectangleObservation.boundingBox.scaled(to: imageSize)
        guard inputImage.extent.contains(boundingBox)
        else { print("invalid detected rectangle"); return nil}
        
        // Rectify the detected image and reduce it to inverted grayscale for applying model.
        let topLeft = rectangleObservation.topLeft.scaled(to: imageSize)
        let topRight = rectangleObservation.topRight.scaled(to: imageSize)
        let bottomLeft = rectangleObservation.bottomLeft.scaled(to: imageSize)
        let bottomRight = rectangleObservation.bottomRight.scaled(to: imageSize)
        let correctedImage = inputImage
            .cropped(to: boundingBox)
            .applyingFilter("CIPerspectiveCorrection", parameters: [
                "inputTopLeft": CIVector(cgPoint: topLeft),
                "inputTopRight": CIVector(cgPoint: topRight),
                "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                "inputBottomRight": CIVector(cgPoint: bottomRight)
            ])
        return correctedImage
    }
    
    //**ML Function block
    
    //Function to reset all elements of the view once an expense is added
    func resetAllViewItems(){
        dateTextField.text = nil
        amountTextField.text = nil
        categoryTextField.text = nil
        paymentTypeTextField.text = nil
        descriptionTextField.text = nil
        recieptImageView.image = UIImage(named:"Tap To Add")
        notesTextField.text = nil
        imageTaken = false
        resetImageButton.isHidden = true
        categoryPicker.selectRow(0, inComponent: 0, animated: true)
        paymentTypePicker.selectRow(0, inComponent: 0, animated: true)
    }
    
    //Validation to check if amount has 2 decimal place (e.g $20.00)
    //It checks the settings to see if authorization is provided, if not it will ask for permissioj.
    //If authorization already exisits, it will run the dispatchNotication() function, if authorization is available. After asking for permission, if granted, will call dispatchNotification, it not, will return.
    func isTwoDecimalNumber(testStr:String) -> Bool {
        return testStr.range(of: "^[0-9]+(?:.[0-9]{1,2})?$",options: .regularExpression, range: nil,locale: nil) != nil
    }
    // Function to check for notification permissions and carry out actions accordingly
    func checkForPermission(title: String, body: String){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings{ settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatchNotification(title: title, body: body)
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        self.dispatchNotification(title: title, body: body)
                    }
                }
            default:
                return
            }
        }
    }
    
    // Function to create and dispatch a push otification
    // This function is called and used in the checkPermission function
    // The hour and the minute variable are retrieved from the current date/time of the system and used to trigger the notification (in this case, 1 minute + the current minute) These are supplied into the dateComponents which in turn is supplied into the UNCalendarNotificationTrigger(an event that triggers the notification based on the date/time supplied)
    func dispatchNotification(title: String, body: String){
        //let identifier = "expense-tracker-notification"
        let title = title
        let body = body
        let hour = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.minute, from: Date())
        let second = Calendar.current.component(.second, from: Date()) + 10
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        let uuid = UUID().uuidString
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        notificationCenter.add(request)
        
    }
}

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
}
extension CGRect {
    func scaled(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: self.size.width * size.width,
            height: self.size.height * size.height
        )
    }
}

extension AddExpenseViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView:UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView:UIPickerView, numberOfRowsInComponent component:Int ) -> Int{
        if pickerView == categoryPicker {
            return categoryPickerOptions.count
        } else{
            return paymentTyplePickerOptions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker{
            return categoryPickerOptions[row]
        } else{
            return paymentTyplePickerOptions[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPicker{
            categoryTextField.text = categoryPickerOptions[row]
            categoryTextField.resignFirstResponder()
        }else{
            paymentTypeTextField.text = paymentTyplePickerOptions[row]
            paymentTypeTextField.resignFirstResponder()
        }
    }
}

