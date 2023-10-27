
import Foundation
import UIKit
struct EmployeeData: Decodable {
    let data: [Details]
}
struct Details: Decodable {
    let first_name: String
    let last_name: String
    let email: String
    let avatar: String
}
struct User{
    var name: String
    var email: String
  //  var avatar: UIImage
    var imageURL: URL?
}
