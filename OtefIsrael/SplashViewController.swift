//
//  SplashViewController.swift
//  DestinationSmartFinder
//
//  Created by Zohar Mosseri on 15/01/2024.
//

import Foundation
import UIKit


class SplashViewController : UIViewController {
    
    var animationCompletionHandler: (() -> Void)?
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "launchLogo")
        return imageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.frame = view.bounds
        view.backgroundColor = .white
        view.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.animate()
        })
    }
    
    private func animate() {
        let scaleFactor: CGFloat = 2
        let newWidth = imageView.frame.width * scaleFactor
        let newHeight = imageView.frame.height * scaleFactor
        let diffX = (view.frame.width - newWidth) / 2
        let diffY = (view.frame.height - newHeight) / 2

        UIView.animate(withDuration: 1, animations: {
            self.imageView.frame = CGRect(x: diffX, y: diffY, width: newWidth, height: newHeight)
        })
        
        UIView.animate(withDuration: 1.5, animations: {
            self.imageView.alpha = 0
        }, completion: { done in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.animationCompletionHandler?()
            })
        })
    }

}
