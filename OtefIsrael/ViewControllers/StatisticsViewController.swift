import Foundation
import UIKit

class StatisticsViewController: UIViewController {

    let statisticsManager = StatisticsManager()
    var requests: [UserRequest] = []
    var users: [User] = []
    var categories: [String: Category] = [:]
    
    // Filters
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    var selectedCity: String?
    var selectedCategory: String?

    // UI components
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["General", "By Category", "By City"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()
    
    private let startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(startDateChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private let endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(endDateChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private let cityPicker: UIPickerView = UIPickerView()
    private let categoryPicker: UIPickerView = UIPickerView()
    
    private let statisticsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()

        // Fetch all the data and then display statistics
        fetchAllData {
            self.displayStatistics()
        }
    }

    private func setupUI() {
        view.addSubview(segmentedControl)
        view.addSubview(statisticsLabel)
        view.addSubview(startDatePicker)
        view.addSubview(endDatePicker)
        view.addSubview(cityPicker)
        view.addSubview(categoryPicker)
        
        cityPicker.delegate = self
        cityPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        segmentedControl.frame = CGRect(x: 10, y: 100, width: view.frame.width - 20, height: 30)
        startDatePicker.frame = CGRect(x: 10, y: segmentedControl.bottom + 10, width: (view.frame.width - 20)/3, height: 30)
        endDatePicker.frame = CGRect(x: startDatePicker.right + 10, y: 140, width: (view.frame.width - 20)/3, height: 30)
        cityPicker.frame = CGRect(x: 10, y: endDatePicker.bottom + 10 , width: view.frame.width - 20, height: 100)
        categoryPicker.frame = CGRect(x: 10, y: 330, width: view.frame.width - 20, height: 100)
        statisticsLabel.frame = CGRect(x: 10, y: 450, width: view.frame.width - 20, height: 300)
    }

    @objc private func segmentChanged() {
        displayStatistics()
    }

    private func fetchAllData(completion: @escaping () -> Void) {
        // Fetch all user requests
        DatabaseManager.shared.retrieveAllUserRequests { [weak self] requests in
            self?.requests = requests

            // Fetch all users
            DatabaseManager.shared.getAllUsers { users in
                self?.users = users

                // Fetch all categories
                DatabaseManager.shared.fetchCategories { categories in
                    self?.categories = categories ?? [:]
                    self?.cityPicker.reloadAllComponents()
                    self?.categoryPicker.reloadAllComponents()

                    // Call the completion handler after all data is loaded
                    completion()
                }
            }
        }
    }

    private func displayStatistics() {
        let criteria = FilterCriteria(
            startDate: selectedStartDate,
            endDate: selectedEndDate,
            category: selectedCategory,
            city: selectedCity
        )
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            displayGeneralStatistics(with: criteria)
        case 1:
            displayCategoryStatistics(with: criteria)
        case 2:
            displayCityStatistics(with: criteria)
        default:
            break
        }
    }

    private func displayGeneralStatistics(with criteria: FilterCriteria? = nil) {
        let totalDemands = statisticsManager.countRequests(requests, isDemand: true, criteria: criteria)
        let totalSupplies = statisticsManager.countRequests(requests, isDemand: false, criteria: criteria)
        let completedDemands = statisticsManager.countCompletedRequests(requests, isDemand: true, criteria: criteria)
        let completedSupplies = statisticsManager.countCompletedRequests(requests, isDemand: false, criteria: criteria)
        let totalViewsDemands = statisticsManager.totalViews(requests, isDemand: true, criteria: criteria)
        let totalViewsSupplies = statisticsManager.totalViews(requests, isDemand: false, criteria: criteria)

        statisticsLabel.text = """
        Total Demands: \(totalDemands)
        Total Supplies: \(totalSupplies)
        Completed Demands: \(completedDemands)
        Completed Supplies: \(completedSupplies)
        Total Views (Demands): \(totalViewsDemands)
        Total Views (Supplies): \(totalViewsSupplies)
        """
    }

    private func displayCategoryStatistics(with criteria: FilterCriteria? = nil) {
        guard let category = selectedCategory else { return }

        let totalDemands = statisticsManager.countRequestsByCategory(requests, isDemand: true, category: category)
        let totalSupplies = statisticsManager.countRequestsByCategory(requests, isDemand: false, category: category)

        statisticsLabel.text = """
        Category: \(category)
        Total Demands: \(totalDemands)
        Total Supplies: \(totalSupplies)
        """
    }

    private func displayCityStatistics(with criteria: FilterCriteria? = nil) {
        guard let city = selectedCity else { return }
        
        let usersInOriginalCity = statisticsManager.countUsersByOriginalCity(users, city: city)
        let usersInCurrentCity = statisticsManager.countUsersByCurrentCity(users, city: city)
        let requestsInCity = statisticsManager.countRequestsByCity(requests, city: city)
        
        statisticsLabel.text = """
        City: \(city)
        Users in Original City: \(usersInOriginalCity)
        Users in Current City: \(usersInCurrentCity)
        Requests in City: \(requestsInCity)
        """
    }
    
    @objc private func startDateChanged(_ picker: UIDatePicker) {
        selectedStartDate = picker.date
        displayStatistics()
    }
    
    @objc private func endDateChanged(_ picker: UIDatePicker) {
        selectedEndDate = picker.date
        displayStatistics()
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension StatisticsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == cityPicker {
            let cities = statisticsManager.getAllCities(from: users)
            return cities.count > 0 ? cities.count : 1 // Return 1 row for "No Cities" if empty
        } else {
            return categories.count > 0 ? categories.count : 1 // Return 1 row for "No Categories" if empty
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == cityPicker {
            let cities = Array(statisticsManager.getAllCities(from: users))
            return cities.isEmpty ? "No Cities" : cities[row] // Show "No Cities" if empty
        } else {
            let categoryArray = Array(categories.values)
            return categoryArray.isEmpty ? "No Categories" : categoryArray[row].category // Show "No Categories" if empty
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == cityPicker {
            let cities = Array(statisticsManager.getAllCities(from: users))
            if row < cities.count {
                selectedCity = cities[row]
            } else {
                selectedCity = nil // Handle case where no city is selected
            }
        } else {
            let categoryArray = Array(categories.values)
            if row < categoryArray.count {
                selectedCategory = categoryArray[row].category
            } else {
                selectedCategory = nil // Handle case where no category is selected
            }
        }
        displayStatistics()
    }

}
