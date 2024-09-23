//import Foundation
//import FirebaseAuth
//import UIKit
// TODO: 4 buttons so uncomment
//class ViewController: UIViewController {
//
//    // Scroll view to contain all UI elements
//    private let scrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.showsVerticalScrollIndicator = false
//        return scrollView
//    }()
//
//    let firstButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("לבקש סיוע", for: .normal)
//        button.backgroundColor = .systemGreen
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        button.layer.cornerRadius = 30
//        return button
//    }()
//
//    let secondButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("לצפות בבקשות לסיוע", for: .normal)
//        button.backgroundColor = .systemYellow
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        button.layer.cornerRadius = 30
//        return button
//    }()
//    
//    let thirdButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("להירשם להתנדבות", for: .normal)
//        button.backgroundColor = .systemPink
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        button.layer.cornerRadius = 30
//        return button
//    }()
//    
//    let fourthButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("לצפות בבקשות לעזרה", for: .normal)
//        button.backgroundColor = .systemPurple
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        button.layer.cornerRadius = 30
//        return button
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        
//        self.navigationItem.title = "תודה שהצטרפתם לקהילה ובואו נתעטף"
//        
//        setupScrollView()
//        setupLayout()
//        setupButtons()
//    }
//    
//    private func setupScrollView() {
//        view.addSubview(scrollView)
//        
//        // Set scroll view constraints to the edges of the view
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//    }
//
//    private func setupLayout() {
//        // Add all UI elements to the scroll view
//        scrollView.addSubview(firstButton)
//        scrollView.addSubview(secondButton)
//        scrollView.addSubview(thirdButton)
//        scrollView.addSubview(fourthButton)
//
//        // Layout settings
//        let buttonWidth = view.frame.width - 100
//        let buttonHeight: CGFloat = 130
//        let buttonSpacing: CGFloat = 30
//        
//        // Set frames for UI elements
//        firstButton.frame = CGRect(x: 50, y: 20, width: buttonWidth, height: buttonHeight)
//        secondButton.frame = CGRect(x: 50, y: firstButton.frame.maxY + buttonSpacing, width: buttonWidth, height: buttonHeight)
//        thirdButton.frame = CGRect(x: 50, y: secondButton.frame.maxY + buttonSpacing, width: buttonWidth, height: buttonHeight)
//        fourthButton.frame = CGRect(x: 50, y: thirdButton.frame.maxY + buttonSpacing, width: buttonWidth, height: buttonHeight)
//        
//        // Update the corner radius to match the button's height (for capsule shape)
//        firstButton.layer.cornerRadius = buttonHeight / 3
//        secondButton.layer.cornerRadius = buttonHeight / 3
//        thirdButton.layer.cornerRadius = buttonHeight / 3
//        fourthButton.layer.cornerRadius = buttonHeight / 3
//        
//        // Set scroll view content size to accommodate all elements
//        scrollView.contentSize = CGSize(width: view.frame.width, height: fourthButton.frame.maxY + 20)
//    }
//
//    private func setupButtons() {
//        // Add targets for the buttons
//        firstButton.addTarget(self, action: #selector(openFirstVC), for: .touchUpInside)
//        secondButton.addTarget(self, action: #selector(openSecondVC), for: .touchUpInside)
//        thirdButton.addTarget(self, action: #selector(openThirdVC), for: .touchUpInside)
//        fourthButton.addTarget(self, action: #selector(openFourthVC), for: .touchUpInside)
//    }
//
//    @objc func openFirstVC() {
//        guard let user_id = Auth.auth().currentUser?.uid else {
//            let vc = LoginViewController()
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: true)
//            print("User is not logged in")
//            return
//        }
//        let volunteerVC = VolunteerVC()
//        volunteerVC.isDemand = true
//        let nav = UINavigationController(rootViewController: volunteerVC)
//        nav.modalPresentationStyle = .fullScreen
//        present(nav, animated: true, completion: nil)
//    }
//    
//    @objc func openSecondVC() {
//        let demandVC = SpecificBoardVC()
//        demandVC.isDemandBoard = true
//        navigationController?.pushViewController(demandVC, animated: true)
//    }
//    
//    @objc func openThirdVC() {
//        guard let user_id = Auth.auth().currentUser?.uid else {
//            let vc = LoginViewController()
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: true)
//            print("User is not logged in")
//            return
//        }
//        let volunteerVC = VolunteerVC()
//        volunteerVC.isDemand = false
//        let nav = UINavigationController(rootViewController: volunteerVC)
//        nav.modalPresentationStyle = .fullScreen
//        present(nav, animated: true, completion: nil)
//    }
//    
//    @objc func openFourthVC() {
//        let demandVC = SpecificBoardVC()
//        demandVC.isDemandBoard = false
//        navigationController?.pushViewController(demandVC, animated: true)
//    }
//}

import FirebaseAuth
import Foundation
import UIKit

class ViewController: UIViewController {

    let demandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("רוצה סיוע", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.layer.cornerRadius = 30 // This will be updated after frame is set
        return button
    }()

    let supplyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("רוצה להתנדב", for: .normal)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        button.layer.cornerRadius = 30 // This will be updated after frame is set
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
                
        let titleLabel = UILabel()
        titleLabel.text = "תודה שהצטרפתם לקהילה ובואו נתעטף"
        titleLabel.textAlignment = .right // Align the text to the right
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.sizeToFit()

        // Set the custom UILabel as the title view
        self.navigationItem.titleView = titleLabel

        // Enable large titles if needed
        navigationController?.navigationBar.prefersLargeTitles = true

        demandButton.frame = CGRect(x: 50, y: 180, width: view.frame.width - 100, height: 250)
        supplyButton.frame = CGRect(x: 50, y: demandButton.bottom + 50, width: view.frame.width - 100, height: 250)
        
        // Update the corner radius to match the button's height (for capsule shape)
        demandButton.layer.cornerRadius = demandButton.frame.height / 3
        supplyButton.layer.cornerRadius = supplyButton.frame.height / 3

        // Add targets for the buttons
        demandButton.addTarget(self, action: #selector(demandButtonTapped), for: .touchUpInside)
        supplyButton.addTarget(self, action: #selector(supplyButtonTapped), for: .touchUpInside)
        
        view.addSubview(demandButton)
        view.addSubview(supplyButton)
    }
    
    @objc func demandButtonTapped() {
        let demandVC = RequestOrBoardVC()
        demandVC.isDemand = true  // Set to true for demand
        navigationController?.pushViewController(demandVC, animated: true)
    }

    @objc func supplyButtonTapped() {
        let supplyVC = RequestOrBoardVC()
        supplyVC.isDemand = false  // Set to false for supply
        navigationController?.pushViewController(supplyVC, animated: true)
    }
}

