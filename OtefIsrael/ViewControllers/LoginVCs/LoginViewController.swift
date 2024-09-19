import Foundation
import UIKit
import MapKit
import FirebaseAuth

class LoginViewController: UIViewController {

    var onLoginSuccess: ((String) -> Void)?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "launchLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 30
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "כתובת אימייל..."
        field.leftViewMode = .always
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
        field.layer.cornerRadius = 30
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "סיסמה..."
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        field.isSecureTextEntry = true
        field.textAlignment = .right // Align text to the right
        field.semanticContentAttribute = .forceRightToLeft // Force text direction to right-to-left
        return field
    }()

    private let loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .link
        button.setTitle("כניסה", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 0.80
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    private let versionTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textColor = .gray
        textView.textAlignment = .center
        textView.text = "שכחת את הסיסמה?"
        textView.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        textView.backgroundColor = UIColor(named: "TextFieldBackground")
        textView.showsVerticalScrollIndicator = false
        return textView
    }()
    
    private let ForgotButton : UIButton = {
        let button = UIButton()
        button.setTitle("לחץ כאן", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 16, weight : .bold)
        return button
    }()

    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("הירשם", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "כניסה"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor.white

        emailField.leftView = createLeftViewWithIcon(named: "envelope.fill")
        passwordField.leftView = createLeftViewWithIcon(named: "lock.fill")
        
        ForgotButton.addTarget(self, action: #selector(didTapForgot), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)

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
        scrollView.addSubview(ForgotButton)
        scrollView.addSubview(registerButton)

        onLoginSuccess = { userID in
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    appDelegate.handleUserSignedIn(window: window)
                } else {
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
        let theWidth = scrollView.width - 60
        let size = scrollView.width / 2

        imageView.frame = CGRect(x: (scrollView.width - size) / 2, y: 20, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 15, width: theWidth, height: 60)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 30, width: theWidth, height: 60)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom + 30, width: theWidth, height: 60)
        versionTextView.frame = CGRect(x: (scrollView.width - 230), y: loginButton.bottom + 20, width: 200, height: 32)
        ForgotButton.frame = CGRect(x: versionTextView.left - 100, y: loginButton.bottom + 20, width: 70, height: 32)
        registerButton.frame = CGRect(x: (scrollView.width - size) / 2, y: ForgotButton.bottom + 100, width: size, height: 32)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func createLeftViewWithIcon(named iconName: String) -> UIView {
        let iconSize: CGFloat = 24
        let padding: CGFloat = 10
        let viewSize: CGFloat = iconSize + padding * 2

        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: viewSize, height: viewSize))
        let imageView = UIImageView(frame: CGRect(x: padding, y: padding, width: iconSize, height: iconSize))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: iconName)
        imageView.tintColor = .gray

        leftView.addSubview(imageView)

        return leftView
    }

    @objc private func didTapRegister() {
        let rvc = RegisterViewController()
        rvc.onRegistrationSuccess = { [weak self] userId in
            guard let strongSelf = self else { return }
            strongSelf.transitionToMainApp(loggedInUserUID: userId)
        }

        rvc.title = "צור חשבון"
        navigationController?.pushViewController(rvc, animated: true)
    }

    @objc private func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()

        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError(message: "אנא הזן את כל המידע על מנת להתחבר")
            return
        }

        SpinnerManager.shared.showSpinner()
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            SpinnerManager.shared.hideSpinner()
            guard let result = authResult, error == nil else {
                strongSelf.alertUserLoginError(message: "האימייל או הסיסמה אינם נכונים")
                print("Error logging in")
                return
            }
            let loggedInUser = result.user

            DatabaseManager.shared.getUserData(with: loggedInUser.uid) { (user) in
                if let user = user {
                    UserDefaults.standard.set(user.firstName + " " + user.lastName, forKey: "name")
                    UserDefaults.standard.set(user.id, forKey: "User ID")
                    UserDefaults.standard.set(user.originalCity, forKey: "originalCity")
                    UserDefaults.standard.set(user.currentCity, forKey: "currentCity")
                    UserDefaults.standard.set(user.phoneNumber, forKey: "phone")
                } else {
                    print("User not found")
                    strongSelf.alertUserLoginError(message: "האימייל או הסיסמה אינם נכונים")
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
    
    @objc private func didTapForgot() {
        // Assuming you have an emailField in your LoginViewController
        let emailText = emailField.text ?? ""
        
        let alertController = UIAlertController(title: "איפוס סיסמה", message: "הכנס את כתובת המייל שלך", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "מייל..."
            textField.keyboardType = .emailAddress
            textField.text = emailText  // Set the current email text if available
        }
        
        let resetAction = UIAlertAction(title: "איפוס", style: .default) { [weak self] _ in
            if let email = alertController.textFields?.first?.text, !email.isEmpty {
                self?.resetPassword(for: email)
            } else {
                self?.alertUserLoginError(message: "בבקשה תכניס כתובת מייל תקינה")
            }
        }
        
        let cancelAction = UIAlertAction(title: "ביטול", style: .cancel, handler: nil)
        
        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func resetPassword(for email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                // Handle error (e.g., show an alert)
                self.alertUserLoginError(message: error.localizedDescription)
            } else {
                // Show success message
                self.alertUserLoginError(message: "מייל איפוס סיסמה נשלח לכתובת המייל")
            }
        }
    }

    func transitionToMainApp(loggedInUserUID: String) {
        if let onLoginSuccess = self.onLoginSuccess {
            onLoginSuccess(loggedInUserUID)
        }
    }

    func alertUserLoginError(message: String) {
        let alert = UIAlertController(title: "שגיאה", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "סגור", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}

