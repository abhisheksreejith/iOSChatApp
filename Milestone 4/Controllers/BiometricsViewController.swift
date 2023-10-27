//
//  BiometricsViewController.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 09/10/23.
//
import UIKit
import Lottie
class BiometricsViewController: UIViewController {
    @IBOutlet weak var biometricsEnableAction: UISwitch!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var biometricsModeSwitch: UISwitch!
    let userDefaults = UserDefaults.standard
    let lottieString = "https://lottie.host/1c6a3eb9-ff9e-4928-b330-a89aa74bd76c/RQTguY8N51.json"
    @IBOutlet weak var animationView: LottieAnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 15
        setupLottie(urlString: lottieString)
        if userDefaults.bool(forKey: "BiometricsEnabled") {
            biometricsModeSwitch.isOn = true
        } else {
            biometricsModeSwitch.isOn = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    @IBAction func biometricsEnabledAction(_ sender: UISwitch) {
        if sender.isOn {
            userDefaults.set(true, forKey: "BiometricsEnabled")
            return
        } else {
            userDefaults.set(false, forKey: "BiometricsEnabled")
            return
        }
    }
    func setupLottie(urlString: String) {
        guard let url  = URL(string: urlString) else { return }
        LottieAnimation.loadedFrom(url: url, closure: {animation in
            self.animationView.animation = animation
            self.animationView.contentMode = .scaleAspectFit
            self.animationView.loopMode = .loop
            self.animationView.play()
        }, animationCache: DefaultAnimationCache.sharedCache)
    }
}
