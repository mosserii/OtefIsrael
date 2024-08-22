//
//  RegisterViewController.swift
//  DestinationSmartFinder
//
//  Created by Zohar Mosseri on 20/02/2024.
//

import Foundation
import UIKit
import MapKit
import FirebaseAuth
import WebKit


class RegisterViewController: UIViewController, UITextViewDelegate {

    var onRegistrationSuccess: ((String) -> Void)?
    
    var new_user_id : String?
    var registraion_FB_completed : Bool = false

    let allowedCountries = [
        ("🇺🇸 USA", "+1"),
        ("🇮🇱 Israel", "+972"),
        ("🇦🇹 Austria", "+43"),
        ("🇦🇿 Azerbaijan", "+994"),
        ("🇧🇪 Belgium", "+32"),
        ("🇧🇬 Bulgaria", "+32"),
        ("🇨🇦 Canada", "+1"),
        ("🇭🇷 Croatia", "+385"),
        ("🇨🇿 Czechia", "+420"),
        ("🇩🇰 Denmark", "+45"),
        ("🇫🇮 Finland", "+358"),
        ("🇫🇷 France", "+33"),
        ("🇬🇪 Georgia", "+995"),
        ("🇩🇪 Germany", "+49"),
        ("🇬🇷 Greece", "+30"),
        ("🇭🇺 Hungary", "+36"),
        ("🇮🇸 Iceland", "+354"),
        ("🇮🇪 Ireland", "+353"),
        ("🇮🇱 Israel", "+972"),
        ("🇮🇹 Italy", "+39"),
        ("🇱🇹 Lithuania", "+370"),
        ("🇱🇺 Luxembourg", "+352"),
        ("🇲🇹 Malta", "+356"),
        ("🇲🇨 Monaco", "+377"),
        ("🇳🇱 Netherlands", "+31"),
        ("🇳🇴 Norway", "+47"),
        ("🇵🇱 Poland", "+48"),
        ("🇵🇹 Portugal", "+351"),
        ("🇷🇴 Romania", "+40"),
        ("🇷🇸 Serbia", "+381"),
        ("🇸🇰 Slovakia", "+421"),
        ("🇸🇮 Slovenia", "+386"),
        ("🇪🇸 Spain", "+34"),
        ("🇸🇪 Sweden", "+46"),
        ("🇨🇭 Switzerland", "+41"),
        ("🇬🇧 United Kingdom", "+44"),
        ("🇺🇸 USA", "+1")
    ]

    private let countryPicker = UIPickerView()

    private var complete_phone : String?
    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "launchLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let firstNameField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .sentences
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        return field
    }()
    
    private let lastNameField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .sentences
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        return field
    }()
    
    private let emailField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        field.textContentType = .emailAddress
        field.keyboardType = .emailAddress
        return field
    }()
    
    private let countryCodeField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        field.placeholder = "Code"
        return field
    }()

    private let phoneField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Phone (Use the same in authentication)"
        field.leftViewMode = .always
        field.textContentType = .telephoneNumber
        field.keyboardType = .numberPad
        field.backgroundColor = UIColor.white
        return field
    }()
    
    private let passwordField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let agreementLabel: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear // or match your background
        textView.textAlignment = .center
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.link
        ]
        return textView
    }()


    private let registerButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("SIGN UP", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.gray.cgColor // Specify your desired color
        button.layer.borderWidth = 0.80 // Adjust the width as needed
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = UIColor.white
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        firstNameField.leftView =  createLeftViewWithIcon(named: "person.fill")
        lastNameField.leftView =  createLeftViewWithIcon(named: "person.3.fill")
        emailField.leftView = createLeftViewWithIcon(named: "envelope.fill")
        countryCodeField.leftView = createLeftViewWithIcon(named: "phone.fill")
        passwordField.leftView = createLeftViewWithIcon(named: "lock.fill")
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        countryCodeField.delegate = self
        phoneField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(countryCodeField)
        scrollView.addSubview(phoneField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        setupCountryPicker()
        addlinksToAgreementLabel()

    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width/2
        
        imageView.frame = CGRect(x: (scrollView.width - size)/2, y: 20, width: size, height: size)
        firstNameField.frame = CGRect(x: 30, y: imageView.bottom + 15, width: scrollView.width-60, height: 32)
        lastNameField.frame = CGRect(x: 30, y: firstNameField.bottom + 30, width: scrollView.width-60, height: 32)
        emailField.frame = CGRect(x: 30, y: lastNameField.bottom + 30, width: scrollView.width-60, height: 32)
        countryCodeField.frame = CGRect(x: 30, y: emailField.bottom+30, width: (scrollView.width-60)/4, height: 32)
        phoneField.frame = CGRect(x: countryCodeField.right, y: emailField.bottom+30, width: scrollView.width-60, height: 32)
        passwordField.frame = CGRect(x: 30, y: phoneField.bottom+30, width: scrollView.width-60, height: 32)
        registerButton.frame = CGRect(x: 30, y: passwordField.bottom+30, width: scrollView.width-60, height: 32)
        agreementLabel.frame = CGRect(x: 30, y: registerButton.bottom+30, width: scrollView.width-60, height: 70)

        scrollView.contentSize = CGSize(width: view.width, height: view.height*1.5)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func addlinksToAgreementLabel(){
        
        let agreementText = "By signing up you agree to the Privacy Policy and Terms of Use."
        let attributedString = NSMutableAttributedString(string: agreementText)
        
        // Configure link attributes
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.darkGray
        ]
        
        // TODO Add link to Privacy Policy
        if let privacyPolicyRange = agreementText.range(of: "Privacy Policy") {
            attributedString.addAttribute(.link, value: "https://solidarity.bringthemhomenow.net", range: NSRange(privacyPolicyRange, in: agreementText))
        }
        
        // Add link to Terms of Use
        if let termsOfUseRange = agreementText.range(of: "Terms of Use") {
            attributedString.addAttribute(.link, value: "https://bringthemhomenow.com", range: NSRange(termsOfUseRange, in: agreementText))
        }
        
        attributedString.addAttributes(linkAttributes, range: NSRange(location: 0, length: attributedString.length))
        agreementLabel.delegate = self
        agreementLabel.attributedText = attributedString // The same attributed string you created

        scrollView.addSubview(agreementLabel)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    func createLeftViewWithIcon(named iconName: String) -> UIView {
        let iconSize: CGFloat = 24
        let padding: CGFloat = 10
        let viewSize: CGFloat = iconSize + padding * 2

        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: viewSize, height: viewSize))
        let imageView = UIImageView(frame: CGRect(x: padding, y: padding, width: iconSize, height: iconSize))
        imageView.contentMode = .scaleAspectFit // Ensure icon is not distorted
        imageView.image = UIImage(systemName: iconName) // Use your icon image here
        imageView.tintColor = .gray

        leftView.addSubview(imageView)

        return leftView
    }
    
    private func setupCountryPicker() {
        countryPicker.delegate = self
        countryPicker.dataSource = self
        countryCodeField.inputView = countryPicker
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissCountryPicker))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        countryCodeField.inputAccessoryView = toolBar
    }

    @objc private func dismissCountryPicker() {
        view.endEditing(true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

    @objc private func registerButtonTapped(){
        
        emailField.resignFirstResponder()
        countryCodeField.resignFirstResponder()
        phoneField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text,
                let code = countryCodeField.text,  var phone = phoneField.text, let password = passwordField.text,
              !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, isValidEmail(email), !code.isEmpty, !phone.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserRegisterError(message: "Please enter all information to register, check your email address")
                return
        }
        if phone.first == "0" {
            phone = String(phone.dropFirst())
        }
        self.complete_phone = code+phone
        SpinnerManager.shared.showSpinner()
        print("registerButtonTapped before userExists")
        DatabaseManager.shared.userExists(email: email, phoneNumber: complete_phone ?? "", completion: { [weak self] exist in
            guard let strongSelf = self else{
                return
            }
            SpinnerManager.shared.hideSpinner()
            guard !exist else{
                strongSelf.alertUserRegisterError(message: "A user with this email or phone number already exists.")
                return
            }
            
            strongSelf.registerToFireBase()
        })
    }

    
    func registerToFireBase(){
        
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text,
              let code = countryCodeField.text,  var phone = phoneField.text, let password = passwordField.text,
              !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !code.isEmpty, !phone.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserRegisterError(message: "please enter all information to register")
            return
        }
        if phone.first == "0" {
            phone = String(phone.dropFirst())
        }
        self.complete_phone = code+phone
        print("registerToFireBase before createUser")
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else{
                return
            }
            guard let result = authResult, error == nil else{
                strongSelf.alertUserRegisterError(message: "Email Address is already in use")
                return
            }
            let newUser = User(id: result.user.uid, firstName: firstName, lastName: lastName, email: email, requests: [], phoneNumber: code+phone)
            DatabaseManager.shared.insertUser(with: newUser, completion: {success in
                if !success{
                    return
                }
                UserDefaults.standard.set(newUser.id, forKey: "User ID")
                UserDefaults.standard.set(firstName + " " + lastName, forKey: "name")
                UserDefaults.standard.set(email, forKey: "email")
                strongSelf.onRegistrationSuccess?(newUser.id)
            })
        })
    }
    
    func alertUserRegisterError(message:String){
        let alert = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameField{
            lastNameField.becomeFirstResponder()
        }
        else if textField == lastNameField{
//            if !isValidEmail(emailField.text){
//                return false
//            }
            emailField.becomeFirstResponder()
        }
        else if textField == emailField{
            phoneField.becomeFirstResponder()
        }
        else if textField == phoneField{
            view.endEditing(true)
        }
        else if textField == passwordField{
            view.endEditing(true)
        }
        return true
    }
    
    func isValidEmail(_ email: String?) -> Bool {
        guard email != nil else { return false }

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            adjustViewFrameForKeyboard(showing: true, keyboardHeight: keyboardSize.height)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustViewFrameForKeyboard(showing: false, keyboardHeight: 0)
    }
    
    func adjustViewFrameForKeyboard(showing: Bool, keyboardHeight: CGFloat) {
        if showing {
            self.view.frame.origin.y = -keyboardHeight/2.3
        } else {
            self.view.frame.origin.y = 0
        }
    }
}

extension RegisterViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allowedCountries.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(allowedCountries[row].0) (\(allowedCountries[row].1))"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let country = allowedCountries[row]
        countryCodeField.text = country.1
    }
}
