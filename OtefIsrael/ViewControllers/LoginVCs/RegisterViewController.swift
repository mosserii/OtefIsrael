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
    
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .sentences
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "שם פרטי..." // Hebrew placeholder
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        field.textAlignment = .right // Align text to the right
        field.semanticContentAttribute = .forceRightToLeft // Force text direction to right-to-left
        return field
    }()

    private let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .sentences
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "שם משפחה..." // Hebrew placeholder
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        field.textAlignment = .right // Align text to the right
        field.semanticContentAttribute = .forceRightToLeft // Force text direction to right-to-left
        return field
    }()
    
    private let originalCityField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .sentences
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "יישוב בת״ז" // Hebrew placeholder
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        field.textAlignment = .right // Align text to the right
        field.semanticContentAttribute = .forceRightToLeft // Force text direction to right-to-left
        return field
    }()
    
    private let currentCityField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .sentences
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "יישוב נוכחי"
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        field.textAlignment = .right // Align text to the right
        field.semanticContentAttribute = .forceRightToLeft // Force text direction to right-to-left
        return field
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "כתובת אימייל..." // Hebrew placeholder
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        field.textAlignment = .right // Align text to the right
        field.semanticContentAttribute = .forceRightToLeft // Force text direction to right-to-left
        field.textContentType = .emailAddress
        field.keyboardType = .emailAddress
        return field
    }()
    
    private let phoneField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "מספר טלפון..." // Hebrew placeholder
        field.leftViewMode = .always
        field.textContentType = .telephoneNumber
        field.keyboardType = .numberPad
        field.backgroundColor = UIColor.white
        field.textAlignment = .right // Align text to the right
        field.semanticContentAttribute = .forceRightToLeft // Force text direction to right-to-left
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "סיסמה..." // Hebrew placeholder
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        field.isSecureTextEntry = true
        field.textAlignment = .right // Align text to the right
        field.semanticContentAttribute = .forceRightToLeft // Force text direction to right-to-left
        return field
    }()
    
    private let agreementLabel: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear // or match your background
        textView.textAlignment = .right
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.link
        ]
        return textView
    }()

    private let registerButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .link
        button.setTitle("הרשמה", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.gray.cgColor // Specify your desired color
        button.layer.borderWidth = 0.80 // Adjust the width as needed
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "פתיחת חשבון"
        view.backgroundColor = UIColor.white
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        firstNameField.leftView =  createLeftViewWithIcon(named: "person.fill")
        lastNameField.leftView =  createLeftViewWithIcon(named: "building")
        originalCityField.leftView =  createLeftViewWithIcon(named: "person.3.fill")
        currentCityField.leftView =  createLeftViewWithIcon(named: "person.3.fill")
        emailField.leftView = createLeftViewWithIcon(named: "envelope.fill")
        phoneField.leftView = createLeftViewWithIcon(named: "phone.fill")
        passwordField.leftView = createLeftViewWithIcon(named: "lock.fill")
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        originalCityField.delegate = self
        currentCityField.delegate = self
        emailField.delegate = self
        phoneField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(originalCityField)
        scrollView.addSubview(currentCityField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(phoneField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        addlinksToAgreementLabel()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width/2
        
        imageView.frame = CGRect(x: (scrollView.width - size)/2, y: 20, width: size, height: size)
        firstNameField.frame = CGRect(x: 30, y: imageView.bottom + 15, width: scrollView.width-60, height: 32)
        lastNameField.frame = CGRect(x: 30, y: firstNameField.bottom + 30, width: scrollView.width-60, height: 32)
        originalCityField.frame = CGRect(x: 30, y: lastNameField.bottom + 30, width: scrollView.width-60, height: 32)
        currentCityField.frame = CGRect(x: 30, y: originalCityField.bottom + 30, width: scrollView.width-60, height: 32)
        emailField.frame = CGRect(x: 30, y: currentCityField.bottom + 30, width: scrollView.width-60, height: 32)
        phoneField.frame = CGRect(x: 30, y: emailField.bottom+30, width: (scrollView.width-60), height: 32)
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
        
        let agreementText = "על ידי לחיצת הרשמה, את/ה מסכים/ה לתנאי השימוש ותנאי הפרטיות"
        let attributedString = NSMutableAttributedString(string: agreementText)
        
        // Configure link attributes
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.darkGray
        ]
        
        // TODO Add link to Privacy Policy
        if let privacyPolicyRange = agreementText.range(of: "ותנאי הפרטיות") {
            attributedString.addAttribute(.link, value: "https://solidarity.bringthemhomenow.net", range: NSRange(privacyPolicyRange, in: agreementText))
        }
        
        // Add link to Terms of Use
        if let termsOfUseRange = agreementText.range(of: "לתנאי השימוש") {
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

    @objc private func registerButtonTapped(){
        
        emailField.resignFirstResponder()
        phoneField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        originalCityField.resignFirstResponder()
        currentCityField.resignFirstResponder()

        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let originalCity = originalCityField.text, let currentCity = currentCityField.text, let email = emailField.text,
                var phone = phoneField.text, let password = passwordField.text,
              !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, isValidEmail(email), !phone.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserRegisterError(message: "Please enter all information to register, check your email address")
                return
        }
        SpinnerManager.shared.showSpinner()
        print("registerButtonTapped before userExists")
        DatabaseManager.shared.userExists(email: email, phoneNumber: phone, completion: { [weak self] exist in
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
        
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let originalCity = originalCityField.text, let currentCity = currentCityField.text, let email = emailField.text,
              var phone = phoneField.text, let password = passwordField.text,
              !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !phone.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserRegisterError(message: "בבקשה מלא את כל השדות על מנת להירשם")
            return
        }
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else{
                return
            }
            guard let result = authResult, error == nil else{
                strongSelf.alertUserRegisterError(message: "כתובת המייל שהוזנה כבר בשימוש")
                return
            }
            let newUser = User(id: result.user.uid, firstName: firstName, lastName: lastName, email: email, requests: [], phoneNumber: phone)
            DatabaseManager.shared.insertUser(with: newUser, completion: {success in
                if !success{
                    return
                }
                UserDefaults.standard.set(newUser.id, forKey: "User ID")
                UserDefaults.standard.set(firstName + " " + lastName, forKey: "name")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(originalCity, forKey: "originalCity")
                UserDefaults.standard.set(currentCity, forKey: "currentCity")
                UserDefaults.standard.set(phone, forKey: "phone")
                strongSelf.onRegistrationSuccess?(newUser.id)
            })
        })
    }
    
    func alertUserRegisterError(message:String){
        let alert = UIAlertController(title: "שים לב", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "אוקיי", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            originalCityField.becomeFirstResponder()
        } else if textField == originalCityField {
            currentCityField.becomeFirstResponder()
        } else if textField == currentCityField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            phoneField.becomeFirstResponder()
        } else if textField == phoneField {
            view.endEditing(true)
        } else if textField == passwordField {
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
        guard let activeField = view.findFirstResponder() as? UITextField else { return }
        
        if showing {
            let fieldFrame = scrollView.convert(activeField.frame, to: view)
            let fieldBottomY = fieldFrame.origin.y + fieldFrame.height
            let visibleAreaHeight = view.frame.height - keyboardHeight
            
            if fieldBottomY > visibleAreaHeight {
                let offset = fieldBottomY - visibleAreaHeight + 20 // Add some padding
                self.view.frame.origin.y = -offset
            }
        } else {
            self.view.frame.origin.y = 0
        }
    }
}

extension UIView {
    // Helper method to find the first responder
    func findFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        for subview in self.subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}
