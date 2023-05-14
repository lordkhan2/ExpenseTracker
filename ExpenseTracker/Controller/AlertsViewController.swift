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
        print("this is happening")
        let cell: AlertTableCell = expensesTableView.dequeueReusableCell(withIdentifier: "AlertTableCell", for: indexPath) as! AlertTableCell
        cell.alertDateLabel.text = alerts[indexPath.row].alertDate
        cell.alertAmountLabel.text = alerts[indexPath.row].amount.description
        cell.alertDescription.text = alerts[indexPath.row].description
        print(alerts[indexPath.row],description)
        cell.selectionStyle = .none
        return cell
    }
}
