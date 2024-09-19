//
//  BoardsVC.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 21/08/2024.
//

import Foundation
import UIKit

class BoardsVC: UIViewController {

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "בחר את הלוח המתאים על מנת לראות את המודעות"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()

    let demandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("לוח למתנדבים", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.layer.cornerRadius = 30 // This will be updated after frame is set
        return button
    }()

    let supplyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("לוח נתינה", for: .normal)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.layer.cornerRadius = 30 // This will be updated after frame is set
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        self.navigationItem.title = "לוחות קהילה"

        subtitleLabel.frame = CGRect(x: 16, y: 150, width: view.frame.width - 32, height: 30)
        demandButton.frame = CGRect(x: 50, y: subtitleLabel.frame.maxY + 20, width: view.frame.width - 100, height: 250)
        supplyButton.frame = CGRect(x: 50, y: demandButton.bottom + 50, width: view.frame.width - 100, height: 250)
        
        // Update the corner radius to match the button's height (for capsule shape)
        demandButton.layer.cornerRadius = demandButton.frame.height / 3
        supplyButton.layer.cornerRadius = supplyButton.frame.height / 3

        // Add targets for the buttons
        demandButton.addTarget(self, action: #selector(opendemandVC), for: .touchUpInside)
        supplyButton.addTarget(self, action: #selector(opensupplyVC), for: .touchUpInside)
        
        view.addSubview(subtitleLabel)
        view.addSubview(demandButton)
        view.addSubview(supplyButton)
    }
    
    @objc func opendemandVC() {
        let demandVC = SpecificBoardVC()
        demandVC.isDemandBoard = false  // Set to true for demand board
        navigationController?.pushViewController(demandVC, animated: true)
    }

    @objc func opensupplyVC() {
        let supplyVC = SpecificBoardVC()
        supplyVC.isDemandBoard = true  // Set to false for supply board
        navigationController?.pushViewController(supplyVC, animated: true)
    }
}

