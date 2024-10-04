//
//  StatisticsManager.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 04/10/2024.
//

import Foundation

class StatisticsManager {
    
    static let shared = StatisticsManager()
    
    
    
    // Filter requests by category, city, or date
    private func filterRequests(_ requests: [UserRequest], criteria: FilterCriteria) -> [UserRequest] {
        return requests.filter { request in
            var isValid = true
            // Filter by startDate
            if let startDate = criteria.startDate, let requestDate = request.date {
                isValid = isValid && (requestDate >= startDate)
            }
            // Filter by endDate
            if let endDate = criteria.endDate, let requestDate = request.date {
                isValid = isValid && (requestDate <= endDate)
            }
            // Filter by category
            if let category = criteria.category {
                isValid = isValid && request.categories.contains(category)
            }
            // Filter by city (currentCity or oldCity)
            if let city = criteria.city {
                isValid = isValid && (request.currentCity == city || request.oldCity == city)
            }
            return isValid
        }
    }
    
    // General stats for requests where isDemand = true or false
    func countRequests(_ requests: [UserRequest], isDemand: Bool, criteria: FilterCriteria? = nil) -> Int {
        let filteredRequests = criteria != nil ? filterRequests(requests, criteria: criteria!) : requests
        return filteredRequests.filter { $0.isDemand == isDemand }.count
    }
    
    // Count completed requests for isDemand = true or false
    func countCompletedRequests(_ requests: [UserRequest], isDemand: Bool, criteria: FilterCriteria? = nil) -> Int {
        let filteredRequests = criteria != nil ? filterRequests(requests, criteria: criteria!) : requests
        return filteredRequests.filter { $0.isDemand == isDemand && $0.isCompleted }.count
    }
    
    // Sum of views for isDemand = true or false
    func totalViews(_ requests: [UserRequest], isDemand: Bool, criteria: FilterCriteria? = nil) -> Int {
        let filteredRequests = criteria != nil ? filterRequests(requests, criteria: criteria!) : requests
        return filteredRequests.filter { $0.isDemand == isDemand }.reduce(0) { $0 + $1.views }
    }
    
    // Sum of mail views for isDemand = true or false
    func totalMailViews(_ requests: [UserRequest], isDemand: Bool, criteria: FilterCriteria? = nil) -> Int {
        let filteredRequests = criteria != nil ? filterRequests(requests, criteria: criteria!) : requests
        return filteredRequests.filter { $0.isDemand == isDemand }.reduce(0) { $0 + $1.mailViews }
    }
    
    // Sum of phone views for isDemand = true or false
    func totalPhoneViews(_ requests: [UserRequest], isDemand: Bool, criteria: FilterCriteria? = nil) -> Int {
        let filteredRequests = criteria != nil ? filterRequests(requests, criteria: criteria!) : requests
        return filteredRequests.filter { $0.isDemand == isDemand }.reduce(0) { $0 + $1.phoneViews }
    }
    
    // Sum of mails sent for isDemand = true or false
    func totalMailsSent(_ requests: [UserRequest], isDemand: Bool, criteria: FilterCriteria? = nil) -> Int {
        let filteredRequests = criteria != nil ? filterRequests(requests, criteria: criteria!) : requests
        return filteredRequests.filter { $0.isDemand == isDemand }.reduce(0) { $0 + $1.mailsSent }
    }
    
    // Count users by originalCity
    func countUsersByOriginalCity(_ users: [User], city: String) -> Int {
        return users.filter { $0.originalCity == city }.count
    }
    
    // Count users by currentCity
    func countUsersByCurrentCity(_ users: [User], city: String) -> Int {
        return users.filter { $0.currentCity == city }.count
    }
    
    
    // Count requests with isDemand filter
    func countRequests(_ requests: [UserRequest], isDemand: Bool) -> Int {
        return requests.filter { $0.isDemand == isDemand }.count
    }
    
    // Count completed requests with isDemand filter
    func countCompletedRequests(_ requests: [UserRequest], isDemand: Bool) -> Int {
        return requests.filter { $0.isDemand == isDemand && $0.isCompleted }.count
    }
    
    // Count requests by category and isDemand filter
    func countRequestsByCategory(_ requests: [UserRequest], isDemand: Bool, category: String) -> Int {
        return requests.filter { $0.isDemand == isDemand && $0.categories.contains(category) }.count
    }
    
    // Total views for requests by isDemand
    func totalViews(_ requests: [UserRequest], isDemand: Bool) -> Int {
        return requests.filter { $0.isDemand == isDemand }.reduce(0) { $0 + $1.views }
    }
    
    // Get all unique cities from users (both originalCity and currentCity)
    func getAllCities(from users: [User]) -> Set<String> {
        var cities = Set<String>()
        for user in users {
            print("user.originalCity")
            print(user.originalCity)
            if let originalCity = user.originalCity {
                cities.insert(originalCity)
            }
            if let currentCity = user.currentCity {
                cities.insert(currentCity)
            }
        }
        return cities
    }
    
    // Count requests by city
    func countRequestsByCity(_ requests: [UserRequest], city: String) -> Int {
        return requests.filter { $0.currentCity == city || $0.oldCity == city }.count
    }
}
