//
//  AppDelegate.swift
//
//  Created by Zohar Mosseri on 15/01/2024.
//


import UIKit
import PushKit
import FirebaseCore
import FirebaseAuth
import FBSDKCoreKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Load categories from CategoryManager
        CategoryManager.shared.loadCategories()
        
        // Set UI style to light mode if iOS 13.0 or later
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
              // Show the app's signed-out state.
            } else { //TODO!!!
              // Show the app's signed-in state.
            }
          }
        
        // Facebook SDK initialization
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        return true
    }

    // Handle when the user is signed in
    func handleUserSignedIn(window: UIWindow) {
        if let currentUser = FirebaseAuth.Auth.auth().currentUser {
            SpinnerManager.shared.showSpinner()
            let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainHome")
            mainViewController.modalPresentationStyle = .fullScreen
            window.rootViewController = mainViewController
        } else {
            SpinnerManager.shared.showSpinner()
            let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainHome")
            mainViewController.modalPresentationStyle = .fullScreen
            window.rootViewController = mainViewController
        }
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
    

    // MARK: Handling URLs for Facebook and Google
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle Facebook URL
        if ApplicationDelegate.shared.application(app, open: url, options: options) {
            return true
        }
        
        // Handle Google URL
        return GIDSignIn.sharedInstance.handle(url)
    }
}




/*
import UIKit
import PushKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }

    func handleUserSignedIn(window: UIWindow) {
        handleVerificationStatusChange(window: window)
    }
    
    
    func handleVerificationStatusChange(window: UIWindow) {
        DispatchQueue.main.async {
            let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainHome")
            mainViewController.modalPresentationStyle = .fullScreen
            window.rootViewController = mainViewController
        }
    }


    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
*/
