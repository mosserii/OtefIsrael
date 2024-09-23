import Foundation
import UIKit
import FirebaseAuth

class UserRequestsVC: UIViewController {

    private var requests = [UserRequest]()
    private var expiredRequestsQueue = [UserRequest]()

    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    var tableView = UITableView()
    
    private let noRequestsLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 12
        label.text = "אין בקשות"
        label.textColor = .gray
        label.textAlignment = .center
        label.isHidden = true
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel()
        titleLabel.text = "הבקשות שלי"
        titleLabel.textAlignment = .right // Align the text to the right
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        titleLabel.sizeToFit()

        // Set the custom UILabel as the title view
        self.navigationItem.titleView = titleLabel

        // Enable large titles if needed
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(ExploreEventCell.self, forCellReuseIdentifier: "ExploreEventCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(tableView)
        scrollView.addSubview(noRequestsLabel)
        
        fetchUserRequests()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        tableView.frame = CGRect(x: 0, y: 10, width: scrollView.width, height: scrollView.height)
        noRequestsLabel.frame = CGRect(x: 10, y: (view.height-200)/2, width: view.width-20, height: 100)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchUserRequests()
    }
    
    private func fetchUserRequests() {
        guard let user_id = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            return
        }
        
        DatabaseManager.shared.retrieveUserRequests(userId: user_id) { [weak self] requests in
            self?.requests = requests
            self?.noRequestsLabel.isHidden = !requests.isEmpty
            self?.tableView.reloadData()
            
            // Check for any expired requests
            self?.checkForExpiredRequests()
        }
    }
    
    private func checkForExpiredRequests() {
        expiredRequestsQueue = requests.filter { request in
            guard let requestDate = request.date else { return false }
            return requestDate < Date().addingTimeInterval(-86400) && !(request.isCompleted)
        }
        
        // Present the follow-up questions if there are expired requests
        presentNextFollowUpQuestion()
    }

    private func presentNextFollowUpQuestion() {
        guard !expiredRequestsQueue.isEmpty else { return }
        
        let request = expiredRequestsQueue.removeFirst()
        let followUpVC = FollowUpQuestionsVC()
        followUpVC.request = request
        let nav = UINavigationController(rootViewController: followUpVC)
        
        present(nav, animated: true) {
            // Once the user dismisses the current VC, present the next one if available
            self.presentNextFollowUpQuestion()
        }
    }
}

extension UserRequestsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreEventCell", for: indexPath) as! ExploreEventCell
        let request = requests[indexPath.row]
        cell.configure(with: request)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedRequest = requests[indexPath.row]
        let detailVC = RequestDetailViewController()
        detailVC.request = selectedRequest
        let nav = UINavigationController(rootViewController: detailVC)
        present(nav, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

