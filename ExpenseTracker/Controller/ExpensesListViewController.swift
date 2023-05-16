//
//  ExpensesListViewController.swift
//  ExpenseTracker
//
//  Created by Cube on 5/6/23.
//

import UIKit
import Foundation

class ExpensesListViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var expensesTableView: UITableView!
    
    var db = DBManager()
    var expenses = Array<Expense>()
    
    let searchController = UISearchController()
    var filteredExpense:[Expense] = [Expense]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configuring the custom expense cell into the table veiw
        self.expensesTableView.register(UINib.init(nibName: "ExpenseTableCell", bundle: .main), forCellReuseIdentifier: "ExpenseTableCell")
        
        self.expensesTableView.delegate = self
        self.expensesTableView.dataSource = self
        
        initSearchController()
        
        expenses = db.read()
        
    }
    
    func initSearchController(){
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        searchController.searchBar.placeholder = "Search by expense date"
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
//        searchController.searchBar.scopeButtonTitles = ["All","First Quarter","Second Quarter","Third Quarter","Last Quarter"]
        searchController.searchBar.delegate = self
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        //let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!
        
        filterForSearchTextAndScopeButton(searchText: searchText)
    }
    
    func filterForSearchTextAndScopeButton(searchText:String){
        filteredExpense = expenses.filter
        {
            expense in
            let searchTextMatch:Bool
            if (searchController.searchBar.text != ""){
                searchTextMatch = expense.expenseDate.lowercased().contains(searchText.lowercased())
            }
            else
            {
                searchTextMatch = true
            }
            return searchTextMatch
        }
        print(searchController.isActive,filteredExpense)
        expensesTableView.reloadData()
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
        if (searchController.isActive){
            return filteredExpense.count
        }
        return expenses.count
    }
    
    func tableView(_ expensesTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("this is happening")
        let cell: ExpenseTableCell = expensesTableView.dequeueReusableCell(withIdentifier: "ExpenseTableCell", for: indexPath) as! ExpenseTableCell
        
        var thisExpense:Expense
        
        if (searchController.isActive){
            thisExpense = filteredExpense[indexPath.row]
        }
        else{
            thisExpense = expenses[indexPath.row]
        }
        
        cell.dateLabel.text = thisExpense.expenseDate
        cell.categoryLabel.text = thisExpense.category
        cell.amountLabel.text = thisExpense.amount.description
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "ExpenseDetailViewController") as? ExpenseDetailViewController {
            self.navigationController?.pushViewController(vc, animated: true)
            vc.expense = expenses[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath:IndexPath){
        if editingStyle == .delete {
            tableView.beginUpdates()
            db.deleteByID(id: expenses[indexPath.row].id)
            expenses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}


