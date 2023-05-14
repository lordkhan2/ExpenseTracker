//
//  AlertTableCell.swift
//  ExpenseTracker
//
//  Created by Cube on 5/14/23.
//

import UIKit

class AlertTableCell: UITableViewCell {

    //This is for a custom cell for the Alerts List Table View - AlertTableCell.xib is the layout file
    @IBOutlet weak var alertDateLabel: UILabel!
    @IBOutlet weak var alertAmountLabel: UILabel!
    @IBOutlet weak var alertDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
