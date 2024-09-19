//
//  DatabaseManager.swift
//  TripSmartFinder
//
//  Created by Zohar Mosseri on 20/02/2024.
//


import Foundation
import FirebaseDatabase
import CoreLocation
import FirebaseAuth

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
 
}

//for users
extension DatabaseManager{
    
    public func userExists(email: String, phoneNumber: String, completion: @escaping (Bool) -> Void) {
        // First, check if the email exists
        print("in userExists")
        checkUserAttributeExists(attribute: "email", value: email) { exists in
            if exists {
                print("true userExists")
                completion(true)
            } else {
                print("in user not Exists")
                // If email doesn't exist, check if the phone number exists
                self.checkUserAttributeExists(attribute: "phone", value: phoneNumber, completion: completion)
            }
        }
    }
    
    private func checkUserAttributeExists(attribute: String, value: String, completion: @escaping (Bool) -> Void) {
        database.child("users").queryOrdered(byChild: attribute).queryEqual(toValue: value).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
        // Prepare the user data dictionary to include all fields
        var userValues: [String: Any] = [
            "email": user.email,
            "phone": user.phoneNumber,
            "first_name": user.firstName,
            "last_name": user.lastName,
            "requests": user.requests
        ]
        
        // Only add originalCity and currentCity if they are not nil
        if let originalCity = user.originalCity {
            userValues["original_city"] = originalCity
        }
        if let currentCity = user.currentCity {
            userValues["current_city"] = currentCity
        }
        
        print("in insertUser")
        
        // Set the user data in the database
        database.child("users").child(user.id).setValue(userValues) { error, _ in
            if let error = error {
                print("Failed to write to database in insertUser: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    public func getUserData(with user_uid: String, completion: @escaping (User?) -> Void) {
        // Observe a single event to retrieve user data
        database.child("users").child(user_uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userData = snapshot.value as? [String: Any],
                  let userEmail = userData["email"] as? String,
                  let userPhone = userData["phone"] as? String,
                  let firstName = userData["first_name"] as? String,
                  let lastName = userData["last_name"] as? String,
                  let requestsDict = userData["requests"] as? [String: Any] else {
                print("Failed to get user data:")
                print(snapshot.value as Any)
                completion(nil)
                return
            }
            
            // Retrieve optional fields if they exist
            let originalCity = userData["original_city"] as? String
            let currentCity = userData["current_city"] as? String
            
            // Convert the keys of the requests dictionary to an array of strings
            let requestsData = Array(requestsDict.keys)
            
            // Create a User object with all the fields
            let user = User(
                id: user_uid,
                firstName: firstName,
                lastName: lastName,
                originalCity: originalCity,
                currentCity: currentCity,
                email: userEmail,
                requests: requestsData,
                phoneNumber: userPhone
            )
            
            completion(user)
        
        }
    }
    
}


extension DatabaseManager {

    // Insert a user request
    func insertUserRequest(userId: String, userRequest: UserRequest, completion: @escaping (Bool) -> Void) {
        var userRequest = userRequest
        let requestId = database.child("requests").childByAutoId().key
        guard let requestId = requestId else {
            completion(false)
            return
        }
        
        userRequest.id = requestId
        
        do {
            let requestData = try JSONEncoder().encode(userRequest)
            let requestDict = try JSONSerialization.jsonObject(with: requestData, options: .allowFragments) as? [String: Any]
            
            // Start a group of tasks
            let group = DispatchGroup()
            var didSucceed = true
            
            // Insert into global /requests/ node
            group.enter()
            database.child("requests").child(requestId).setValue(requestDict) { error, _ in
                if let error = error {
                    print("Failed to insert user request in global requests: \(error)")
                    didSucceed = false
                }
                group.leave()
            }
            
            // Also save the requestId under the specific user's branch
            group.enter()
            database.child("users").child(userId).child("requests").child(requestId).setValue(true) { error, _ in
                if let error = error {
                    print("Failed to save requestId under user's requests: \(error)")
                    didSucceed = false
                }
                group.leave()
            }
            
            // Notify completion when both tasks are done
            group.notify(queue: .main) {
                completion(didSucceed)
            }
            
        } catch {
            print("Failed to encode user request: \(error)")
            completion(false)
        }
    }
    
    
    /// Update a user request
    func updateUserRequest(userId: String, userRequest: UserRequest, completion: @escaping (Bool) -> Void) {
        do {
            let requestData = try JSONEncoder().encode(userRequest)
            let requestDict = try JSONSerialization.jsonObject(with: requestData, options: .allowFragments) as? [String: Any]
            
            let requestId = userRequest.id
            
            // Update in global /requests/ node
            database.child("requests").child(requestId).setValue(requestDict) { error, _ in
                if let error = error {
                    print("Failed to update user request in global requests: \(error)")
                    completion(false)
                } else {
                    // Also update the requestId under the specific user's branch
                    self.database.child("users").child(userId).child("requests").child(requestId).setValue(true) { error, _ in
                        if let error = error {
                            print("Failed to update requestId under user's requests: \(error)")
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                }
            }
        } catch {
            print("Failed to encode user request: \(error)")
            completion(false)
        }
    }
    
    // Retrieve all user requests (not specific to any user)
    func retrieveAllUserRequests(completion: @escaping ([UserRequest]) -> Void) {
        database.child("requests").observeSingleEvent(of: .value) { snapshot in
            var userRequests = [UserRequest]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let value = childSnapshot.value as? [String: Any],
                   let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []),
                   var userRequest = try? JSONDecoder().decode(UserRequest.self, from: jsonData) {
                    userRequest.id = childSnapshot.key
                    userRequests.append(userRequest)
                }
            }
            completion(userRequests)
        }
    }
    
    // Retrieve user requests for a specific user
    func retrieveUserRequests(userId: String, completion: @escaping ([UserRequest]) -> Void) {
        database.child("users").child(userId).child("requests").observeSingleEvent(of: .value) { snapshot in
            var userRequests = [UserRequest]()
            let group = DispatchGroup()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot {
                    let requestId = childSnapshot.key
                    
                    group.enter()
                    self.database.child("requests").child(requestId).observeSingleEvent(of: .value) { requestSnapshot in
                        if let value = requestSnapshot.value as? [String: Any],
                           let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []),
                           var userRequest = try? JSONDecoder().decode(UserRequest.self, from: jsonData) {
                            userRequest.id = requestId
                            userRequests.append(userRequest)
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                completion(userRequests)
            }
        }
    }
    
    // Delete a user request
    func deleteUserRequest(userId: String, requestId: String, completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var didSucceed = true
        
        // Remove from global /requests/ node
        group.enter()
        database.child("requests").child(requestId).removeValue { error, _ in
            if let error = error {
                print("Failed to delete user request from global requests: \(error)")
                didSucceed = false
            }
            group.leave()
        }
        
        // Remove requestId from user's branch
        group.enter()
        database.child("users").child(userId).child("requests").child(requestId).removeValue { error, _ in
            if let error = error {
                print("Failed to delete requestId from user's requests: \(error)")
                didSucceed = false
            }
            group.leave()
        }
        
        // Notify completion when both tasks are done
        group.notify(queue: .main) {
            completion(didSucceed)
        }
    }
}

// CATEGORIES
extension DatabaseManager{
    func fetchCategories(completion: @escaping ([String: Category]?) -> Void) {
        database.child("categories").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: [String: String]] else {
                completion(nil)
                return
            }

            var categories: [String: Category] = [:]
            for (key, dict) in value {
                if let categoryName = dict["category"],
                   let imageId = dict["image_id"] {
                    categories[key] = Category(category: categoryName, image_id: imageId)
                }
            }
            completion(categories)
        }
    }
    
    ///not very useful
    func insertCategories(categories: [String: Category], completion: @escaping (Bool) -> Void) {
        var categoriesData: [String: [String: String]] = [:]
        
        for (key, category) in categories {
            categoriesData[key] = [
                "category": category.category,
                "image_id": category.image_id ?? ""
            ]
        }
        
        database.child("categories").setValue(categoriesData) { error, _ in
            if let error = error {
                print("Failed to insert categories: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Categories inserted successfully.")
                completion(true)
            }
        }
    }
}
