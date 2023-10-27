//
//  EmployeeTableViewCell.swift
//  ReqresEmployee
//
//  Created by Abhishek-Sreejith on 16/08/23.
//
import UIKit
class EmployeeTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
