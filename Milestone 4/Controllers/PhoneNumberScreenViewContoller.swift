import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
class PhoneNumberScreenViewContoller: UIViewController {
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var phonenoTextField: UITextField!
    var phoneNumber = ""
    var enteredOTP = ""
    var selectedCountryCode = ""
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 2)
    let countryCodeData: [String: String] = [
        "IN": "+91",
        "USA": "+1",
        "CA": "+1",
        "UK": "+44",
        "AU": "+61",
        "DE": "+49"
    ]
    var countryArray: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        verifyButton.layer.cornerRadius = 12
        phonenoTextField.delegate = self
        countryPicker.delegate = self
        countryPicker.dataSource = self
        countryPicker.layer.cornerRadius = 8
        countryArray = Array(countryCodeData.keys)
    }
    override func viewWillAppear(_ animated: Bool) {
        phonenoTextField.text = ""
        phoneNumber = ""
        selectedCountryCode = "+91"
    }
    @IBAction func verifyButtonPressed(_ sender: Any) {
        phoneNumber = selectedCountryCode + (phonenoTextField.text ?? "")
        if phoneNumber != "" && phoneNumber.count >= 10 {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            print(phoneNumber)
            guard let otpVC = storyBoard.instantiateViewController(withIdentifier: "OtpScreenViewController") as? OtpScreenViewController
            else {
                return
            }
            self.navigationController?.pushViewController(otpVC, animated: true)
        }
    }
}
// MARK: - UITextField Delegate
extension PhoneNumberScreenViewContoller: UITextFieldDelegate {
    private func textLimit(existingText: String?, newText: String, limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isLimited = self.textLimit(existingText: textField.text, newText: string, limit: 10)
        return isLimited
    }
}
// MARK: - UIPickerViewDelegates
extension PhoneNumberScreenViewContoller: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryCodeData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(countryArray[row]) \(countryCodeData[countryArray[row]]!)"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCountryCode = countryCodeData[countryArray[row]]!
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "", size: 20)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = "\(countryArray[row]) \(countryCodeData[countryArray[row]]!)"
        return pickerLabel!
    }
}
