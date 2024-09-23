//
//  FilterViewController.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 22/08/2024.
//

import Foundation
import UIKit

class FilterViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    var onApplyFilters: (([FilterSection]) -> Void)?

    var filterOptions: [FilterSection] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "סינון ומיון"
        view.backgroundColor = .white
        setupTableView()
        setupApplyButton()
    }
    
    func defaultFilterOptions() -> [FilterSection] {
        // Get the categories from the CategoryManager
        let categories = CategoryManager.shared.getCategories().map { FilterOption(name: $0.category, isSelected: false) }
        
        return [
            FilterSection(title: "קטגוריה", options: categories),
            FilterSection(title: "איזור", options: [
                FilterOption(name: "ירושלים", isSelected: false),
                FilterOption(name: "תל אביב יפו", isSelected: false),
                FilterOption(name: "ראשון לציון", isSelected: false),
                FilterOption(name: "פתח תקווה", isSelected: false)
            ])
        ]
    }

    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FilterOptionCell.self, forCellReuseIdentifier: FilterOptionCell.identifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
    }
    
    func setupApplyButton() {
        let applyButton = UIButton(type: .system)
        applyButton.setTitle("הצג תוצאות", for: .normal)
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.backgroundColor = .black
        applyButton.layer.cornerRadius = 25
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)
        
        view.addSubview(applyButton)
        
        NSLayoutConstraint.activate([
            applyButton.heightAnchor.constraint(equalToConstant: 50),
            applyButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            applyButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    @objc func applyFilters() {
        // Call the closure and pass the selected filters
        onApplyFilters?(filterOptions)
        dismiss(animated: true, completion: nil)
    }
}

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterOptions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions[section].options.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filterOptions[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterOptionCell.identifier, for: indexPath) as! FilterOptionCell
        let option = filterOptions[indexPath.section].options[indexPath.row]
        cell.configure(with: option)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filterOptions[indexPath.section].options[indexPath.row].isSelected.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
