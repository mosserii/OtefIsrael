
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
            "isAdmin": user.isAdmin,
            "phone": user.phoneNumber,
            "first_name": user.firstName,
            "last_name": user.lastName,
            "requests": user.requests
        ]
        
        userValues["model_version"] = 1
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
    
    
    public func updateUser(with updatedUser: User, completion: @escaping (Bool) -> Void) {
        // Prepare the dictionary of values to update
        var updatedValues: [String: Any] = [:]
        
        // Update only the fields that are not nil or have changed
        updatedValues["first_name"] = updatedUser.firstName
        updatedValues["last_name"] = updatedUser.lastName
        updatedValues["phone"] = updatedUser.phoneNumber
        
        // Handle optional fields
        if let originalCity = updatedUser.originalCity {
            updatedValues["original_city"] = originalCity
        } else {
            updatedValues["original_city"] = NSNull() // Removes the field if nil
        }
        
        if let currentCity = updatedUser.currentCity {
            updatedValues["current_city"] = currentCity
        } else {
            updatedValues["current_city"] = NSNull() // Removes the field if nil
        }
        
        // Add or update model version if needed
        updatedValues["model_version"] = updatedUser.modelVersion ?? 1
        
//        updatedValues["email"] = updatedUser.email
//        updatedValues["isAdmin"] = updatedUser.isAdmin
//        updatedValues["requests"] = updatedUser.requests
        
        // Update the user data in Firebase
        database.child("users").child(updatedUser.id).updateChildValues(updatedValues) { error, _ in
            if let error = error {
                print("Failed to update user: \(error)")
                completion(false)
            } else {
                print("User updated successfully")
                completion(true)
            }
        }
    }

    // Retrieve all users
    func getAllUsers(completion: @escaping ([User]) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            var users = [User]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let value = childSnapshot.value as? [String: Any],
                   let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []),
                   var user = try? JSONDecoder().decode(User.self, from: jsonData) {
                    user.id = childSnapshot.key // Firebase assigns user IDs as keys
                    users.append(user)
                }
            }
            completion(users)
        }
    }
    
    public func getUserData(with user_uid: String, completion: @escaping (User?) -> Void) {
        // Observe a single event to retrieve user data
        database.child("users").child(user_uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userData = snapshot.value as? [String: Any],
                  let userEmail = userData["email"] as? String,
                  let userPhone = userData["phone"] as? String,
                  let firstName = userData["first_name"] as? String,
                  let lastName = userData["last_name"] as? String else {
                print("Failed to get user data:")
                print(snapshot.value as Any)
                completion(nil)
                return
            }
//            let modelVersion = userData["model_version"] as? Int ?? 1 // Default to version 1 for old users
            // Retrieve optional fields if they exist
            let originalCity = userData["original_city"] as? String
            let currentCity = userData["current_city"] as? String

            // Check if `isAdmin` is either a Bool or an Int (1 or 0)
            let isAdmin: Bool
            if let adminValue = userData["isAdmin"] as? Bool {
                isAdmin = adminValue
            } else if let adminValue = userData["isAdmin"] as? Int {
                isAdmin = adminValue == 1
            } else {
                isAdmin = false // Default value if neither Bool nor Int
            }

            
//            var preferredLanguage: String? = nil
//            if modelVersion >= 2 {
//                // Fetch new fields available in version 2 or higher
//                preferredLanguage = userData["preferred_language"] as? String
//            }
            
            // Handle missing `requests` field by making it optional
            let requestsDict = userData["requests"] as? [String: Any]
            let requestsData = requestsDict != nil ? Array(requestsDict!.keys) : [] // Empty array if no requests

            // Create a User object with all the fields
            let user = User(
                id: user_uid,
                isAdmin: isAdmin,
                firstName: firstName,
                lastName: lastName,
                originalCity: originalCity,
                currentCity: currentCity,
                email: userEmail,
                requests: requestsData,
                phoneNumber: userPhone
                //preferredLanguage: preferredLanguage // Add new field for version 2+
            )
            
//            if modelVersion < 2 {
//                self.updateUserToLatestVersion(user: user)
//            }
            

            completion(user)
        }
    }
    
    //TODO if we change the user model
//    public func updateUserToLatestVersion(user: User) {
//        // Create a dictionary to store fields that need to be updated
//        var updatedValues: [String: Any] = [:]
//
//        // Check for fields that need to be added in the latest version
//        if user.preferredLanguage == nil {
//            // Add default value for preferredLanguage if it's missing
//            updatedValues["preferred_language"] = "en" // Set default value as "en" (English)
//        }
//
//        // Set the latest model version
//        updatedValues["model_version"] = 2
//
//        // Perform the update if there are any fields that need to be changed
//        if !updatedValues.isEmpty {
//            // Update the user's data in the database
//            database.child("users").child(user.id).updateChildValues(updatedValues) { error, _ in
//                if let error = error {
//                    print("Failed to migrate user data: \(error)")
//                } else {
//                    print("User data migrated to the latest version.")
//                }
//            }
//        }
//    }

    
    func checkIfUserIsAdmin(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let ref = Database.database().reference()
        ref.child("users").child(userId).child("isAdmin").observeSingleEvent(of: .value) { snapshot in
            if let isAdmin = snapshot.value as? Bool {
                completion(isAdmin)
            } else {
                completion(false)
            }
        }
    }

    func getAdminUserIds(completion: @escaping ([String]) -> Void) {
        let ref = Database.database().reference().child("users")
        ref.queryOrdered(byChild: "isAdmin").queryEqual(toValue: true).observeSingleEvent(of: .value) { snapshot in
            var adminIds = [String]()
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                let adminId = child.key
                adminIds.append(adminId)
            }
            completion(adminIds)
        }
    }
    
    func createNotificationForAdmin(adminID: String, request: UserRequest) {
        let ref = Database.database().reference().child("notifications").child(adminID)
        
        let notificationData: [String: Any] = [
            "title": "New Request for Managers",
            "body": "A new request titled \(request.title) was submitted for review.",
            "timestamp": Date().timeIntervalSince1970,
            "requestId": request.id
        ]
        
        ref.childByAutoId().setValue(notificationData)
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
            
            if !(userRequest.isPublic){
                DatabaseManager.shared.getAdminUserIds { [weak self] adminUsers in
                    guard let self = self else { return }
                    print(adminUsers)
                    // Create a notification for each admin
                    for admin in adminUsers {
                        DatabaseManager.shared.createNotificationForAdmin(adminID: admin, request: userRequest)
                    }
                }
            }
            
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
