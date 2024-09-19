//
//  infoVC.swift
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


class infoVC: UIViewController {
    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "launchLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var tableView1 = UITableView()
    var selectOptions = ["דף מרכזי", "קבוצת הוואטספ שלנו", "ניצולי שואה", "חינוך", "לוחמים", "נפגעי אוקטובר", "לכתבה בגלובס"]
    
    private let selectOptionSymbols: [UIImage?] = [
        UIImage(systemName: "house")?.withRenderingMode(.alwaysTemplate),              // דף מרכזי (Main Page)
        UIImage(systemName: "message")?.withRenderingMode(.alwaysTemplate),            // קבוצת הוואטספ שלנו (Our WhatsApp Group)
        UIImage(systemName: "person.3")?.withRenderingMode(.alwaysTemplate),      // ניצולי שואה (Holocaust Survivors)
        UIImage(systemName: "book")?.withRenderingMode(.alwaysTemplate),          // חינוך (Education)
        UIImage(systemName: "shield")?.withRenderingMode(.alwaysTemplate),        // לוחמים (Soldiers)
        UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate),         // נפגעי אוקטובר (October Victims)
        UIImage(systemName: "newspaper")?.withRenderingMode(.alwaysTemplate)      // לכתבה בגלובס (Globes Article)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "מידע"
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView1.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView1.delegate = self
        tableView1.dataSource = self

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(tableView1)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        scrollView.frame = view.bounds
        let size = scrollView.width / 2

        
        imageView.frame = CGRect(x: (scrollView.width - size) / 2, y: 30, width: size, height: size)
        tableView1.frame = CGRect(x: 0, y: imageView.bottom + 20, width: scrollView.width, height: 400)

    }
}


extension infoVC: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var linkToOpen = ""
        // Handle cell selection based on the selected option
        switch selectOptions[indexPath.row] {
        case "דף מרכזי":
            linkToOpen = "https://hamaloteflightingthedarom.ravpage.co.il/otek"
        case "קבוצת הוואטספ שלנו":
            linkToOpen = "https://chat.whatsapp.com/Il45HhdyJCE8TMZrsl2JLB"
        case "ניצולי שואה":
            linkToOpen = "https://www.facebook.com/profile.php?id=100064843984467"
        case "חינוך":
            linkToOpen = ""
        case "לוחמים":
            linkToOpen = ""
        case "נפגעי אוקטובר":
            linkToOpen = ""
        case "לכתבה בגלובס":
            linkToOpen = "https://www.globes.co.il/news/article.aspx?did=1001468430"
        default:
            break
        }
        
//        if let url = URL(string: linkToOpen) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        } else {
//            // Handle the error if the URL is invalid
//            let alert = UIAlertController(title: "שגיאה", message: "לא ניתן לפתוח את הלינק המבוקש, נא לנסות שוב", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "אוקיי", style: .default))
//            present(alert, animated: true)
//        }
        
        if !linkToOpen.isEmpty, let url = URL(string: linkToOpen) {
            // Create an instance of WebViewController
            let webVC = WebViewController()
            webVC.urlString = linkToOpen  // Pass the URL string to the WebViewController
            
            // Present the WebViewController
            navigationController?.pushViewController(webVC, animated: true)
        } else {
            // Handle the error if the URL is invalid
            let alert = UIAlertController(title: "שגיאה", message: "לא ניתן לפתוח את הלינק המבוקש, נא לנסות שוב", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "אוקיי", style: .default))
            present(alert, animated: true)
        }
    }
}
