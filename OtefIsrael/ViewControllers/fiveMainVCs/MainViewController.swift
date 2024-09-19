//
//  MainViewController.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 22/08/2024.
//

import Foundation
import UIKit
import WebKit

class MainViewController: UIViewController {
    var webView: WKWebView!
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the WebView
        webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        
        // Setup the Toolbar
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(toolbar)
        
        let safariButton = UIBarButtonItem(image: UIImage(systemName: "safari"), style: .plain, target: self, action: #selector(openInSafariTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexibleSpace, safariButton]
        
        // Add constraints to toolbar
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Adjust WebView frame to fit above the toolbar
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
        
        self.urlString = "https://hamaloteflightingthedarom.ravpage.co.il/otek"

        // Load the URL
        if let urlString = urlString, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @objc func openInSafariTapped() {
        if let urlString = urlString, let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
