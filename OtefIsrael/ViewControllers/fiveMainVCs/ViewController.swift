//
//  ViewController.swift
//  DestinationSmartFinder
//
//  Created by Zohar Mosseri on 15/01/2024.
//

import Foundation
import UIKit

class ViewController: UIViewController {

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "בחר מה אתה רוצה לעשות"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()

    let firstButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("אני רוצה להתנדב", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.layer.cornerRadius = 30 // This will be updated after frame is set
        return button
    }()

    let secondButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("אני צריך עזרה", for: .normal)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.layer.cornerRadius = 30 // This will be updated after frame is set
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.navigationItem.title = "פתיחת קריאה חדשה"

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
    
    @objc func openFirstVC() {
        let demandVC = DemandVC()
        demandVC.isDemand = false
        navigationController?.pushViewController(demandVC, animated: true)
    }
    
    @objc func openSecondVC() {
        let demandVC = DemandVC()
        demandVC.isDemand = true
        navigationController?.pushViewController(demandVC, animated: true)
    }
}
