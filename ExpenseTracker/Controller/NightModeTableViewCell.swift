//
//  SettingTableViewCell.swift
//  ExpenseTracker
//
//  Created by Yangru Guo on 7/5/2023.
//

import UIKit

class NightModeTableViewCell: UITableViewCell {

    static let id = "NightModeTableViewCell"
    let bufferSize = 10
    
    private let iconContainer:UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let iconImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let nightModeSwitch:UISwitch = {
        let nightModeSwitch = UISwitch()
        nightModeSwitch.onTintColor = .systemBlue
        return nightModeSwitch
    }()
    
    override init(style:UITableViewCell.CellStyle, reuseIdentifier:String?){
        super.init(style:style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconContainer)
        nightModeSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        contentView.addSubview(nightModeSwitch)
        iconContainer.addSubview(iconImageView)
        
        contentView.clipsToBounds = true
        accessoryType = .none
    }
    
    @objc func switchChanged(_ sender:UISwitch){
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }
        if traitCollection.userInterfaceStyle == .light {
            if sender.isOn{
                window?.overrideUserInterfaceStyle = .dark
            }
        } else{
            if !(sender.isOn){
                window?.overrideUserInterfaceStyle = .light
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.frame.size.height - 12
        iconContainer.frame = CGRect(x: 15, y: 6, width: size, height: size)
        let imageSize = size * (2/3)
        iconImageView.frame = CGRect(x: (size - imageSize) * 0.5, y: (size - imageSize) * 0.5, width: imageSize, height: imageSize)
        nightModeSwitch.sizeToFit()
        nightModeSwitch.frame = CGRect(x: contentView.frame.size.width - nightModeSwitch.frame.size.width - CGFloat(bufferSize), y: (contentView.frame.size.height - nightModeSwitch.frame.size.height)/2, width: nightModeSwitch.frame.width, height: nightModeSwitch.frame.height)
        label.frame = CGRect(
            x: 25 + iconContainer.frame.size.width,
            y: 0,
            width: contentView.frame.size.width - 20 - iconContainer.frame.size.width,
            height: contentView.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        iconContainer.backgroundColor = nil
        label.text = nil
        nightModeSwitch.isOn = false
    }
    
    public func configure(with model:SettingsSwitchOption){
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBGColor
        nightModeSwitch.isOn = model.isOn
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
