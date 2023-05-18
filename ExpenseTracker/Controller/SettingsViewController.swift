//
//  Settings.swift
//  ExpenseTracker
//
//  Created by Cube on 5/1/23.
//

import UIKit

struct ExpenseCap:Codable{
    var monthlyCapAmount:Double
}

struct Section{
    let title: String
    let options:[SettingsOptionType]
}

//enlist all types of button
enum SettingsOptionType{
    case staticCell(model:SettingsOption)
    case switchCell(model:SettingsSwitchOption)
}

// To be added if more types of button are needed
struct SettingsOption{
    let title:String
    let icon:UIImage?
    let iconBGColor:UIColor
    let handler:(() -> Void)
}

struct SettingsSwitchOption{
    let title:String
    let icon:UIImage?
    let iconBGColor:UIColor
    let handler:(() -> Void)
    var isOn:Bool
}


class SettingsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var settingTableView: UITableView!
    @IBOutlet var settingMonthlyAlertView: UIView!
    
    @IBOutlet var blurBackgroundView: UIVisualEffectView!
    @IBOutlet weak var capAmountTextField: UITextField!
    
    var models = [Section]()
    let MONTHLY_EXPENSE_CAP_KEY = "MonthlyExpenseCap"
    let userDefault = UserDefaults.standard
    var popUpViewAppear:Bool = false
    var nightModeOn:Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.id)
        settingTableView.register(NightModeTableViewCell.self, forCellReuseIdentifier: NightModeTableViewCell.id)
        
        configure()

        //monthly expense cap alert subview to be shown once click alert button
        capAmountTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.blurBackgroundView.bounds = self.view.bounds
        blurBackgroundView.center = self.view.center
        self.settingMonthlyAlertView.center = self.view.center
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func configure(){
        models.append(Section(title: "General Settings", options: [
            .switchCell(model: SettingsSwitchOption(title:"Night Mode",icon:UIImage(systemName: "airplane"),iconBGColor: .systemRed,handler:{
                if self.nightModeOn == false{
                    self.nightModeOn = true
                } else{
                    self.nightModeOn = false
                }
                let connectedScenes = UIApplication.shared.connectedScenes
                    .filter { $0.activationState == .foregroundActive }
                    .compactMap { $0 as? UIWindowScene }
                
                let window = connectedScenes.first?
                    .windows
                    .first { $0.isKeyWindow }
                if self.nightModeOn {
                    window?.overrideUserInterfaceStyle = .dark
                } else{
                    window?.overrideUserInterfaceStyle = .light
                }
            },isOn:false)),
            .staticCell(model: SettingsOption(title: "Reminder", icon: UIImage(systemName:"exclamationmark.bubble"), iconBGColor: .systemPink){
                //code to be added when user click the button
                self.blurBackgroundView.bounds = self.view.bounds
                self.settingMonthlyAlertView.bounds = CGRect(x: 0, y: 0, width: 310, height: 192)
                self.animateViewIn(targetView: self.blurBackgroundView)
                self.animateViewIn(targetView: self.settingMonthlyAlertView)
                //if the user previously set a cap, retrive the cap amount and render to the relevant textfield
                if let monthlyCapRecord = self.userDefault.value(forKey: self.MONTHLY_EXPENSE_CAP_KEY) as? Data{
                    let expenseCapRecord = try! PropertyListDecoder().decode(ExpenseCap.self,from: monthlyCapRecord)
                    self.capAmountTextField.text = String(expenseCapRecord.monthlyCapAmount)
                }
            })
        ])
        )
        
        models.append(Section(title: "App Settings", options: [
            .staticCell(model: SettingsOption(title: "FAQ", icon: UIImage(systemName:"person.fill.questionmark"), iconBGColor: .systemBlue){
                //code to be added when user click the button
                self.performSegue(withIdentifier: "ToFAQController", sender: Any?.self)
            }),
            .staticCell(model: SettingsOption(title: "About the App", icon: UIImage(systemName:"app"), iconBGColor: .systemGreen){
                //code to be added when user click the button
                self.performSegue(withIdentifier: "ToAboutApp", sender: Any?.self)
            })
        ])
        )
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int{
        return models[section].options.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        //configure based on different type of cells
        switch model.self{
        case .staticCell(let model):
            guard let cell  = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.id, for:indexPath) as? SettingTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        case .switchCell(let model):
            guard let cell  = tableView.dequeueReusableCell(withIdentifier: NightModeTableViewCell.id, for:indexPath) as? NightModeTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let type = models[indexPath.section].options[indexPath.row]
        //to be added based on different types of cells
        switch type.self{
        case .staticCell(let model):
            model.handler()
        case .switchCell(let model):
            model.handler()
        }
    }
    
    func animateViewIn(targetView:UIView){
        let bgView = self.view!
        
        bgView.addSubview(targetView)
        
        //view scalling to be 120%
        targetView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        targetView.alpha = 0
        targetView.center = bgView.center
        
        //animate the view
        UIView.animate(withDuration: 0.3, animations:{
            targetView.transform = CGAffineTransform(scaleX: 1, y: 1)
            targetView.alpha = 1
        }
        )
        
        popUpViewAppear = true
    }
    
    func animateViewOut(targetView:UIView){
        UIView.animate(withDuration: 0.3, animations:{
            targetView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            targetView.alpha = 0
        }, completion: {_ in
            targetView.removeFromSuperview()
        }
        )
        
        popUpViewAppear = false
    }
    
    @IBAction func pressAlertConfirmButton(_ sender: Any) {
        //check empty field
        guard !capAmountTextField.text!.isEmpty else {
            let dialogMessage = UIAlertController(title: "Empty Fields Alert", message: "Required fields cannot be empty! Please check...", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
             })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
            return
        }
        //check two decimal number
        guard isTwoDecimalNumber(testStr: capAmountTextField.text!) else{
            let dialogMessage = UIAlertController(title: "Wrong Amount", message: "The amount must be a number with up to two decimal places!Please check...", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
             })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
            return
        }
        //setting monthly cap to local user defaults
        let newExpenseCap = ExpenseCap(monthlyCapAmount: Double(capAmountTextField.text!)!)
        userDefault.setValue(try? PropertyListEncoder().encode(newExpenseCap), forKey: MONTHLY_EXPENSE_CAP_KEY)

        //open a dialog alert to inform the user the cap has been set
        let dialogMessage = UIAlertController(title: "Expense Cap Set", message: "Expense cap has been set, tap ok to continue", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
         })
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
        self.animateViewOut(targetView: self.blurBackgroundView)
        self.animateViewOut(targetView: self.settingMonthlyAlertView)
    }
    
    @IBAction func cancelCapAmount(_ sender: Any) {
        self.animateViewOut(targetView: self.settingMonthlyAlertView)
        self.animateViewOut(targetView: self.blurBackgroundView)
    }
    func isTwoDecimalNumber(testStr:String) -> Bool {
        return testStr.range(of: "^[0-9]+(?:.[0-9]{1,2})?$",options: .regularExpression, range: nil,locale: nil) != nil
    }
    
}
