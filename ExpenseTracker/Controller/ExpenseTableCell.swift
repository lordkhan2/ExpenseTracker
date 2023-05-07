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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
