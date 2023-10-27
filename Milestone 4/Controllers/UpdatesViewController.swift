//
//  UpdatesViewController.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 29/09/23.
//
import UIKit
import Lottie
class UpdatesViewController: UIViewController {
    @IBOutlet weak var animationView: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimation()
    }
    func setupAnimation() {
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
    }
}
