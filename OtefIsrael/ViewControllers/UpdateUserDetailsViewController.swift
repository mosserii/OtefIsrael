import UIKit

class UpdateUserDetailsViewController: UIViewController, UITextViewDelegate {

    var existingUser: User? // This will hold the existing user data
    var onUpdateCompletion: (() -> Void)? // Completion handler to notify ProfileViewController

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
        field.textAlignment = .right
        field.semanticContentAttribute = .forceRightToLeft
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
        field.placeholder = "שם משפחה..."
        field.leftViewMode = .always
        field.backgroundColor = UIColor.white
        field.textAlignment = .right
        field.semanticContentAttribute = .forceRightToLeft
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
        field.textAlignment = .right
        field.semanticContentAttribute = .forceRightToLeft
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
        field.textAlignment = .right
        field.semanticContentAttribute = .forceRightToLeft
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
        field.placeholder = "מספר טלפון..."
        field.leftViewMode = .always
        field.textContentType = .telephoneNumber
        field.keyboardType = .numberPad
        field.backgroundColor = UIColor.white
        field.textAlignment = .right
        field.semanticContentAttribute = .forceRightToLeft
        return field
    }()

    private let saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .link
        button.setTitle("שמור שינויים", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 0.80
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    
    private let firstNameLabel: UILabel = {
        let label = UILabel()
        label.text = "שם פרטי"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()

    private let lastNameLabel: UILabel = {
        let label = UILabel()
        label.text = "שם משפחה"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()

    private let originalCityLabel: UILabel = {
        let label = UILabel()
        label.text = "יישוב בת״ז"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()

    private let currentCityLabel: UILabel = {
        let label = UILabel()
        label.text = "יישוב נוכחי"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()

    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "מספר טלפון"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "עריכת פרטים"
        view.backgroundColor = .white
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        firstNameField.leftView = createLeftViewWithIcon(named: "person.fill")
        lastNameField.leftView = createLeftViewWithIcon(named: "person.fill")
        originalCityField.leftView = createLeftViewWithIcon(named: "person.3.fill")
        currentCityField.leftView = createLeftViewWithIcon(named: "person.3.fill")
        phoneField.leftView = createLeftViewWithIcon(named: "phone.fill")
        
        firstNameField.text = existingUser?.firstName
        lastNameField.text = existingUser?.lastName
        originalCityField.text = existingUser?.originalCity
        currentCityField.text = existingUser?.currentCity
        phoneField.text = existingUser?.phoneNumber
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(originalCityField)
        scrollView.addSubview(currentCityField)
        scrollView.addSubview(phoneField)
        scrollView.addSubview(saveButton)
        
        scrollView.addSubview(firstNameLabel)
        scrollView.addSubview(lastNameLabel)
        scrollView.addSubview(originalCityLabel)
        scrollView.addSubview(currentCityLabel)
        scrollView.addSubview(phoneLabel)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 2
        
        imageView.frame = CGRect(x: (scrollView.width - size) / 2, y: 20, width: size, height: size)
        firstNameLabel.frame = CGRect(x: 30, y: imageView.bottom + 15, width: scrollView.width - 60, height: 20)
        firstNameField.frame = CGRect(x: 30, y: firstNameLabel.bottom + 5, width: scrollView.width - 60, height: 32)

        lastNameLabel.frame = CGRect(x: 30, y: firstNameField.bottom + 20, width: scrollView.width - 60, height: 20)
        lastNameField.frame = CGRect(x: 30, y: lastNameLabel.bottom + 5, width: scrollView.width - 60, height: 32)

        originalCityLabel.frame = CGRect(x: 30, y: lastNameField.bottom + 20, width: scrollView.width - 60, height: 20)
        originalCityField.frame = CGRect(x: 30, y: originalCityLabel.bottom + 5, width: scrollView.width - 60, height: 32)

        currentCityLabel.frame = CGRect(x: 30, y: originalCityField.bottom + 20, width: scrollView.width - 60, height: 20)
        currentCityField.frame = CGRect(x: 30, y: currentCityLabel.bottom + 5, width: scrollView.width - 60, height: 32)

        phoneLabel.frame = CGRect(x: 30, y: currentCityField.bottom + 20, width: scrollView.width - 60, height: 20)
        phoneField.frame = CGRect(x: 30, y: phoneLabel.bottom + 5, width: scrollView.width - 60, height: 32)

        saveButton.frame = CGRect(x: 30, y: phoneField.bottom + 40, width: scrollView.width - 60, height: 50)
        
        scrollView.contentSize = CGSize(width: view.width, height: view.height * 1.2)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func saveButtonTapped() {
        guard let userId = existingUser?.id else { return }
        
        let isAdmin = existingUser?.isAdmin ?? false
        let firstName = firstNameField.text ?? ""
        let lastName = lastNameField.text ?? ""
        let email = existingUser?.email ?? ""
        let requests = existingUser?.requests ?? []
        let phoneNumber = phoneField.text ?? ""

        let updatedUser = User(
            id: userId,
            isAdmin: isAdmin,
            firstName: firstName,
            lastName: lastName,
            originalCity: originalCityField.text,
            currentCity: currentCityField.text,
            email: email,
            requests: requests,
            phoneNumber: phoneNumber
        )
        
        // Update user in database
        DatabaseManager.shared.updateUser(with: updatedUser) { [weak self] success in
            guard let strongSelf = self else { return }
            if success {
                UserDefaults.standard.setValue(strongSelf.existingUser?.email, forKey: "email")
                UserDefaults.standard.setValue(userId, forKey: "User ID")
                UserDefaults.standard.setValue(firstName + " " + lastName, forKey: "name")
                UserDefaults.standard.setValue(strongSelf.originalCityField.text, forKey: "originalCity")
                UserDefaults.standard.setValue(strongSelf.currentCityField.text, forKey: "currentCity")
                UserDefaults.standard.setValue(phoneNumber, forKey: "phone")
                print("User details updated successfully")
                strongSelf.onUpdateCompletion?()
                strongSelf.dismiss(animated: true, completion: nil)
            } else {
                print("Failed to update user details")
            }
        }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}

