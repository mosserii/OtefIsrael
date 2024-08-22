//
//  RequestDetailViewController.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 21/08/2024.
//

import Foundation
import UIKit
import FirebaseAuth
import SDWebImage

class RequestDetailViewController: UIViewController {

    var request: UserRequest?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.pageIndicatorTintColor = .lightGray
        return pageControl
    }()

    private var imageTimer: Timer?


    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .right // Align text to the right for Hebrew
        return label
    }()

    private let categoriesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .right // Align text to the right for Hebrew
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right // Align text to the right for Hebrew
        label.numberOfLines = 0
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .right // Align text to the right for Hebrew
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right // Align text to the right for Hebrew
        return label
    }()

    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right // Align text to the right for Hebrew
        return label
    }()

    private let emailButton: UIButton = {
        let button = UIButton(type: .system)
        let emailIcon = UIImage(systemName: "envelope.fill")
        button.setTitle(" אימייל", for: .normal)
        button.setImage(emailIcon, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.sizeToFit()
        return button
    }()

    private let phoneButton: UIButton = {
        let button = UIButton(type: .system)
        let phoneIcon = UIImage(systemName: "phone.fill")
        button.setTitle(" טלפון", for: .normal)
        button.setImage(phoneIcon, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.sizeToFit()
        return button
    }()


    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()

 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupNavigationBar()
        configureRequestDetails()
        
        // Check if the current user is the owner of the request
        if let request = request, request.user_id == Auth.auth().currentUser?.uid {
            let editButton = UIBarButtonItem(title: "ערוך", style: .plain, target: self, action: #selector(editButtonTapped))
            navigationItem.rightBarButtonItem = editButton
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageTimer?.invalidate()
    }


    private func setupViews() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(imageScrollView)
        scrollView.addSubview(pageControl)
        
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(categoriesLabel)
        scrollView.addSubview(descriptionLabel)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(emailLabel)
        scrollView.addSubview(phoneLabel)
        
        buttonStackView.addArrangedSubview(emailButton)
        buttonStackView.addArrangedSubview(phoneButton)
        view.addSubview(buttonStackView)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds

        // Adjust the frame for the imageScrollView and pageControl
        imageScrollView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.width / 2)
        pageControl.frame = CGRect(x: 0, y: imageScrollView.frame.maxY - 20, width: scrollView.frame.width, height: 20)

        titleLabel.frame = CGRect(x: 16, y: imageScrollView.frame.maxY + 16, width: scrollView.frame.width - 32, height: titleLabel.intrinsicContentSize.height)
        categoriesLabel.frame = CGRect(x: 16, y: titleLabel.frame.maxY + 8, width: scrollView.frame.width - 32, height: categoriesLabel.intrinsicContentSize.height)
        descriptionLabel.frame = CGRect(x: 16, y: categoriesLabel.frame.maxY + 8, width: scrollView.frame.width - 32, height: descriptionLabel.sizeThatFits(CGSize(width: scrollView.frame.width - 32, height: CGFloat.greatestFiniteMagnitude)).height)
        dateLabel.frame = CGRect(x: 16, y: descriptionLabel.frame.maxY + 8, width: scrollView.frame.width - 32, height: dateLabel.intrinsicContentSize.height)
        emailLabel.frame = CGRect(x: 16, y: dateLabel.frame.maxY + 8, width: scrollView.frame.width - 32, height: emailLabel.intrinsicContentSize.height)
        phoneLabel.frame = CGRect(x: 16, y: emailLabel.frame.maxY + 8, width: scrollView.frame.width - 32, height: phoneLabel.intrinsicContentSize.height)

        let buttonHeight = emailButton.frame.height + 64
        buttonStackView.frame = CGRect(x: 16, y: view.frame.height - buttonHeight - view.safeAreaInsets.bottom, width: view.frame.width - 32, height: emailButton.frame.height + 32)

        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: phoneLabel.frame.maxY + 70)
        
        // Re-configure the image carousel after setting the frames
        if let imageUrls = request?.imageUrls {
            setupImageCarousel(imageUrls: imageUrls)
        }
    }

    
    private func setupNavigationBar() {
        // Back button
        let backButton = UIBarButtonItem(title: "חזור", style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .systemBlue // Customize the color if needed
        navigationItem.leftBarButtonItem = backButton

        // Share button
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        navigationItem.rightBarButtonItem = shareButton
    }

    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func editButtonTapped() {
        let volunteerVC = VolunteerVC()
        volunteerVC.requestToEdit = request
        let navController = UINavigationController(rootViewController: volunteerVC)
        present(navController, animated: true, completion: nil)
    }

    // Handle share button action
    @objc private func shareButtonTapped() {
        guard let request = request else { return }
        let shareText = "\(request.title)\n\(request.description ?? "")"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    private func configureRequestDetails() {
        guard let request = request else { return }

        titleLabel.text = request.title
        categoriesLabel.text = request.categories.joined(separator: ", ")
        descriptionLabel.text = request.description ?? "אין תיאור זמין"

        if let date = request.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "he_IL")
            dateLabel.text = "תאריך: \(dateFormatter.string(from: date))"
        } else {
            dateLabel.text = "תאריך: לא זמין"
        }

        emailLabel.text = request.email != nil ? "אימייל: \(request.email!)" : "אימייל: לא זמין"
        phoneLabel.text = request.phone != nil ? "טלפון: \(request.phone!)" : "טלפון: לא זמין"

        // Check if there are image URLs and set up the carousel, otherwise set up the default image
        if let imageUrls = request.imageUrls, !imageUrls.isEmpty {
            setupImageCarousel(imageUrls: imageUrls)
        } else {
            setupImageCarousel(imageUrls: ["placeholderImage"])
        }
    }

    private func setupImageCarousel(imageUrls: [String]) {
        imageScrollView.contentSize = CGSize(width: imageScrollView.frame.width * CGFloat(imageUrls.count), height: imageScrollView.frame.height)
        imageScrollView.delegate = self
        
        pageControl.numberOfPages = imageUrls.count
        pageControl.currentPage = 0
        
        for (index, urlString) in imageUrls.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            if let url = URL(string: urlString) {
                imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "launchLogo"))
            }
            imageView.frame = CGRect(x: CGFloat(index) * imageScrollView.frame.width, y: 0, width: imageScrollView.frame.width, height: imageScrollView.frame.height)
            imageScrollView.addSubview(imageView)
        }
        
        startImageTimer()
    }
    
    private func startImageTimer() {
        imageTimer?.invalidate()
        imageTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(autoScrollImages), userInfo: nil, repeats: true)
    }

    @objc private func autoScrollImages() {
        let currentPage = pageControl.currentPage
        let nextPage = (currentPage + 1) % pageControl.numberOfPages
        let offsetX = CGFloat(nextPage) * imageScrollView.frame.width
        imageScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        pageControl.currentPage = nextPage
    }


}

extension RequestDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        imageTimer?.invalidate()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startImageTimer()
    }
}
