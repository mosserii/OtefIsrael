//
//  CategoryManager.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 22/08/2024.
//
import Foundation
import MapKit
import UIKit
import CoreLocation
import SDWebImage

class CategoryManager {
    static let shared = CategoryManager()

    var categories: [String: Category] = [
        "math": Category(category: "מתמטיקה", image_id: "math_image"),
        "housing": Category(category: "בית", image_id: "housing_image"),
        "furniture": Category(category: "ריהוט", image_id: "furniture_image"),
        "birthday": Category(category: "יומהולדת", image_id: "birthday_image"),
        "other": Category(category: "אחר", image_id: "other_image"),
        // Add more categories as needed
    ]
    
    let answerSymbols: [String: String] = [
        "Going Solo": "person",
        "Alone": "person",
        "Partner": "heart",
        "Friends": "person.3.sequence",
        "Family": "figure.2.and.child.holdinghands",
        
        "alone": "person",
        "partner": "heart",
        "friends": "person.3.sequence",
        "family": "figure.2.and.child.holdinghands",
        
        
        "Weekend": "3.square.fill",
        "Week": "7.square.fill",
        "2 Weeks": "14.square.fill",
        "Month": "30.square.fill",
        "Locks": "locksinParis",
        "Meuseum": "louvre",
        "Church": "sacreCeour",
        "Architecture": "tourEiffel",
        "Culture & History": "building.columns",
        "Extreme & Outdoor": "figure.skiing.downhill",
        "Outdoor & Extreme": "figure.skiing.downhill", //"figure.equestrian.sports",  //figure.outdoor.cycle //figure.equestrian.sports //figure.jumprope"
        "Culinary Experience": "fork.knife",
        "Relaxation & Wellness": "figure.mind.and.body", //"peacesign", //"figure.yoga" //"figure.mind.and.body"
        "Urban & Entertainment": "building.2.fill",

        "Nature": "mountain.2.fill",
        "nature": "mountain.2.fill",
        "Urban": "building.2.fill",


        "Public Transport" : "bus",
        "By foot" : "figure.walk",
        "City walks" : "figure.walk",
        "city walks" : "figure.walk",
        "Bicycle": "bicycle",
        "Taxi": "car.front.waves.up",
        
        "Footbal (American)": "football.fill",
        "Footbal": "football.fill",
        "Soccer": "soccerball",
        "Basketball": "basketball.fill",
        "Baseball": "baseball.fill",
        "Beseball": "baseball.fill", //todo change name
        "Tennis": "tennisball.fill",
        "Hockey": "hockey.puck.fill",
        "Cricket": "cricket.ball.fill",
        "Rugby": "figure.rugby",
        "Cycling": "figure.outdoor.cycle",
        "Golf": "figure.golf",

        "doing martial arts" : "figure.martial.arts",
        "playing table tennis": "figure.table.tennis",
        "playing squash": "figure.squash",
        "skiing": "figure.skiing.downhill",
        "yoga class" : "figure.yoga",
        "playing cricket" : "figure.cricket",
        "playing golf": "figure.golf",
        "playing soccer": "figure.soccer",
        "camping": "tent.2.fill",
        "cycling": "figure.outdoor.cycle",
        "snowboarding": "figure.snowboarding",
        "playing badminton": "figure.badminton",
        "skateboarding": "figure.skating",
        "water activities": "figure.waterpolo",
        "bowling": "figure.bowling",
        "playing hockey": "figure.hockey",
        "playing american football": "figure.american.football",
        "playing tennis": "figure.tennis",
        "playing rugby": "figure.rugby",
        "rock climbing": "figure.climbing",
        "running marathon": "figure.run",
        "playing baseball": "figure.baseball",
        "playing basketball": "figure.basketball",
        "playing volleyball": "figure.volleyball",
        "fishing": "figure.fishing",

        
        "1": "1.square.fill",
        "2": "2.square.fill",
        "3": "3.square.fill",
        "4": "4.square.fill",
        "5": "5.square.fill",
        "6": "6.square.fill",
        "7": "7.square.fill",
        "8": "8.square.fill",
        "9": "9.square.fill",
        "10": "10.square.fill",
        "11": "11.square.fill",
        "12": "12.square.fill",
        "13": "13.square.fill",
        "14": "14.square.fill",
        "ריהוט": "sofa.fill",
        "בית": "house.fill",
        "מתמטיקה": "textformat.123",
        "אחר": "questionmark",
        "יומהולדת": "birthday.cake.fill",
    ]
    
    func loadCategories() {
        DatabaseManager.shared.fetchCategories { [weak self] fetchedCategories in
            guard let self = self, let categories = fetchedCategories else { return }
            self.categories = categories
        }
    }
    
    func getCategories() -> [Category] {
        return Array(categories.values)
    }
    
    var answerImages: [String: URL] = [:] {
        didSet {
            SDWebImagePrefetcher.shared.prefetchURLs(Array(answerImages.values))
        }
    }

    func getImageName(forAnswer answer: String) -> String? {
        return answerSymbols[answer]
    }
    
    func getImageUrl(forAnswer answer: String) -> URL? {
        return answerImages[answer]
    }
    
    func insertCategories() {
        DatabaseManager.shared.insertCategories(categories: self.categories) { success in
            if success {
                print("Categories were successfully added to Firebase.")
            } else {
                print("There was an issue adding the categories to Firebase.")
            }
        }
    }
}

