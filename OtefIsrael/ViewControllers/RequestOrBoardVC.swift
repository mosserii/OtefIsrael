//
//  RequestOrBoardVC.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 11/09/2024.
//

import Foundation
import UIKit
import FirebaseAuth

class RequestOrBoardVC: UIViewController {
    
    var isDemand: Bool = false

    let boardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("לצפות בלוח HELP", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.layer.cornerRadius = 30 // This will be updated after frame is set
        return button
    }()

    let requestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("להירשם להתנדבות", for: .normal)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.layer.cornerRadius = 30 // This will be updated after frame is set
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.navigationItem.title = "אני רוצה:"

        boardButton.frame = CGRect(x: 50, y: 180, width: view.frame.width - 100, height: 250)
        requestButton.frame = CGRect(x: 50, y: boardButton.bottom + 50, width: view.frame.width - 100, height: 250)
        
        boardButton.layer.cornerRadius = boardButton.frame.height / 3
        requestButton.layer.cornerRadius = requestButton.frame.height / 3

        boardButton.addTarget(self, action: #selector(boardButtonTapped), for: .touchUpInside)
        requestButton.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
        
        if isDemand{
            boardButton.setTitle("לצפות בלוח נתינה", for: .normal)
            requestButton.setTitle("לבקש סיוע", for: .normal)
        }
        
        view.addSubview(boardButton)
        view.addSubview(requestButton)
    }
    
    @objc func boardButtonTapped() {
        let demandVC = SpecificBoardVC()
        demandVC.isDemandBoard = self.isDemand
        navigationController?.pushViewController(demandVC, animated: true)
    }

    @objc func requestButtonTapped() {
        guard let user_id = Auth.auth().currentUser?.uid else {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            print("User is not logged in")
            return
        }
        let volunteerVC = VolunteerVC()
        print("isDemand")
        print(isDemand)
        volunteerVC.isDemand = self.isDemand
        let nav = UINavigationController(rootViewController: volunteerVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
}

