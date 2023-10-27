//
//  T&CViewController.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 10/10/23.
//

import UIKit
import ReadMoreTextView
class TCViewController: UIViewController {

    @IBOutlet weak var textView: ReadMoreTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        textView.shouldTrim = true
        textView.maximumNumberOfLines = 4
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.link]
        textView.attributedReadMoreText = NSAttributedString(string: "... Read more", attributes: attributes)
        textView.attributedReadLessText = NSAttributedString(string: " Read less", attributes: attributes)
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }

}
