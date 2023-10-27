//
//  OtpScreenViewController.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 26/09/23.
//
import UIKit
import OTPFieldView
class OtpScreenViewController: UIViewController {
    @IBOutlet weak var invalidOtpView: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var otpTextField: OTPFieldView!
    @IBOutlet weak var resendTextView: UITextView!
    var timer = Timer()
    var countdown = 30
    var enteredOTP = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.otpTextField.delegate = self
        navigationItem.leftBarButtonItem?.tintColor = .white
        // resendButton.isEnabled = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        verifyButton.isEnabled = false
        verifyButton.alpha = 0.75
        verifyButton.layer.cornerRadius = 12
        resendTextView.delegate = self
        resendTextView.isEditable = false
        resendTextView.isScrollEnabled = false
        resendTextView.textContainer.lineFragmentPadding = 0.0
        resendTextView.textContainerInset = .zero
        setupOtpView()
    }
    @objc func updateTimer() {
        countdown -= 1
        var text = NSLocalizedString("ResendOtpText", comment: "Recent Text")
        if countdown == 0 {
            let linktext = NSLocalizedString("ResendLink", comment: "Recent Link")
            let linkRange = (text as NSString).range(of: linktext)
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label]
            let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
            let linkTextAttributes: [NSAttributedString.Key: Any] = [ .link: "www.google.com"]
            attributedString.addAttributes(linkTextAttributes, range: linkRange)
            resendTextView.attributedText = attributedString
            timer.invalidate()
        } else {
            text += " \(countdown)s"
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label]
            let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
            resendTextView.attributedText = attributedString
        }
    }
    @IBAction func verifyButtonPressed(_ sender: Any) {
        if enteredOTP != "12345"{
            invalidOtpView.isHidden = false
            self.otpTextField.fieldBorderWidth = 2
            self.otpTextField.defaultBorderColor = UIColor.red
            otpTextField.filledBorderColor = UIColor(red: 0.71, green: 0.71, blue: 0.70, alpha: 0.3)
            otpTextField.initializeUI()
        } else {
            invalidOtpView.isHidden = true
            let alert = UIAlertController(title: "User Logged In", message: "The user was logged in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
// MARK: - OTPFieldDelegate
extension OtpScreenViewController: OTPFieldViewDelegate {
    func setupOtpView() {
        self.otpTextField.fieldsCount = 5
        self.otpTextField.fieldBorderWidth = 0
        self.otpTextField.cursorColor = UIColor.black
        self.otpTextField.displayType = .roundedCorner
        self.otpTextField.fieldSize = 50
        self.otpTextField.separatorSpace = 8
        self.otpTextField.defaultBackgroundColor = UIColor(red: 0.71, green: 0.71, blue: 0.70, alpha: 0.3)
        self.otpTextField.filledBackgroundColor = UIColor(red: 0.71, green: 0.71, blue: 0.70, alpha: 0.3)
        self.otpTextField.shouldAllowIntermediateEditing = false
        self.otpTextField.initializeUI()
    }
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    func enteredOTP(otp: String) {
        enteredOTP = otp
        verifyButton.isEnabled = true
    }
    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        if hasEnteredAll {
            verifyButton.isEnabled = true
            verifyButton.alpha = 1
        } else {
            verifyButton.isEnabled = false
            verifyButton.alpha = 0.5
        }
        return false
    }
}
// MARK: - TextView delegate
extension OtpScreenViewController: UITextViewDelegate {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL,
                  in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        timer.invalidate()
        countdown = 30
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        return false
    }
}
