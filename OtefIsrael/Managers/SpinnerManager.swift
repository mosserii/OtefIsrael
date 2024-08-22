//
//  SpinnerManager.swift
//  DestinationSmartFinder
//
//  Created by Zohar Mosseri on 20/02/2024.
//

import Foundation
import UIKit

class SpinnerManager {
    static let shared = SpinnerManager()

    private var animationView = UIImageView()
    private var backgroundView = UIView()
    private var spinnerCount = 0

    private init() {
        setupSpinnerAndBackground()
    }

    private func setupSpinnerAndBackground() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                return
            }

            // Background view setup
            self.backgroundView.frame = window.bounds
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.backgroundView.isHidden = true

            // Image setup
            self.animationView.image = UIImage(named: "redSandClock")
            self.animationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            self.animationView.center = window.center
            self.animationView.contentMode = .scaleAspectFit

            window.addSubview(self.backgroundView)
            window.addSubview(self.animationView)
        }
    }

    func showSpinner() {
        DispatchQueue.main.async {
            self.spinnerCount += 1
            if self.animationView.superview == nil {
                self.setupSpinnerAndBackground()
            }
            self.backgroundView.isHidden = false
            // No need to play animation for UIImageView
        }
    }
    
    func hideSpinner() {
        DispatchQueue.main.async {
            self.spinnerCount -= 1
            if self.spinnerCount <= 0 {
                self.spinnerCount = 0 // Reset to ensure it doesn't go negative
                self.backgroundView.isHidden = true
                self.animationView.isHidden = true // Hide the animation view as well
            }
        }
    }
}
