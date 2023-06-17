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
    
    @IBOutlet weak var alertLevelImageView: UIImageView!
    @IBOutlet weak var alertBubbleView: UIView!
    @IBOutlet weak var dateImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateImageView.image = UIImage(systemName: "calendar")
        dateImageView.tintColor = .white
        alertBubbleView.layer.cornerRadius = alertBubbleView.frame.size.height / 20
        alertBubbleView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.8)
        alertLevelImageView.image = UIImage(systemName: "eye.trianglebadge.exclamationmark")
        alertLevelImageView.tintColor = .systemPink.withAlphaComponent(1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
