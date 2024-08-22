//
//  LoginViewController.swift
//  DestinationSmartFinder
//
//  Created by Zohar Mosseri on 20/02/2024.
//

import Foundation
import UIKit
import MapKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    var onLoginSuccess: ((String) -> Void)?


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
    
    private let emailField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
//        field.placeholder = "EMAIL"
        //field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
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
//        field.placeholder = "PASSWORD"
        //field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        //todo field.passwordRules =
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        field.isSecureTextEntry = true
        return field
    }()

    private let loginButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.gray.cgColor // Specify your desired color
        button.layer.borderWidth = 0.80 // Adjust the width as needed
        button.titleLabel?.font = .systemFont(ofSize: 20, weight : .bold)
        return button
    }()
    
    private let versionTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textColor = .gray
        textView.textAlignment = .center
        textView.text = "Don't have an account?"
        textView.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        textView.backgroundColor = UIColor(named: "TextFieldBackground")
        textView.showsVerticalScrollIndicator = true
        return textView
    }()
    
    private let RegisterButton : UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 16, weight : .bold)
        return button
    }()
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor.white
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        emailField.leftView = createLeftViewWithIcon(named: "envelope.fill")
        passwordField.leftView = createLeftViewWithIcon(named: "lock.fill")

        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        RegisterButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(versionTextView)
        scrollView.addSubview(RegisterButton)
        
        
        onLoginSuccess = { userID in
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    appDelegate.handleUserSignedIn(window: window)
                }
                else{
                    let loginVC = LoginViewController()
                    let nav = UINavigationController(rootViewController: loginVC)
                    nav.modalPresentationStyle = .fullScreen
                }
            }
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        let theWidth = scrollView.width-60
        let size = scrollView.width/2
        
        
        imageView.frame = CGRect(x: (scrollView.width - size)/2, y: 20, width: size, height: size)
        emailField.frame = CGRect(x: 20, y: imageView.bottom + 15, width: theWidth, height: 32)
        passwordField.frame = CGRect(x: 20, y: emailField.bottom+30, width: theWidth, height: 32)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom+30, width: theWidth, height: 32)
        versionTextView.frame = CGRect(x: 30, y: loginButton.bottom+20, width: 200, height: 32)
        RegisterButton.frame = CGRect(x: versionTextView.right + 1, y: loginButton.bottom+20, width: 70, height: 32)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func createLeftViewWithIcon(named iconName: String) -> UIView {
        let iconSize: CGFloat = 24 // Adjust icon size
        let padding: CGFloat = 10 // Adjust padding around icon
        let viewSize: CGFloat = iconSize + padding * 2

        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: viewSize, height: viewSize))
        let imageView = UIImageView(frame: CGRect(x: padding, y: padding, width: iconSize, height: iconSize))
        imageView.contentMode = .scaleAspectFit // Ensure icon is not distorted
        imageView.image = UIImage(systemName: iconName) // Use your icon image here
        imageView.tintColor = .gray

        leftView.addSubview(imageView)

        return leftView
    }



    @objc private func didTapRegister(){
        let RVC = RegisterViewController()
        RVC.onRegistrationSuccess = { [weak self] userId in
            guard let strongSelf = self else { return }
            // Transition to the main app VC
            strongSelf.transitionToMainApp(loggedInUserUID: userId)
        }

        RVC.title = "Create Account"
        navigationController?.pushViewController(RVC, animated: true)
    }

    @objc private func loginButtonTapped(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                alertUserLoginError(message: "please enter all information to log in")
                return
        }
        SpinnerManager.shared.showSpinner()
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult, error in
            guard let strongSelf = self else{
                return
            }
            SpinnerManager.shared.hideSpinner()
            guard let result = authResult, error == nil else{
                strongSelf.alertUserLoginError(message: "Email or Password are incorrect")
                print("Error logging in")
                return
            }
            let loggedInUser = result.user
            
            DatabaseManager.shared.getUserData(with: loggedInUser.uid) { (user) in
                if let user = user {
                    UserDefaults.standard.set(user.firstName + " " + user.lastName, forKey: "name")
                    UserDefaults.standard.set(user.id, forKey: "User ID")
                } else {
                    print("User not found")
                    strongSelf.alertUserLoginError(message: "email or password is incorrect")
                }
            }
            UserDefaults.standard.set(email, forKey: "email")
            
            print("logged in user:  \(loggedInUser)")
            strongSelf.transitionToMainApp(loggedInUserUID: loggedInUser.uid)

            strongSelf.navigationController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: NSNotification.Name("LoginVCDismissed"), object: nil)
            })

        })
    }
    
    func transitionToMainApp(loggedInUserUID : String) {
        
        if let onLoginSuccess = self.onLoginSuccess {
            onLoginSuccess(loggedInUserUID)
        }
    }

    func alertUserLoginError(message:String){
        let alert = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            loginButtonTapped()
        }
        return true
    }
}
