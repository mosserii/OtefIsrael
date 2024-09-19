//
//  Models.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 21/08/2024.
//

import Foundation
import UIKit
import MapKit


import Foundation

struct User: Identifiable {
    var id = UUID().uuidString
    var firstName: String
    var lastName: String
    var originalCity: String? = nil
    var currentCity: String? = nil
    var email: String
    var requests: [String]
    var phoneNumber : String
}

struct UserRequest: Identifiable, Equatable, Codable {
    var id: String = UUID().uuidString
    var isDemand: Bool
    var isPublic: Bool
    let title: String
    var categories: [String]
    var oldCity: String?
    var currentCity: String?
    var age: String?
    var date: Date?
    var description: String?
    var user_id: String
    var email: String?
    var phone: String?
    var imageUrls: [String]?

    static func == (lhs: UserRequest, rhs: UserRequest) -> Bool {
        return lhs.id == rhs.id
    }
}


struct Category: Codable, Equatable {
    var category: String
    var image_id: String? = nil
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.category == rhs.category && lhs.image_id == rhs.image_id
    }
}
