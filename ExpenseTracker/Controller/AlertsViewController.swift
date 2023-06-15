//
//  Alerts.swift
//  ExpenseTracker
//
//  Created by Cube on 5/1/23.
//

import UIKit

class AlertsViewController: UIViewController {

    @IBOutlet weak var alertTable: UITableView!
    
    var db = DBManager()
    var alerts = Array<Alert>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configuring the custom expense cell into the table veiw
        self.alertTable.register(UINib.init(nibName: "AlertTableCell", bundle: .main), forCellReuseIdentifier: "AlertTableCell")
        
        self.alertTable.delegate = self
        self.alertTable.dataSource = self
        
        alerts = db.readAlerts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alerts = db.readAlerts()
        self.alertTable.reloadData()
    }
}

extension AlertsViewController: UITableViewDelegate {
    
    func tableView(_ alertTable: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension AlertsViewController: UITableViewDataSource {
    func tableView(_ alertTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }
    
    func tableView(_ expensesTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AlertTableCell = expensesTableView.dequeueReusableCell(withIdentifier: "AlertTableCell", for: indexPath) as! AlertTableCell
        cell.alertDateLabel.text = alerts[indexPath.row].alertDate
        cell.alertDescription.text = "You have spent $\(alerts[indexPath.row].amount.description) this Month." + alerts[indexPath.row].description
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath:IndexPath){
        if editingStyle == .delete {
            tableView.beginUpdates()
            db.deleteAlertByID(id: alerts[indexPath.row].id)
            alerts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}
