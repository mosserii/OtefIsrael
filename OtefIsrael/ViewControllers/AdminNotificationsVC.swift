import UIKit
import FirebaseAuth
import FirebaseDatabase

struct AdminNotification {
    let title: String
    let body: String
    let timestamp: Double
    let requestId: String
}

class AdminNotificationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var notifications = [AdminNotification]()
    var userRequests = [UserRequest]() // To store the UserRequests related to the notifications
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Admin Notifications"
        setupTableView()
        fetchNotifications()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    // Fetch notifications for the admin
    func fetchNotifications() {
        guard let adminId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("notifications").child(adminId)
        
        ref.observe(.value) { snapshot in
            self.notifications.removeAll()
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                if let notificationData = child.value as? [String: Any],
                   let title = notificationData["title"] as? String,
                   let body = notificationData["body"] as? String,
                   let timestamp = notificationData["timestamp"] as? Double,
                   let requestId = notificationData["requestId"] as? String {
                    
                    let notification = AdminNotification(title: title, body: body, timestamp: timestamp, requestId: requestId)
                    self.notifications.append(notification)
                }
            }
            self.tableView.reloadData()
            self.fetchUserRequests() // Fetch the related UserRequests once notifications are loaded
        }
    }
    
    // Fetch UserRequest objects related to the notifications
    func fetchUserRequests() {
        let ref = Database.database().reference().child("requests")
        
        for notification in notifications {
            ref.child(notification.requestId).observeSingleEvent(of: .value) { snapshot in
                if let requestData = snapshot.value as? [String: Any] {
                    if let request = self.mapUserRequest(from: requestData, requestId: notification.requestId) {
                        self.userRequests.append(request)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    // Map UserRequest from Firebase snapshot
    private func mapUserRequest(from requestData: [String: Any], requestId: String) -> UserRequest? {
        guard let isDemand = requestData["isDemand"] as? Bool,
              let isPublic = requestData["isPublic"] as? Bool,
              let title = requestData["title"] as? String,
              let categories = requestData["categories"] as? [String],
              let userId = requestData["user_id"] as? String,
              let views = requestData["views"] as? Int,
              let mailViews = requestData["mailViews"] as? Int,
              let phoneViews = requestData["phoneViews"] as? Int,
              let mailsSent = requestData["mailsSent"] as? Int,
              let isCompleted = requestData["isCompleted"] as? Bool,
              let feedback = requestData["feedback"] as? String else {
            return nil
        }
        
        let oldCity = requestData["oldCity"] as? String
        let currentCity = requestData["currentCity"] as? String
        let age = requestData["age"] as? String
        let date = requestData["date"] as? TimeInterval
        let description = requestData["description"] as? String
        let email = requestData["email"] as? String
        let phone = requestData["phone"] as? String
        let imageUrls = requestData["imageUrls"] as? [String]
        
        return UserRequest(
            id: requestId,
            isDemand: isDemand,
            isPublic: isPublic,
            title: title,
            categories: categories,
            oldCity: oldCity,
            currentCity: currentCity,
            age: age,
            date: date != nil ? Date(timeIntervalSince1970: date!) : nil,
            description: description,
            user_id: userId,
            email: email,
            phone: phone,
            imageUrls: imageUrls,
            views: views,
            mailViews: mailViews,
            phoneViews: phoneViews,
            mailsSent: mailsSent,
            isCompleted: isCompleted,
            feedback: feedback
        )
    }
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let request = userRequests[indexPath.row]
        cell.textLabel?.text = request.title
        return cell
    }
    
    // UITableViewDelegate: Handle selection of a notification
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedRequest = userRequests[indexPath.row]
        
        // Handle showing details of the selected request
        let detailVC = RequestDetailViewController()
        detailVC.request = selectedRequest
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
}
