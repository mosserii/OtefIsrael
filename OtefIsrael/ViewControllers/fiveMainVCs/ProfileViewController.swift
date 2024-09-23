//
//  ProfileViewController.swift
//  DestinationSmartFinder
//
//  Created by Zohar Mosseri on 20/02/2024.
//

import Foundation
import UIKit
import AVFoundation
import FirebaseAuth
import MessageUI
import SDWebImage


class ProfileViewController: UIViewController {
        
    var userRequests = [UserRequest]()
    let requestsTableViewController = UITableViewController(style: .plain)
    private var imageChanged: Bool = false
    
    var tableView1 = UITableView()
    var selectOptions = ["צור קשר", "הגדרות", "פייסבוק", "מפתח האפליקציה", "דיווח על מישהו שזקוק לעזרה", "התנתקות", "מחק חשבון"]
    
    private let selectOptionSymbols: [UIImage?] = [
        UIImage(systemName: "envelope")?.withRenderingMode(.alwaysTemplate),
        UIImage(systemName: "gear")?.withRenderingMode(.alwaysTemplate),
        UIImage(named: "facebook-square-fill")?.withRenderingMode(.alwaysTemplate),
        UIImage(named: "linkedin-fill")?.withRenderingMode(.alwaysTemplate),
        UIImage(systemName: "exclamationmark.bubble")?.withRenderingMode(.alwaysTemplate),
        UIImage(systemName: "door.left.hand.open")?.withRenderingMode(.alwaysTemplate),
        UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
    ]
    
    let headerView = UIView()
    
    var headerImageView: UIImageView = {
        let headerImageView = UIImageView()
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.image = UIImage(named: "image2")
        headerImageView.clipsToBounds = true
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        return headerImageView
    }()
    
    //todo delete
    let segmentImages: [UIImage] = [
        UIImage(named: "launchLogo")!, //POSTERSANN, posterOnWall
    ]

    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 4
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowRadius = 15
        return imageView
    }() {
        didSet {
            // This block will be executed when imageView.image changes
            handleImageChange()
        }
    }
    
    private let nameLabel : UILabel = {
        let field = UILabel()
        field.layer.cornerRadius = 12
        field.text = "שם:"
        field.textAlignment = .center
        field.shadowOffset = CGSize(width: 10, height: 10)
        field.font = .boldSystemFont(ofSize: 24)
        return field
    }()

    private let emailLabel : UILabel = {
        let field = UILabel()
        field.layer.cornerRadius = 12
        field.text = "אימייל:"
        field.font = .boldSystemFont(ofSize: 20)
        field.textAlignment = .center
        return field
    }()
    
    private let phoneLabel : UILabel = {
        let field = UILabel()
        field.layer.cornerRadius = 12
        field.text = "טלפון:"
        field.font = .boldSystemFont(ofSize: 20)
        field.textAlignment = .center
        return field
    }()
    
    private let currentCityLabel : UILabel = {
        let field = UILabel()
        field.layer.cornerRadius = 12
        field.text = "יישוב נוכחי:"
        field.font = .boldSystemFont(ofSize: 20)
        field.textAlignment = .center
        return field
    }()
    
    private let oldCityLabel : UILabel = {
        let field = UILabel()
        field.layer.cornerRadius = 12
        field.text = "יישוב בת.ז:"
        field.font = .boldSystemFont(ofSize: 20)
        field.textAlignment = .center
        return field
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleLabel = UILabel()
        titleLabel.text = "פרופיל"
        titleLabel.textAlignment = .right // Align the text to the right
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        titleLabel.sizeToFit()

        // Set the custom UILabel as the title view
        self.navigationItem.titleView = titleLabel

        // Enable large titles if needed
        navigationController?.navigationBar.prefersLargeTitles = true
        
        requestsTableViewController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Create a table view controller
        requestsTableViewController.tableView.delegate = self
        requestsTableViewController.tableView.dataSource = self
        
//        tableView1.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView1.register(InfoTableViewCell.self, forCellReuseIdentifier: "InfoTableViewCell")
        tableView1.delegate = self
        tableView1.dataSource = self

        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
        
        view.addSubview(tableView1)
        headerView.addSubview(headerImageView)
        headerView.addSubview(imageView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(emailLabel)
        headerView.addSubview(phoneLabel)
        headerView.addSubview(currentCityLabel)
        headerView.addSubview(oldCityLabel)

        // Set the background color of headerView to blue
//        headerView.backgroundColor = UIColor.red
        headerImageView.frame = headerView.bounds

        
        headerView.sendSubviewToBack(headerImageView) // as a background

        
        setApperance()
        
        DatabaseManager.shared.checkIfUserIsAdmin { [weak self] isAdmin in
            guard let self = self else { return }
            if isAdmin {
                self.addAdminButton()
            }
        }
    }
    
    private func addAdminButton() {
        let adminButton = UIBarButtonItem(title: "Admin", style: .plain, target: self, action: #selector(openAdminNotifications))
        navigationItem.leftBarButtonItem = adminButton
    }

    @objc private func openAdminNotifications() {
        let adminNotificationsVC = AdminNotificationsVC()
        let navController = UINavigationController(rootViewController: adminNotificationsVC)
        present(navController, animated: true, completion: nil)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        validateAuth()
        setApperance()
        
        guard let user_id = Auth.auth().currentUser?.uid else {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            print("User is not logged in")
            return
        }
    }
    
    
    func downloadImageView(imageX : UIImageView, url : URL){
        
        URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageX.image = image
            }
        }).resume()
    }
    
    func setApperance(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
              let user_id = UserDefaults.standard.value(forKey: "User ID") as? String,
              let name = UserDefaults.standard.value(forKey: "name") as? String
        else{
            print("cant retrieve user details from UserDefaults in profile")
            return
        }
        
        let fileName = user_id + "_profile_picture.png"
        let path = "profilePics/" + fileName

        if let originalCity = UserDefaults.standard.value(forKey: "originalCity") as? String,
           let currentCity = UserDefaults.standard.value(forKey: "currentCity") as? String{
            currentCityLabel.text = "יישוב נוכחי : \(currentCity)"
            oldCityLabel.text = "יישוב בת.ז : \(originalCity)"
        }
        if let phone = UserDefaults.standard.value(forKey: "phone") as? String{
            phoneLabel.text = "טלפון : \(phone)"
        }
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let url):
                
                //strongSelf.downloadImageView(imageX: strongSelf.imageView, url: url)
                strongSelf.imageView.sd_setImage(with: url, completed: nil)
                print("sd_setImage succeded")
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        
        nameLabel.text = "שם : \(name)"
        //self.navigationItem.title = name
        emailLabel.text = "אימייל : \(email)"

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        // Layout the subviews of the headerView
        let size = view.bounds.width / 2.2
        imageView.frame = CGRect(x: (view.bounds.width - size) / 2, y: 10, width: size, height: size)
        nameLabel.frame = CGRect(x: 30, y: imageView.frame.maxY + 10, width: view.bounds.width - 60, height: 32)
        emailLabel.frame = CGRect(x: 30, y: nameLabel.frame.maxY + 10, width: view.bounds.width - 60, height: 32)
        phoneLabel.frame = CGRect(x: 30, y: emailLabel.frame.maxY + 10, width: view.bounds.width - 60, height: 32)
        currentCityLabel.frame = CGRect(x: 30, y: phoneLabel.frame.maxY + 10, width: view.bounds.width - 60, height: 32)
        oldCityLabel.frame = CGRect(x: 30, y: currentCityLabel.frame.maxY + 10, width: view.bounds.width - 60, height: 32)

        // Set the frame for the headerView based on its subviews
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: oldCityLabel.frame.maxY + 20 + 10)
        
        // Assign the headerView to the tableHeaderView property of your tableView
        tableView1.tableHeaderView = headerView
        
        // Layout the tableView to fill the entire view controller's view
        tableView1.frame = view.bounds
        
        imageView.layer.cornerRadius = imageView.width/2.0
    }
    
    
    @objc private func logoutButtonTapped(){
        
        let actionSheet = UIAlertController(title: "", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "התנתקות", style: .destructive, handler: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            UserDefaults.standard.setValue(nil, forKey: "email")
            UserDefaults.standard.setValue(nil, forKey: "User ID")
            UserDefaults.standard.setValue(nil, forKey: "name")
            UserDefaults.standard.setValue(nil, forKey: "originalCity")
            UserDefaults.standard.setValue(nil, forKey: "currentCity")
            UserDefaults.standard.setValue(nil, forKey: "phone")
            strongSelf.imageView.image = UIImage(systemName: "person.circle")
            strongSelf.emailLabel.text = " "
            strongSelf.phoneLabel.text = " "
            strongSelf.currentCityLabel.text = " "
            strongSelf.oldCityLabel.text = " "
            strongSelf.nameLabel.text = " "
            
            do {//todo big check here (about vc on success)
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
            catch {
                print("Failed to התנתקות")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        self.present(actionSheet, animated: true)
    }
}


extension ProfileViewController: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView1{
            return selectOptions.count
        }
        else{
            let numberOfRequests = userRequests.count
            return numberOfRequests == 0 ? 1 : numberOfRequests //1 cell for showing "Create Request" or the number of requests
        }
    }

//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let option = selectOptions[indexPath.row]
//        cell.textLabel?.text = option
//        if let symbol = selectOptionSymbols[indexPath.row] {
//            cell.imageView?.image = symbol
//            cell.imageView?.tintColor = .black
//        }
//        cell.accessoryType = .disclosureIndicator
//        return cell
//        
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell", for: indexPath) as! InfoTableViewCell
        let option = selectOptions[indexPath.row]
        cell.customLabel.text = option
        
        if let symbol = selectOptionSymbols[indexPath.row] {
            cell.customImageView.image = symbol
        }
        
        return cell
    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Handle cell selection based on the selected option
        switch selectOptions[indexPath.row] {
        case "Passengers Details":
            print("Terms of Use")
        case "Payment Methods":
            print("Payment Methods screen to view/edit/add Payments")
        case "צור קשר":
            // Check if the device can send email
            if MFMailComposeViewController.canSendMail() {
                // Create a mail composer
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self
                mailComposer.setToRecipients(["milis1michael@gmail.com"])
                mailComposer.setSubject("יצירת קשר דרך אפליקציית עוטף ישראל")
                present(mailComposer, animated: true, completion: nil)
            } else {
                // Show an alert if the device can't send email
                let alertController = UIAlertController(title: "שגיאה", message: "המכשיר שלך אינו תומך בשליחת מיילים", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "אוקיי", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        case "פייסבוק":
            let facebookGroupURL = "https://www.facebook.com/groups/3538241003109652/"
            
            // Check if the URL can be opened
            if let url = URL(string: facebookGroupURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Handle the error if the URL is invalid
                let alert = UIAlertController(title: "שגיאה", message: "לא ניתן לפתוח את קבוצת הפייסבוק", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "אוקיי", style: .default))
                present(alert, animated: true)
            }
        case "מפתח האפליקציה":
            let linkedInProfileURL = "https://www.linkedin.com/in/zohar-mosseri"
            
            // Check if the URL can be opened
            if let url = URL(string: linkedInProfileURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Handle the error if the URL is invalid
                let alert = UIAlertController(title: "שגיאה", message: "לא ניתן לפתוח לינקדאין, מפתח האפליקציה הוא זוהר מוסרי.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "אוקיי", style: .default))
                present(alert, animated: true)
            }
        case "התנתקות":
            self.logoutButtonTapped()
        case "מחק חשבון":
            self.deleteAccountTapped()
        default:
            break
        }
    }
    
    // MFMailComposeViewControllerDelegate method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func presentQuizVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let createRequestVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            present(createRequestVC, animated: true, completion: nil)
        }
    }
}

extension ProfileViewController{
    @objc private func deleteAccountTapped() {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.sendDeletionRequestEmail()
        }))
        present(alert, animated: true, completion: nil)
    }

    private func sendDeletionRequestEmail() {
        guard let user = Auth.auth().currentUser else {
            return
        }

        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(["freedom.now.app@gmail.com"])
            mailComposer.setSubject("User Account Deletion Request")
            mailComposer.setMessageBody("User with ID: \(user.uid) and email: \(user.email ?? "") has requested account deletion. Please delete their data from the database manually.", isHTML: false)
            present(mailComposer, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Your device doesn't support sending emails, please contact us at freedom.now.app@gmail.com.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    private func deleteUserFromAuth() {
        guard let user = Auth.auth().currentUser else {
            return
        }

        user.delete { error in
            if let error = error {
                // Handle error
                print("Error deleting user: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: "There was an error deleting your account. Please try again, or contact us.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }

            // Sign out the user and navigate to the login screen
            do {
                try Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
                let alert = UIAlertController(title: "Error", message: "There was an error signing out. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc private func didTapChangeProfilePic() {
        self.imageChanged = false
        self.presentPhotoActionSheet()
    }
    
    func handleImageChange(){
        print("imageChanged")
        
        // upload image
        guard let image = self.imageView.image,
            let data = image.pngData() else {
                return
        }
        
        guard let user_id = UserDefaults.standard.value(forKey: "User ID") as? String else{
            print("Can't retrieve user details from UserDefaults in profile")
            return
        }
        
        let fileName = user_id + "_profile_picture.png"
        
        DispatchQueue.main.async {
            StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let downloadUrl):
                    UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                    print("uploadProfilePicture succeded, URL : " + downloadUrl)
                case .failure(let error):
                    DispatchQueue.main.async {
                        if let storageError = error as? StorageManager.StorageErrors, storageError == .fileTooLarge {
                            let alert = UIAlertController(title: "Attention", message: "Please upload a picture smaller than 10MB", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
                            strongSelf.present(alert, animated: true)
                        }
                        print("Storage manager error: \(error)")
                    }
                }
            })
        }
    }

    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in

                                                self?.presentCamera()

        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Remove Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.deletePhoto()
        }))
         
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera

        // Request camera permission
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let strongSelf = self else { return }
            if granted {
                DispatchQueue.main.async {
                    vc.delegate = self
                    vc.allowsEditing = true
                    strongSelf.present(vc, animated: true)
                }
            } else {
                // Handle denied access (e.g., show an alert)
                print("Camera access denied")
            }
        }
    }

    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func deletePhoto() {
        DispatchQueue.main.async {
            self.imageView.image = UIImage(systemName: "person.circle")
            self.imageView = UIImageView(image: UIImage(systemName: "person.circle"))
            self.imageChanged = true
        }
    }
     
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        let squareImage = cropToSquare(image: selectedImage)
        self.imageView.image = squareImage
        self.imageView = UIImageView(image: squareImage)
        self.imageView.image = squareImage
    }
    
    func cropToSquare(image: UIImage) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        let edge = min(originalWidth, originalHeight)
        
        let posX = (originalWidth - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0

        let rect = CGRect(x: posX, y: posY, width: edge, height: edge)

        let cgImage = image.cgImage!.cropping(to: rect)!
        let croppedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)

        return croppedImage
    }
    
    func makeCircularImage(from image: UIImage, size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let imageView = UIImageView(frame: rect)
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        imageView.layer.cornerRadius = size.width / 2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let circularImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return circularImage ?? image
    }

    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

