//
//  VolunteerVC.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 21/08/2024.
//

import Foundation
import UIKit
import FirebaseAuth


class VolunteerVC: UIViewController, UITextFieldDelegate {

    var isDemand: Bool = false
    var isEditingRequest: Bool = false
    var requestToEdit: UserRequest? // TODO: pass the request we want to edit
    
    var requests = [UserRequest]()
            
    var activeField: UIView?

    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.isPagingEnabled = false
        scrollView.backgroundColor = UIColor.white
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "הוספת בקשה"
        label.textAlignment = .right
        label.textColor = .black
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "מלא את כל פרטי בקשתך על מנת שנוכל למצוא התאמה למי שצריך ולטפל בה בצורה הטובה ביותר."
        label.numberOfLines = 0
        label.textAlignment = .right
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.text = "כותרת הבקשה"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()
    
    private let headlineField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .sentences
        field.autocorrectionType = .no
        field.returnKeyType = .next
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "רשום כותרת..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.textAlignment = .right
        field.textColor = .black
        field.backgroundColor = .white
        return field
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "קטגוריה"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private let categoryField: UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "בחר קטגוריה..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.textColor = .black
        field.textAlignment = .right
        field.returnKeyType = .done
        return field
    }()
    
    private let segmentedControlLabel: UILabel = {
        let label = UILabel()
        label.text = "היכן לפרסם?"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["להעלות ללוח הקהילה", "להעביר רק למנהלים"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = .white
        control.layer.cornerRadius = 8
        control.layer.borderWidth = 1
        control.selectedSegmentTintColor = .systemGreen
        control.layer.borderColor = UIColor.lightGray.cgColor
        return control
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.text = "תיאור הבקשה"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private let descField: UITextView = {
        let textView = UITextView()
        textView.autocapitalizationType = .sentences
        textView.autocorrectionType = .no
        textView.layer.cornerRadius = 8 // Match the corner radius
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1 // Match the border width
        textView.textColor = .black // Match the text color
        textView.backgroundColor = .white // Match the background color
        textView.textAlignment = .right // Match the text alignment
        textView.font = UIFont.systemFont(ofSize: 16) // Match the font size
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12) // Adjust to match UITextField padding
        textView.isScrollEnabled = false
        textView.text = "פרט לפרטים על מנת שנוכל להבין טוב יותר..."
        textView.textColor = UIColor.lightGray // Placeholder color
        return textView
    }()
    
    private let agePickerLabel: UILabel = {
        let label = UILabel()
        label.text = "גיל"
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    private let agePickerField: UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "גיל"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.keyboardType = .numberPad
        field.textColor = .black
        field.returnKeyType = .next
        field.textAlignment = .right
        field.semanticContentAttribute = .forceLeftToRight
        return field
    }()
    
    private let oldCityLabel: UILabel = {
        let label = UILabel()
        label.text = "יישוב מקורי"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private let oldCityField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .sentences
        field.autocorrectionType = .no
        field.returnKeyType = .next
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "רשום יישוב מקורי..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.textAlignment = .right
        field.textColor = .black
        field.backgroundColor = .white
        return field
    }()
    
    private let currentCityLabel: UILabel = {
        let label = UILabel()
        label.text = "יישוב נוכחי"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private let currentCityField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .sentences
        field.autocorrectionType = .no
        field.returnKeyType = .next
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "רשום יישוב נוכחי..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.textAlignment = .right
        field.textColor = .black
        field.backgroundColor = .white
        return field
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "תאריך הבקשה"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let field = UIDatePicker()
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = UIColor.white
        field.minimumDate = Date() // Set the minimum date to today
        field.datePickerMode = .date // Show only the date picker
        return field
    }()
    
    private let photoLabel: UILabel = {
        let label = UILabel()
        label.text = "הוסף תמונות"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()

    private let photoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("בחר תמונות", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(photoButtonTapped), for: .touchUpInside)
        return button
    }()

    private let photoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()


    
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let previousButton = UIBarButtonItem(title: "אחורה", style: .plain, target: self, action: #selector(previousButtonTapped))
        let nextButton = UIBarButtonItem(title: "קדימה", style: .plain, target: self, action: #selector(nextButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [previousButton, nextButton, flexSpace, doneButton]

        return toolbar
    }()
    
    private var isFormVisible = false
            
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        scrollView.backgroundColor = .white
        
        setupUI()
        setupPickers()
    
        fillCities()
        // Set the delegates for text fields
        agePickerField.delegate = self
        headlineField.delegate = self
        oldCityField.delegate = self
        currentCityField.delegate = self
        categoryField.delegate = self
        descField.delegate = self
        
        if !self.isDemand{
            self.titleLabel.text = "תיאור הצעת ההתנדבות"
            self.instructionLabel.text = "מעריכים שהגעת עד לפה ויש עוד אנשים טובים בדרך, נשמח לדייק את ההתנדבות על מנת שנוכל להתאים אותה בצורה הטובה ביותר."
            self.headlineLabel.text = "כותרת הצעת ההתנדבות"
            self.descLabel.text = "פרטים נוספים על ההתנדבות"
            self.dateLabel.text = "תאריך ההתנדבות"
        }
        
        let continueButton = UIBarButtonItem(title: "פרסם", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.leftBarButtonItem = continueButton
                
        if let request = requestToEdit {
            fillRequest(request: request)
        }
    }
    
    func fillRequest(request: UserRequest) {
        headlineField.text = request.title
        categoryField.text = request.categories.first
        oldCityField.text = request.oldCity
        currentCityField.text = request.currentCity
        agePickerField.text = request.age
        datePicker.date = request.date ?? Date() // Set to current date if nil
        descField.text = request.description
        
        // If description is empty, set placeholder
        if request.description?.isEmpty ?? true {
            descField.text = "תאר את הבקשה..."
            descField.textColor = UIColor.lightGray
        }

        // Load and display images if imageUrls are present
        if let imageUrls = request.imageUrls, !imageUrls.isEmpty {
            for imageUrl in imageUrls {
                if let url = URL(string: imageUrl) {
                    loadImageFromUrl(url: url) { [weak self] image in
                        guard let image = image else {return}
                        self?.addImageToStackView(image: image)
                    }
                }
            }
        }
    }
    
    func addImageToStackView(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 1
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        photoStackView.addArrangedSubview(imageView)
        
        // Update scrollView contentSize
        scrollView.contentSize = CGSize(width: view.frame.width, height: photoStackView.frame.maxY + 70)
    }


    private func loadImageFromUrl(url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                print("Failed to load image from URL: \(url), error: \(String(describing: error))")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }

    
    func fillCities() {
        guard let originalCity = UserDefaults.standard.value(forKey: "originalCity") as? String,
                  let currentCity = UserDefaults.standard.value(forKey: "currentCity") as? String
        else {
            return
        }
        oldCityField.text = originalCity
        currentCityField.text = currentCity
    }

    
    private func clearForm() {
        agePickerField.text = ""
        headlineField.text = ""
        oldCityField.text = ""
        currentCityField.text = ""
        categoryField.text = ""
    }
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(instructionLabel)
        
        scrollView.addSubview(headlineLabel)
        scrollView.addSubview(headlineField)
        scrollView.addSubview(categoryLabel)
        scrollView.addSubview(categoryField)
        
        
        scrollView.addSubview(segmentedControlLabel)
        scrollView.addSubview(segmentedControl)

        scrollView.addSubview(descLabel)
        scrollView.addSubview(descField)
        scrollView.addSubview(oldCityLabel)
        scrollView.addSubview(oldCityField)
        scrollView.addSubview(currentCityLabel)
        scrollView.addSubview(currentCityField)
        scrollView.addSubview(agePickerLabel)
        scrollView.addSubview(agePickerField)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(datePicker)
        scrollView.addSubview(photoLabel)
        scrollView.addSubview(photoButton)
        scrollView.addSubview(photoStackView)
        
        let exitButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(exitButtonTapped))
        navigationItem.rightBarButtonItem = exitButton
        
        let padding: CGFloat = 20
        let elementHeight: CGFloat = 44
        let labelHeight: CGFloat = 20
        
        scrollView.frame = view.bounds
        
        titleLabel.frame = CGRect(x: padding, y: view.safeAreaInsets.top + padding, width: view.frame.size.width - 2 * padding, height: 30)
        instructionLabel.frame = CGRect(x: padding, y: titleLabel.frame.maxY + 10, width: view.frame.size.width - 2 * padding, height: 60)
        
        headlineLabel.frame = CGRect(x: padding, y: instructionLabel.frame.maxY + padding, width: view.frame.size.width - 2 * padding, height: labelHeight)
        headlineField.frame = CGRect(x: padding, y: headlineLabel.frame.maxY + 5, width: view.frame.size.width - 2 * padding, height: elementHeight)
        
        categoryLabel.frame = CGRect(x: padding, y: headlineField.frame.maxY + padding, width: view.frame.size.width - 2 * padding, height: labelHeight)
        categoryField.frame = CGRect(x: padding, y: categoryLabel.frame.maxY + 5, width: view.frame.size.width - 2 * padding, height: elementHeight)
        
        segmentedControlLabel.frame = CGRect(x: padding, y: categoryField.frame.maxY + padding, width: view.frame.size.width - 2 * padding, height: labelHeight)
        segmentedControl.frame = CGRect(x: padding, y: segmentedControlLabel.frame.maxY + 5, width: view.frame.size.width - 2 * padding, height: elementHeight)
        
        descLabel.frame = CGRect(x: padding, y: segmentedControl.frame.maxY + padding, width: view.frame.size.width - 2 * padding, height: labelHeight)
        descField.frame = CGRect(x: padding, y: descLabel.frame.maxY + 5, width: view.frame.size.width - 2 * padding, height: elementHeight * 2)
        
        oldCityLabel.frame = CGRect(x: padding, y: descField.frame.maxY + padding, width: view.frame.size.width - 2 * padding, height: labelHeight)
        oldCityField.frame = CGRect(x: padding, y: oldCityLabel.frame.maxY + 5, width: view.frame.size.width - 2 * padding, height: elementHeight)
        
        currentCityLabel.frame = CGRect(x: padding, y: oldCityField.frame.maxY + padding, width: view.frame.size.width - 2 * padding, height: labelHeight)
        currentCityField.frame = CGRect(x: padding, y: currentCityLabel.frame.maxY + 5, width: view.frame.size.width - 2 * padding, height: elementHeight)
        
        agePickerLabel.frame = CGRect(x: padding, y: currentCityField.frame.maxY + padding, width: view.frame.size.width - 2 * padding, height: labelHeight)
        agePickerField.frame = CGRect(x: view.frame.size.width - 2 * elementHeight - padding, y: agePickerLabel.frame.maxY + 5, width: elementHeight * 2, height: elementHeight)
        
        dateLabel.frame = CGRect(x: padding, y: agePickerField.frame.maxY + padding, width: view.frame.size.width - 2 * padding, height: labelHeight)
        datePicker.frame = CGRect(x: padding, y: dateLabel.frame.maxY + 5, width: view.frame.size.width - 2 * padding, height: elementHeight)

        photoLabel.frame = CGRect(x: padding, y: datePicker.frame.maxY + padding, width: view.frame.size.width - 2 * padding, height: labelHeight)
        photoButton.frame = CGRect(x: padding, y: photoLabel.frame.maxY + 5, width: view.frame.size.width - 2 * padding, height: elementHeight)
        photoStackView.frame = CGRect(x: padding, y: photoButton.frame.maxY + 10, width: view.frame.size.width - 2 * padding, height: 100)
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: photoStackView.frame.maxY + 60)
    }


    
    func setupPickers() {

        agePickerField.inputAccessoryView = toolbar
        headlineField.inputAccessoryView = toolbar
        oldCityField.inputAccessoryView = toolbar
        currentCityField.inputAccessoryView = toolbar
        categoryField.inputAccessoryView = toolbar
        descField.inputAccessoryView = toolbar
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    @objc func exitButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func changeTitle(newTitle: String) {
        self.titleLabel.text = newTitle
    }
    
    @objc private func photoButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]
        present(imagePicker, animated: true, completion: nil)
    }

    
    func formatDate(day: String, month: String, year: String) -> String {
        let daySuffix: String
        switch day {
        case "01", "21", "31": daySuffix = "st"
        case "02", "22": daySuffix = "nd"
        case "03", "23": daySuffix = "rd"
        default: daySuffix = "th"
        }
        return "\(month) \(day)\(daySuffix) \(year)"
    }
    
    // Function to check if all fields are filled
    private func areAllFieldsValid() -> Bool {
        if headlineField.text?.isEmpty ?? true {
            return false
        }
        if categoryField.text?.isEmpty ?? true {
            return false
        }
        if oldCityField.text?.isEmpty ?? true {
            return false
        }
        if currentCityField.text?.isEmpty ?? true {
            return false
        }
        if descField.text.isEmpty || descField.text == "פרט לפרטים על מנת שנוכל להבין טוב יותר..." || descField.text == "תאר את הבקשה..." {
            return false
        }
        return true
    }
    
    private func showValidationErrorAlert() {
        let alert = UIAlertController(title: "שגיאה", message: "אנא מלא את כל השדות הנדרשים", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "אישור", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @objc func saveButtonTapped() {
        guard let user_id = Auth.auth().currentUser?.uid else {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            print("User is not logged in")
            return
        }
        
        // Validate all required fields
        if !areAllFieldsValid() {
            // If validation fails, show an alert and return
            showValidationErrorAlert()
            return
        }

        // Retrieve user phone and email from UserDefaults
        let userDefaults = UserDefaults.standard
        let userPhone = userDefaults.string(forKey: "phone") ?? ""
        let userEmail = userDefaults.string(forKey: "email") ?? ""

        // Collect images from photoStackView
        let images = photoStackView.arrangedSubviews.compactMap { ($0 as? UIImageView)?.image }

        // Check if editing an existing request
        if let existingRequest = requestToEdit {
            updateRequest(existingRequest: existingRequest, userId: user_id, images: images, userEmail: userEmail, userPhone: userPhone)
        } else {
            createNewRequest(userId: user_id, images: images, userEmail: userEmail, userPhone: userPhone)
        }
    }

    // Function to handle new request creation
    private func createNewRequest(userId: String, images: [UIImage], userEmail: String, userPhone: String) {
        if images.isEmpty {
            // No images, directly create and insert the request
            let newRequest = UserRequest(
                id: UUID().uuidString,
                isDemand: self.isDemand,
                isPublic: self.segmentedControl.selectedSegmentIndex == 0,
                title: self.headlineField.text ?? "",
                categories: [self.categoryField.text ?? ""],
                oldCity: self.oldCityField.text,
                currentCity: self.currentCityField.text,
                age: self.agePickerField.text ?? "",
                date: self.datePicker.date,
                description: self.descField.text,
                user_id: userId,
                email: userEmail,
                phone: userPhone,
                imageUrls: [],
                views: 0,
                mailViews: 0,
                phoneViews: 0,
                mailsSent: 0,
                isCompleted: false,
                feedback: ""
            )
            
            DatabaseManager.shared.insertUserRequest(userId: userId, userRequest: newRequest) { success in
                if success {
                    print("User request inserted successfully")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("Failed to insert user request")
                    let alert = UIAlertController(title: "Error", message: "Failed to save your request. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            // There are images, upload them first
            StorageManager.shared.uploadRequestImages(requestId: UUID().uuidString, images: images) { [weak self] result in
                switch result {
                case .success(let imageUrls):
                    let newRequest = UserRequest(
                        id: UUID().uuidString,
                        isDemand: self?.isDemand ?? false,
                        isPublic: self?.segmentedControl.selectedSegmentIndex == 0,
                        title: self?.headlineField.text ?? "",
                        categories: [self?.categoryField.text ?? ""],
                        oldCity: self?.oldCityField.text,
                        currentCity: self?.currentCityField.text,
                        age: self?.agePickerField.text ?? "",
                        date: self?.datePicker.date,
                        description: self?.descField.text,
                        user_id: userId,
                        email: userEmail,
                        phone: userPhone,
                        imageUrls: imageUrls,
                        views: 0,
                        mailViews: 0,
                        phoneViews: 0,
                        mailsSent: 0,
                        isCompleted: false,
                        feedback: ""
                    )
                    
                    DatabaseManager.shared.insertUserRequest(userId: userId, userRequest: newRequest) { success in
                        if success {
                            print("User request inserted successfully")
                            self?.dismiss(animated: true, completion: nil)
                        } else {
                            print("Failed to insert user request")
                            let alert = UIAlertController(title: "Error", message: "Failed to save your request. Please try again.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(alert, animated: true, completion: nil)
                        }
                    }

                case .failure(let error):
                    print("Failed to upload images: \(error)")
                    let alert = UIAlertController(title: "Error", message: "Failed to upload images. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    // Function to handle request update
    private func updateRequest(existingRequest: UserRequest, userId: String, images: [UIImage], userEmail: String, userPhone: String) {
        if images.isEmpty {
            // Update the request without images
            let updatedRequest = UserRequest(
                id: existingRequest.id,
                isDemand: self.isDemand,
                isPublic: self.segmentedControl.selectedSegmentIndex == 0,
                title: self.headlineField.text ?? "",
                categories: [self.categoryField.text ?? ""],
                oldCity: self.oldCityField.text,
                currentCity: self.currentCityField.text,
                age: self.agePickerField.text ?? "",
                date: self.datePicker.date,
                description: self.descField.text,
                user_id: userId,
                email: userEmail,
                phone: userPhone,
                imageUrls: existingRequest.imageUrls, // Keep existing image URLs
                views: existingRequest.views,
                mailViews: existingRequest.mailViews,
                phoneViews: existingRequest.phoneViews,
                mailsSent: existingRequest.mailsSent,
                isCompleted: false,
                feedback: existingRequest.feedback
            )
            
            DatabaseManager.shared.updateUserRequest(userId: userId, userRequest: updatedRequest) { success in
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
        } else {
            // Update the request and upload new images
            StorageManager.shared.uploadRequestImages(requestId: existingRequest.id, images: images) { [weak self] result in
                switch result {
                    /*
                     var isCompleted: Bool
                     var feedback: String
                     */
                case .success(let imageUrls):
                    let updatedRequest = UserRequest(
                        id: existingRequest.id,
                        isDemand: self?.isDemand ?? false,
                        isPublic: self?.segmentedControl.selectedSegmentIndex == 0,
                        title: self?.headlineField.text ?? "",
                        categories: [self?.categoryField.text ?? ""],
                        oldCity: self?.oldCityField.text,
                        currentCity: self?.currentCityField.text,
                        age: self?.agePickerField.text ?? "",
                        date: self?.datePicker.date,
                        description: self?.descField.text,
                        user_id: userId,
                        email: userEmail,
                        phone: userPhone,
                        imageUrls: imageUrls,
                        views: existingRequest.views,
                        mailViews: existingRequest.mailViews,
                        phoneViews: existingRequest.phoneViews,
                        mailsSent: existingRequest.mailsSent,
                        isCompleted: false,
                        feedback: existingRequest.feedback
                    )
                    
                    DatabaseManager.shared.updateUserRequest(userId: userId, userRequest: updatedRequest) { success in
                        if success {
                            print("User request updated successfully")
                            self?.dismiss(animated: true, completion: nil)
                        } else {
                            print("Failed to update user request")
                            let alert = UIAlertController(title: "Error", message: "Failed to update your request. Please try again.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self?.present(alert, animated: true, completion: nil)
                        }
                    }

                case .failure(let error):
                    print("Failed to upload images: \(error)")
                    let alert = UIAlertController(title: "Error", message: "Failed to upload images. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }



    private func showUploadError() {
        let alert = UIAlertController(title: "Error", message: "Failed to upload images. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == categoryField {
            presentCategoriesVC()
            return false
        }
        return true
    }
    
    // UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        registerForKeyboardNotifications()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
        unregisterForKeyboardNotifications()
    }



    
    private func presentCategoriesVC() {
        let categoriesVC = categoriesVC()
        //TODO: when you add new categories : CategoryManager.shared.insertCategories()
        categoriesVC.categories = CategoryManager.shared.getCategories()
        categoriesVC.allowMultiple = false // or true if you want to allow multiple selection

        categoriesVC.didSelectCategory = { [weak self] selectedCategory in
            self?.categoryField.text = selectedCategory?.category
        }

        let navigationController = UINavigationController(rootViewController: categoriesVC)
        navigationController.modalPresentationStyle = .fullScreen

        self.present(navigationController, animated: true, completion: nil)
    }



    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == agePickerField {
            headlineField.becomeFirstResponder()
        } else if textField == headlineField {
            oldCityField.becomeFirstResponder()
        } else if textField == oldCityField {
            currentCityField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @objc private func previousButtonTapped() {
        if headlineField.isFirstResponder {
            agePickerField.becomeFirstResponder()
        } else if oldCityField.isFirstResponder {
            headlineField.becomeFirstResponder()
        } else if currentCityField.isFirstResponder {
            oldCityField.becomeFirstResponder()
        }
    }

    @objc private func nextButtonTapped() {
        if agePickerField.isFirstResponder {
            headlineField.becomeFirstResponder()
        } else if headlineField.isFirstResponder {
            oldCityField.becomeFirstResponder()
        } else if oldCityField.isFirstResponder {
            currentCityField.becomeFirstResponder()
        }  else if categoryField.isFirstResponder {
            categoryField.resignFirstResponder()
        }
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

}

extension VolunteerVC : UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextView) -> Bool {
        textField.resignFirstResponder()
        view.endEditing(true)
        return true
    }
    
    // UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "פרטים נוספים על ההתנדבות" || textView.text == "תאר את הבקשה..."  {
            textView.text = nil
        }
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .black
        }
        activeField = textView
        registerForKeyboardNotifications()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        NotificationCenter.default.removeObserver(self)
        if textView.text.isEmpty {
            textView.text = "תאר את הבקשה..."
            textView.textColor = UIColor.lightGray
        }
        unregisterForKeyboardNotifications()
        activeField = nil
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
        guard let activeField = activeField else { return }
        
        let bottomOfField = activeField.convert(activeField.bounds, to: self.view).maxY
        let topOfKeyboard = self.view.frame.height - keyboardHeight
        
        if showing {
            // If the active field is below the keyboard, move the view up
            if bottomOfField > topOfKeyboard {
                let offset = bottomOfField - topOfKeyboard + 10 // 10 points of padding
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = -offset
                }
            }
        } else {
            // Reset the view when the keyboard is hidden
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = 0
            }
        }
    }
}

extension VolunteerVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            addImageToStackView(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
}
