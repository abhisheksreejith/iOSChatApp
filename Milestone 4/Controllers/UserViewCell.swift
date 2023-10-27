//
//  UserViewCell.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 03/10/23.
//
import UIKit
class UserViewCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var chatView: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.contentMode = .scaleAspectFill
        userImage.tintColor = .darkGray
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
