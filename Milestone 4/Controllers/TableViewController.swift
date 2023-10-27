//
//  TableViewController.swift
//  Employees
//
//  Created by Abhishek-Sreejith on 18/08/23.
//
import Foundation
import UIKit
import SkeletonView
import FirebaseFirestore
import FirebaseAuth
class TableViewController: UIViewController {
    @IBOutlet var employeeTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var users = [Details]()
    var filteredUsers = [Details]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        employeeTableView.delegate = self
        employeeTableView.dataSource = self
        searchBar.delegate = self
        employeeTableView.rowHeight = 70
        employeeTableView.isSkeletonable = true
        employeeTableView.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .gray), animation: nil, transition: .crossDissolve(0.25))
        performRequest()
        filteredUsers = users
        employeeTableView.reloadData()
    }
    func performRequest() {
        if let url = URL(string: "https://reqres.in/api/users?per_page=13") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if error != nil {
                    return
                }
                if let safeData = data {
                    // print(String(data: safeData, encoding: .utf8))
                    if self.parseJSON(safeData) != nil {
                        // print(employee)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.employeeTableView.reloadData()
                            self.employeeTableView.stopSkeletonAnimation()
                            self.view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                        }
                    }
                }
            }
            task.resume()
        }
    }
    func parseJSON(_ employeeData: Data) -> [Details]? {
        let decorder = JSONDecoder()
        do {
            let decodedData = try decorder.decode(EmployeeData.self, from: employeeData)
            for item in decodedData.data {
                let fname = item.first_name
                let lname = item.last_name
                let avatar = item.avatar
                let email = item.email
                users.append(Details(first_name: fname, last_name: lname, email: email, avatar: avatar))
            }
            filteredUsers = users
            return users
        } catch {
            return nil
        }
    }
}
extension TableViewController: UITableViewDelegate, SkeletonTableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "Cell"
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? EmployeeTableViewCell
        cell!.nameLabel.text = "\(filteredUsers[indexPath.row].first_name) \(filteredUsers[indexPath.row].last_name)"
        cell!.emailLabel.text = "\(filteredUsers[indexPath.row].email)"
        if let url = URL(string: filteredUsers[indexPath.row].avatar) {
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    cell!.userImage.image = UIImage(data: data)!
                    cell!.userImage.layer.cornerRadius = cell!.userImage.frame.height/2
                    cell!.userImage.layer.borderWidth = 2
                    cell!.userImage.layer.borderColor = UIColor(red: 0.59, green: 0.71, blue: 0.77, alpha: 1.00).cgColor
                    cell?.userImage.hideSkeleton()
                    cell?.nameLabel.hideSkeleton()
                    cell?.emailLabel.hideSkeleton()
                    self.employeeTableView.stopSkeletonAnimation()
                    self.employeeTableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(1))
                }
            }
            task.resume()
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        guard let profileDetailVC = storyBoard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
//        else {
//            return
//        }
//        profileDetailVC.employee = users[indexPath.row]
//        self.navigationController?.pushViewController(profileDetailVC, animated: true)
    }
}
extension TableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
            employeeTableView.reloadData()
        } else {
            filteredUsers = users.filter({ users in
                return users.first_name.lowercased().contains(searchText.lowercased())
            })
            employeeTableView.reloadData()
        }
    }
}
