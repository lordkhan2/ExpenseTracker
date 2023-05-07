//
//  Settings.swift
//  ExpenseTracker
//
//  Created by Cube on 5/1/23.
//

import UIKit

struct Section{
    let title: String
    let options:[SettingsOptionType]
}

//enlist all types of button
enum SettingsOptionType{
    case staticCell(model:SettingsOption)
}

// To be added if more types of button are needed
struct SettingsOption{
    let title:String
    let icon:UIImage?
    let iconBGColor:UIColor
    let handler:(() -> Void)
}


class SettingsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var settingTableView: UITableView!
    
    var models = [Section]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.id)
        configure()
    }
    func configure(){
        models.append(Section(title: "Expense Settings", options: [
            .staticCell(model:SettingsOption(title: "Fixed Cost and Income", icon: UIImage(systemName:"banknote"), iconBGColor: .systemYellow){
                //code to be added when user click the button
                print("Test: First cell has been selected")
            }),
            .staticCell(model:SettingsOption(title: "Edit Categories", icon: UIImage(systemName:"pencil"), iconBGColor: .systemBlue){
                //code to be added when user click the button
            })
        ])
        )
        
        models.append(Section(title: "Graph Settings", options: [
            .staticCell(model: SettingsOption(title: "Start Date of Month", icon: UIImage(systemName:"calendar"), iconBGColor: .systemGreen){
                //code to be added when user click the button
            }),
            .staticCell(model: SettingsOption(title: "Start Date of Week", icon: UIImage(systemName:"calendar"), iconBGColor: .systemGreen){
                //code to be added when user click the button
            }),
            .staticCell(model: SettingsOption(title: "Graph Settings", icon: UIImage(systemName:"chart.xyaxis.line"), iconBGColor: .systemGreen){
                //code to be added when user click the button
            })
        ])
        )
        
        models.append(Section(title: "General Settings", options: [
            .staticCell(model: SettingsOption(title: "Language", icon: UIImage(systemName:"text.bubble"), iconBGColor: .systemBlue){
                //code to be added when user click the button
            }),
            .staticCell(model: SettingsOption(title: "Currency", icon: UIImage(systemName:"dollarsign.arrow.circlepath"), iconBGColor: .systemRed){
                //code to be added when user click the button
            }),
            .staticCell(model: SettingsOption(title: "Reminder", icon: UIImage(systemName:"exclamationmark.bubble"), iconBGColor: .systemPink){
                //code to be added when user click the button
            })
        ])
        )
        
        models.append(Section(title: "Reporting Settings", options: [
            .staticCell(model: SettingsOption(title: "Yearly Report", icon: UIImage(systemName:"newspaper"), iconBGColor: .systemBlue){
                //code to be added when user click the button
            }),
            .staticCell(model: SettingsOption(title: "Yearly Category-wise Report", icon: UIImage(systemName:"newspaper"), iconBGColor: .systemBlue){
                //code to be added when user click the button
            }),
            .staticCell(model: SettingsOption(title: "Yearly Reporting Yearly Category-wise Report", icon: UIImage(systemName:"calendar.badge.clock"), iconBGColor: .systemBlue){
                //code to be added when user click the button
            }),
            .staticCell(model: SettingsOption(title: "Yearly Category-wise Report Yearly Category-wise Report", icon: UIImage(systemName:"calendar.badge.clock"), iconBGColor: .systemGreen){
                //code to be added when user click the button
            })
        ])
        )
        
        models.append(Section(title: "App Settings", options: [
            .staticCell(model: SettingsOption(title: "FAQ", icon: UIImage(systemName:"person.fill.questionmark"), iconBGColor: .systemBlue){
                //code to be added when user click the button
            }),
            .staticCell(model: SettingsOption(title: "About the App", icon: UIImage(systemName:"app"), iconBGColor: .systemGreen){
                //code to be added when user click the button
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
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let type = models[indexPath.section].options[indexPath.row]
        //to be added based on different types of cells
        switch type.self{
        case .staticCell(let model):
            model.handler()
        }
    }

}
