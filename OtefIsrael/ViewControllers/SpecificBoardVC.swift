//
//  SpecificBoardVC.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 21/08/2024.
//

import Foundation
import UIKit
import SDWebImage

class RequestBoardHeaderView: UICollectionReusableView {
    static let identifier = "RequestBoardHeaderView"

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "backgroundImage") // Replace with your actual image name
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "לוח צרכים" // Title in Hebrew
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "ניתן לבחור מודעה ולקבל עוד פרטים על הצורך" // Subtitle in Hebrew
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "חפש בקשות או הצעות"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()

    let filterButton: UIButton = {
        let button = UIButton(type: .system)
        
        // Set title with symbol
        let buttonTitle = NSAttributedString(string: " סינון ומיון", attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.gray
        ])
        
        let symbolAttachment = NSTextAttachment()
        symbolAttachment.image = UIImage(systemName: "line.3.horizontal.decrease.circle")?.withTintColor(.gray)
        symbolAttachment.bounds = CGRect(x: 0, y: -2, width: 20, height: 20)
        
        let symbolString = NSAttributedString(attachment: symbolAttachment)
        let fullTitle = NSMutableAttributedString()
        fullTitle.append(symbolString)
        fullTitle.append(buttonTitle)
        
        button.setAttributedTitle(fullTitle, for: .normal)
        
        // Button styling
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(backgroundImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(searchBar)
        addSubview(filterButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.frame = bounds
        
        // Layout for title and subtitle
        titleLabel.frame = CGRect(x: 0, y: bounds.height / 2 - 50, width: bounds.width, height: 30)
        subtitleLabel.frame = CGRect(x: 0, y: titleLabel.frame.maxY, width: bounds.width, height: 20)
        
        // Layout for search bar
        searchBar.frame = CGRect(x: 16, y: subtitleLabel.frame.maxY + 10, width: bounds.width - 32, height: 40)
        
        // Layout for filter button
        filterButton.frame = CGRect(x: bounds.width - 120, y: searchBar.frame.maxY + 10, width: 100, height: 40)
    }
}

class SpecificBoardVC: UIViewController, UISearchBarDelegate {
    
    var requests = [UserRequest]()
    var isDemandBoard: Bool = false // To determine if to show Demands/Offers
    var isFromLogin: Bool = false // Add the boolean property to the view controller

    var selectedFilters = [FilterSection]()

    
    var requestCollectionView: UICollectionView!
    
    var filteredRequests = [UserRequest]()
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        configureBoardContent()
        requestCollectionView.reloadData()
    }
    
    func setupCollectionView() {
        // Initialize the collection view with a flow layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16 // Space between rows
        layout.minimumInteritemSpacing = 16 // Space between items in the same row
        
        // Set section insets for padding around the cells and the screen edges
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        requestCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        requestCollectionView.backgroundColor = .white
        requestCollectionView.dataSource = self
        requestCollectionView.delegate = self

        // Register the custom cell
        requestCollectionView.register(RequestCell.self, forCellWithReuseIdentifier: "RequestCell")
        requestCollectionView.register(RequestBoardHeaderView.self,
                                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                       withReuseIdentifier: RequestBoardHeaderView.identifier)

        view.addSubview(requestCollectionView)
    }
    
    private func configureBoardContent() {
        DatabaseManager.shared.retrieveAllUserRequests { [weak self] userRequests in
            guard let self = self else { return }
            self.requests = userRequests.filter { $0.isDemand == self.isDemandBoard }
            self.requestCollectionView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredRequests = []
            requestCollectionView.reloadData()
        } else {
            isSearching = true
            filteredRequests = requests.filter { request in
                return request.title.lowercased().contains(searchText.lowercased()) ||
                       request.description?.lowercased().contains(searchText.lowercased()) ?? false ||
                       request.categories.joined(separator: " ").lowercased().contains(searchText.lowercased())
            }
        }
        // Do not reload the collection view here
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Reload the collection view only when the search is confirmed
        requestCollectionView.reloadData()
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        filteredRequests = []
        requestCollectionView.reloadData()
        searchBar.resignFirstResponder()
    }

    @objc func filterButtonTapped() {
        let filterVC = FilterViewController()
        let navController = UINavigationController(rootViewController: filterVC)
        filterVC.navigationItem.title = "סינון ומיון"
        
        let batelButton = UIBarButtonItem(title: "בטל", style: .done, target: self, action: #selector(dismissFilter))
        filterVC.navigationItem.rightBarButtonItem = batelButton
        
        // Pass the selected filters to the FilterViewController
        filterVC.filterOptions = selectedFilters.isEmpty ? filterVC.defaultFilterOptions() : selectedFilters

        // Handle the filtering logic
        filterVC.onApplyFilters = { [weak self] selectedFilters in
            guard let self = self else { return }
            self.selectedFilters = selectedFilters // Store the selected filters
            self.applyFilters(selectedFilters)
        }

        present(navController, animated: true, completion: nil)
    }

    func applyFilters(_ selectedFilters: [FilterSection]) {
        var filteredResults = requests
        for section in selectedFilters {
            switch section.title {
            case "סוג מוצר":
                let selectedCategories = section.options.filter { $0.isSelected }.map { $0.name }
                if !selectedCategories.isEmpty {
                    filteredResults = filteredResults.filter { request in
                        return !Set(request.categories).intersection(selectedCategories).isEmpty
                    }
                }
            case "מצב מוצר":
                let selectedConditions = section.options.filter { $0.isSelected }.map { $0.name }
                if !selectedConditions.isEmpty {
                    filteredResults = filteredResults.filter { request in
                        let inCategories = !Set(request.categories).intersection(selectedConditions).isEmpty
                        let inDescription = selectedConditions.contains { condition in
                            request.description?.contains(condition) ?? false
                        }
                        return inCategories || inDescription
                    }
                }
            case "אזור מכירה":
                let selectedCities = section.options.filter { $0.isSelected }.map { $0.name }
                if !selectedCities.isEmpty {
                    filteredResults = filteredResults.filter { request in
                        guard let city = request.currentCity else { return false }
                        return selectedCities.contains(city)
                    }
                }
            default:
                break
            }
        }
        
        filteredRequests = filteredResults
        isSearching = true
        requestCollectionView.reloadData()
    }

    @objc func dismissFilter() {
        dismiss(animated: true, completion: nil)
    }

}

extension SpecificBoardVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredRequests.count : requests.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestCell", for: indexPath) as! RequestCell
        let request = isSearching ? filteredRequests[indexPath.item] : requests[indexPath.item]

        // Configure the cell with the filtered or unfiltered request
        cell.imageView.image = UIImage(named: "launchLogo")
        cell.titleLabel.text = request.title
        cell.categoriesLabel.text = request.categories.joined(separator: ", ")
        cell.descriptionLabel.text = request.description

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let selectedRequest = isSearching ? filteredRequests[indexPath.item] : requests[indexPath.item]
        let detailVC = RequestDetailViewController()
        detailVC.request = selectedRequest
        let nav = UINavigationController(rootViewController: detailVC)
        present(nav, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = 16 * 3 // Total padding: 16 for left, 16 for right, 16 between items
        let availableWidth = view.frame.width - CGFloat(paddingSpace)
        let widthPerItem = availableWidth / 2 // Two items per row
        return CGSize(width: widthPerItem, height: 300)
    }

    // Set up the header view
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: RequestBoardHeaderView.identifier,
                                                                             for: indexPath) as! RequestBoardHeaderView
            // Configure the header based on the board type
            headerView.searchBar.delegate = self
            headerView.searchBar.showsCancelButton = true
            headerView.filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
            
            headerView.titleLabel.text = isDemandBoard ? "לוח צרכים" : "לוח נתינות"
            headerView.subtitleLabel.text = isDemandBoard ? "ניתן לבחור מודעה ולקבל עוד פרטים על הצורך" : "ניתן לבחור מודעה ולקבל עוד פרטים על ההצעה"
            
            return headerView
        }
        return UICollectionReusableView()
    }
    
    // Define the size of the header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 220)
    }
}
