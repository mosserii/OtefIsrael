//
//  DemandVC.swift
//  DestinationSmartFinder
//
//  Created by Zohar Mosseri on 15/01/2024.
//

import Foundation
import UIKit

class DemandVC: UIViewController {
    
    var isDemand: Bool = false

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "ניתן להסתכל בלוח הדרישות או להציע הצעת התנדבות חדשה"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()

    let firstButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("הצעת התנדבות חדשה", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.layer.cornerRadius = 30 // This will be updated after frame is set
        return button
    }()

    let secondButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("לוח הדרישות", for: .normal)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.layer.cornerRadius = 30 // This will be updated after frame is set
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if isDemand{
            self.navigationItem.title = "אני מבקש עזרה"
            subtitleLabel.text = "ניתן להסתכל בלוח הנתינות או לפתוח בקשת עזרה חדשה"
            firstButton.setTitle("בקשת עזרה חדשה", for: .normal)
            secondButton.setTitle("לוח ההצעות", for: .normal)
        }
        else {
            self.navigationItem.title = "אני מתנדב"
            subtitleLabel.text = "ניתן להסתכל בלוח הדרישות או להציע הצעת התנדבות חדשה"
            firstButton.setTitle("הצעת התנדבות חדשה", for: .normal)
            secondButton.setTitle("לוח הדרישות", for: .normal)

        }
        subtitleLabel.frame = CGRect(x: 16, y: 150, width: view.frame.width - 32, height: 30)
        firstButton.frame = CGRect(x: 50, y: subtitleLabel.frame.maxY + 20, width: view.frame.width - 100, height: 250)
        secondButton.frame = CGRect(x: 50, y: firstButton.bottom + 50, width: view.frame.width - 100, height: 250)
        
        // Update the corner radius to match the button's height (for capsule shape)
        firstButton.layer.cornerRadius = firstButton.frame.height / 3
        secondButton.layer.cornerRadius = secondButton.frame.height / 3

        // Add targets for the buttons
        firstButton.addTarget(self, action: #selector(openFirstVC), for: .touchUpInside)
        secondButton.addTarget(self, action: #selector(openSecondVC), for: .touchUpInside)
        
        view.addSubview(subtitleLabel)
        view.addSubview(firstButton)
        view.addSubview(secondButton)
    }
    
    @objc func openFirstVC() { // new Post
        let volunteerVC = VolunteerVC()
        volunteerVC.isDemand = self.isDemand
        let nav = UINavigationController(rootViewController: volunteerVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func openSecondVC() { // go to board
        let demandVC = SpecificBoardVC()
        demandVC.isDemandBoard = !self.isDemand
        navigationController?.pushViewController(demandVC, animated: true)

//        let nav = UINavigationController(rootViewController: demandVC)
//        nav.modalPresentationStyle = .fullScreen
//        present(nav, animated: true, completion: nil)
    }
}
