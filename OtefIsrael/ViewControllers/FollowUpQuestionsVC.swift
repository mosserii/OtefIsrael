import UIKit

class FollowUpQuestionsVC: UIViewController {
    
    var request: UserRequest?
    
    // MARK: - UI Elements
    
    private let requestTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()

    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "האם הבקשה טופלה?"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let yesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("כן", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapYes), for: .touchUpInside)
        return button
    }()
    
    private let noButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("לא", for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapNo), for: .touchUpInside)
        return button
    }()
    
    private let detailsTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.font = .systemFont(ofSize: 16)
        textView.text = "רשום כאן עוד פרטים על החוויה שלך..."
        textView.textColor = .lightGray
        textView.textAlignment = .right
        return textView
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("שלח", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        return button
    }()
    
    private var didGetHelp: Bool? // Track the user's response
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "איך היה?"
        setupUI()
        setupTextViewPlaceholderBehavior()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding: CGFloat = 20
        requestTitleLabel.frame = CGRect(x: padding, y: 60, width: view.width - 2 * padding, height: 40) // Big title at the top
        questionLabel.frame = CGRect(x: padding, y: requestTitleLabel.bottom + 20, width: view.width - 2 * padding, height: 40)
        
        let buttonWidth: CGFloat = (view.width - 3 * padding) / 2
        noButton.frame = CGRect(x: padding, y: questionLabel.bottom + 20, width: buttonWidth, height: 50)
        yesButton.frame = CGRect(x: noButton.right + padding, y: questionLabel.bottom + 20, width: buttonWidth, height: 50)
        
        detailsTextView.frame = CGRect(x: padding, y: noButton.bottom + 30, width: view.width - 2 * padding, height: 150)
        submitButton.frame = CGRect(x: padding, y: detailsTextView.bottom + 20, width: view.width - 2 * padding, height: 50)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(requestTitleLabel)
        view.addSubview(questionLabel)
        view.addSubview(yesButton)
        view.addSubview(noButton)
        view.addSubview(detailsTextView)
        view.addSubview(submitButton)
        
        submitButton.isEnabled = false
        
        // Set the request title
        requestTitleLabel.text = request?.title ?? "בקשה"
    }

    
    private func setupTextViewPlaceholderBehavior() {
        detailsTextView.delegate = self
        
        // Placeholder behavior for UITextView
        detailsTextView.text = "רשום כאן עוד פרטים על החוויה שלך..."
        detailsTextView.textColor = .lightGray
    }

    
    // MARK: - Button Actions
    
    @objc private func didTapYes() {
        didGetHelp = true
        enableDetailsTextView()
        updateButtonSelectionState(yesSelected: true)
    }
    
    @objc private func didTapNo() {
        didGetHelp = false
        enableDetailsTextView()
        updateButtonSelectionState(yesSelected: false)
    }
    
    @objc private func didTapSubmit() {
        guard let details = detailsTextView.text, details != "רשום כאן עוד פרטים על החוויה שלך..." else { return }
        
        guard let existingRequest = request else{
            return
        }

        let updatedRequest = UserRequest(
            id: existingRequest.id,
            isDemand: existingRequest.isDemand,
            isPublic: existingRequest.isPublic,
            title: existingRequest.title,
            categories: existingRequest.categories,
            oldCity: existingRequest.oldCity,
            currentCity: existingRequest.currentCity,
            age: existingRequest.age,
            date: existingRequest.date,
            description: existingRequest.description,
            user_id: existingRequest.user_id,
            email: existingRequest.email,
            phone: existingRequest.phone,
            imageUrls: existingRequest.imageUrls,
            views: existingRequest.views,
            mailViews: existingRequest.mailViews,
            phoneViews: existingRequest.phoneViews,
            mailsSent: existingRequest.mailsSent,
            isCompleted: self.didGetHelp ?? false,
            feedback: details
        )
        
        DatabaseManager.shared.updateUserRequest(userId: existingRequest.user_id, userRequest: updatedRequest) { success in
            if success {
                print("User request updated successfully")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Failed to update user request")
                let alert = UIAlertController(title: "Error", message: "Failed to update your request. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        // Dismiss or handle completion
        dismiss(animated: true)
    }
    
    
    private func enableDetailsTextView() {
        detailsTextView.isEditable = true
        detailsTextView.text = ""
        detailsTextView.textColor = .black
        submitButton.isEnabled = true
    }

    
    private func updateButtonSelectionState(yesSelected: Bool) {
        yesButton.backgroundColor = yesSelected ? .systemGreen : .lightGray
        noButton.backgroundColor = !yesSelected ? .systemRed : .lightGray
    }
    
    @objc private func textViewTapped() {
        if detailsTextView.text == "רשום כאן עוד פרטים על החוויה שלך..."{
            detailsTextView.text = ""
            detailsTextView.textColor = .black
        }
    }
}

// MARK: - UITextViewDelegate

extension FollowUpQuestionsVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "רשום כאן עוד פרטים על החוויה שלך..." {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "רשום כאן עוד פרטים על החוויה שלך..."
            textView.textColor = .lightGray
        }
    }
}

