//
//  ExpenseTableCell.swift
//  ExpenseTracker
//
//  Created by Cube on 5/7/23.
//

import UIKit

class ExpenseTableCell: UITableViewCell {

    //This is for a custom cell for the Expense List Table View - ExpenseTableCell.xib is the layout file
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var expenseTableCellBGView: UIView!
    
    @IBOutlet weak var categoryImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        expenseTableCellBGView.layer.cornerRadius = expenseTableCellBGView.frame.size.height / 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func expenseCategoryImage(expenseCategory:String){
        switch expenseCategory{
        case "Food & Dining":
            categoryImageView.image = UIImage(systemName: "fork.knife")
        case "Transportation":
            categoryImageView.image = UIImage(systemName: "car.2.fill")
        case "Utilities":
            categoryImageView.image = UIImage(systemName: "lightbulb.2")
        case "Housing":
            categoryImageView.image = UIImage(systemName: "house.circle")
        case "Entertainment":
            categoryImageView.image = UIImage(systemName: "gamecontroller")
        case "Health & Wellness":
            categoryImageView.image = UIImage(systemName: "figure.cooldown")
        case "Personal Care":
            categoryImageView.image = UIImage(systemName: "shower")
        case "Travel":
            categoryImageView.image = UIImage(systemName: "airplane.departure")
        case "Shopping":
            categoryImageView.image = UIImage(systemName: "cart")
        case "Education":
            categoryImageView.image = UIImage(systemName: "books.vertical")
        case "Debt Payments":
            categoryImageView.image = UIImage(systemName: "dollarsign.circle")
        case "Gifts & Donations":
            categoryImageView.image = UIImage(systemName: "gift")
        case "Business":
            categoryImageView.image = UIImage(systemName: "suitcase")
        case "Groceries":
            categoryImageView.image = UIImage(systemName: "carrot")
        case "Transfer Payments":
            categoryImageView.image = UIImage(systemName: "banknote")
        case "Miscellaneous":
            categoryImageView.image = UIImage(systemName: "newspaper")
        default:
            print("Error:No category detected")
        }
        
    }
    
}
