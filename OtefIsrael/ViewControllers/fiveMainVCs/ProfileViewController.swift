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
    var selectOptions = ["הבקשות שלי", "Passengers Details", "Payment Methods", "Contact Us", "App Preferences", "Log Out"]
    
    private let selectOptionSymbols: [UIImage?] = [
        UIImage(systemName: "airplane")?.withRenderingMode(.alwaysTemplate),
        UIImage(systemName: "person.2")?.withRenderingMode(.alwaysTemplate),
        UIImage(systemName: "creditcard")?.withRenderingMode(.alwaysTemplate),
        UIImage(systemName: "envelope")?.withRenderingMode(.alwaysTemplate),
        UIImage(systemName: "gear")?.withRenderingMode(.alwaysTemplate),
        UIImage(systemName: "door.left.hand.open")?.withRenderingMode(.alwaysTemplate)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "פרופיל"
        navigationController?.navigationBar.prefersLargeTitles = true

        
        requestsTableViewController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Create a table view controller
        requestsTableViewController.tableView.delegate = self
        requestsTableViewController.tableView.dataSource = self
        
        tableView1.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        
        // Set the background color of headerView to blue
//        headerView.backgroundColor = UIColor.red
        headerImageView.frame = headerView.bounds

        
        headerView.sendSubviewToBack(headerImageView) // as a background

        
        setApperance()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        validateAuth()
        setApperance()
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
        
        nameLabel.text = name
        self.navigationItem.title = name
        emailLabel.text = email
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        // Layout the subviews of the headerView
        let size = view.bounds.width / 2.2
        imageView.frame = CGRect(x: (view.bounds.width - size) / 2, y: 10, width: size, height: size)
        nameLabel.frame = CGRect(x: 30, y: imageView.frame.maxY + 10, width: view.bounds.width - 60, height: 32)
        emailLabel.frame = CGRect(x: 30, y: nameLabel.frame.maxY + 10, width: view.bounds.width - 60, height: 32)
        
        // Set the frame for the headerView based on its subviews
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: emailLabel.frame.maxY + 20 + 10)
        
        // Assign the headerView to the tableHeaderView property of your tableView
        tableView1.tableHeaderView = headerView
        
        // Layout the tableView to fill the entire view controller's view
        tableView1.frame = view.bounds
        
        imageView.layer.cornerRadius = imageView.width/2.0
    }
    
    
    @objc private func logoutButtonTapped(){
        
        let actionSheet = UIAlertController(title: "", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            UserDefaults.standard.setValue(nil, forKey: "email")
            UserDefaults.standard.setValue(nil, forKey: "User ID")
            UserDefaults.standard.setValue(nil, forKey: "name")
            strongSelf.imageView.image = UIImage(systemName: "person.circle")
            strongSelf.emailLabel.text = " "
            strongSelf.nameLabel.text = " "
            
            do {//todo big check here (about vc on success)
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
            catch {
                print("Failed to log out")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        self.present(actionSheet, animated: true)
    }
    
    ///if user clicks on his requests so he can see all his requests
    private func showMyRequests(){
        
        var userRequestsIDs = [String]()
        
        guard let user_id = UserDefaults.standard.value(forKey: "User ID") as? String else{
            print("Can't retrieve user details from UserDefaults in profile")
            return
        }
        DatabaseManager.shared.getUserData(with: user_id) { [weak self] (user) in
            guard let strongSelf = self else{
                return
            }
            if let user = user {
                userRequestsIDs = user.requests
            } else {
                print("User not found in showMyRequests")
            }
            
            strongSelf.userRequests = []
                // TODO: do it
//            for requestID in userRequestsIDs {
//                if requestID != "dummy"{
//                    DatabaseManager.shared.getRequestData(with: requestID) { [weak self] (request) in
//                        guard let strongSelf = self else{
//                            return
//                        }
//                        if let specificRequest = request {
//                            strongSelf.userRequests.append(specificRequest)
//                        } else {
//                            print("Request not found in getUserRequests()")
//                        }
//                    }
//                }
//            }
            
            if strongSelf.requestsTableViewController.tableView != nil {
                DispatchQueue.main.async {
                    strongSelf.requestsTableViewController.tableView?.reloadData()
                }
            } else {
                print("strongSelf.tableView is nil")
            }
            
            // Create and configure the alert controller, depends if no requests or there are some requests to choose from
            let alertController = strongSelf.userRequests.isEmpty ? (UIAlertController(title: "No Requests", message: "Create a new request!", preferredStyle: .actionSheet)) : (UIAlertController(title: "My Requests", message: "Choose an request!", preferredStyle: .actionSheet))
            alertController.setValue(strongSelf.requestsTableViewController, forKey: "contentViewController")
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            strongSelf.present(alertController, animated: true, completion: nil)
        }
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableView1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let option = selectOptions[indexPath.row]
            cell.textLabel?.text = option
            if let symbol = selectOptionSymbols[indexPath.row] {
                cell.imageView?.image = symbol
                cell.imageView?.tintColor = .black
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        else{ // my requests
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.textColor = .link
            cell.textLabel?.textAlignment = .center
            
            if userRequests.isEmpty {
                cell.textLabel?.text = "Create Request"
            } else {
                // Display cells with request details
                let request = userRequests[indexPath.row]
                cell.textLabel?.text = request.title
                cell.textLabel?.textAlignment = .left
                let originalImage = segmentImages[0]
                let imageSize = CGSize(width: 30, height: 30) // Set the desired size
                let circularImage = makeCircularImage(from: originalImage, size: imageSize)
                cell.imageView?.image = circularImage
                //let scaledImage = originalImage.resize(to: imageSize)
                //cell.imageView?.image = scaledImage
                
            }
            return cell
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == tableView1{
            
            // Handle cell selection based on the selected option
            switch selectOptions[indexPath.row] {
            case "My Requests":
                self.showMyRequests()
            case "Passengers Details":
                print("Terms of Use")
            case "Payment Methods":
                print("Payment Methods screen to view/edit/add Payments")
            case "Contact Us":
                // Check if the device can send email
                if MFMailComposeViewController.canSendMail() {
                    // Create a mail composer
                    let mailComposer = MFMailComposeViewController()
                    mailComposer.mailComposeDelegate = self
                    mailComposer.setToRecipients(["zohar@gmail.com"])
                    mailComposer.setSubject("Contact Us from BringThemHomeNow App")
                    present(mailComposer, animated: true, completion: nil)
                } else {
                    // Show an alert if the device can't send email
                    let alertController = UIAlertController(title: "Error", message: "Your device doesn't support sending emails.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alertController, animated: true, completion: nil)
                }
            case "Terms of Use":
                print("Terms of Use")
            case "Privacy Policy":
                // Navigate to the Privacy Policy page
                performSegue(withIdentifier: "PrivacyPolicySegueIdentifier", sender: nil)
            case "Log Out":
                self.logoutButtonTapped()
            default:
                break
            }
        }
        else{ //requests table view
            if !userRequests.isEmpty {
                let selectedRequest = userRequests[indexPath.row]
                // Dismiss any existing view controller before presenting RequestDetailsViewController
                if let presentedViewController = presentedViewController {
                    presentedViewController.dismiss(animated: true) {
                        self.presentRequestDetails(for: selectedRequest)
                    }
                } else {
                    // No view controller is currently being presented, proceed to present RequestDetailsViewController
                    presentRequestDetails(for: selectedRequest)
                }
            }
            else{ //isEmpty
                // Dismiss any existing view controller before presenting RequestDetailsViewController
                if let presentedViewController = presentedViewController {
                    presentedViewController.dismiss(animated: true) {
                        self.presentQuizVC()
                    }
                } else {
                    // No view controller is currently being presented, proceed to present RequestDetailsViewController
                    presentQuizVC()
                }
            }
        }
    }
    
    // MFMailComposeViewControllerDelegate method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func presentRequestDetails(for request: UserRequest) {
//        let reviewBookingVC = ReviewBookingVC()
//        reviewBookingVC.destinationName = request.destination
//        reviewBookingVC.title = "Your Request to \(request.destination)"
//        reviewBookingVC.request = request
//        reviewBookingVC.isRequest = true
//        let navigationController = UINavigationController(rootViewController: reviewBookingVC)
//        present(navigationController, animated: true, completion: nil)
        
    }
    
    private func presentQuizVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let createRequestVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            present(createRequestVC, animated: true, completion: nil)
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

