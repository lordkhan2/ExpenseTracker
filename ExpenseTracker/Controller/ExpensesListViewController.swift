//
//  ExpensesListViewController.swift
//  ExpenseTracker
//
//  Created by Cube on 5/6/23.
//

import UIKit
import Foundation

class ExpensesListViewController: UIViewController {
    
    @IBOutlet weak var expensesTableView: UITableView!
    
    var db = DBManager()
    var expenses = Array<Expense>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configuring the custom expense cell into the table veiw
        self.expensesTableView.register(UINib.init(nibName: "ExpenseTableCell", bundle: .main), forCellReuseIdentifier: "ExpenseTableCell")
        
        self.expensesTableView.delegate = self
        self.expensesTableView.dataSource = self
        
        expenses = db.read()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        expenses = db.read()
        self.expensesTableView.reloadData()
       
    }
}

extension ExpensesListViewController: UITableViewDelegate {
    
    func tableView(_ expensesTableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ExpensesListViewController: UITableViewDataSource {
    func tableView(_ expensesTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ expensesTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("this is happening")
        let cell: ExpenseTableCell = expensesTableView.dequeueReusableCell(withIdentifier: "ExpenseTableCell", for: indexPath) as! ExpenseTableCell
        cell.dateLabel.text = expenses[indexPath.row].expenseDate
        cell.categoryLabel.text = expenses[indexPath.row].category
        cell.amountLabel.text = expenses[indexPath.row].amount.description
        
        cell.selectionStyle = .none
        return cell
    }
}


