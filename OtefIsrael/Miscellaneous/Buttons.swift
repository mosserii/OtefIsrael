//
//  Buttons.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 21/08/2024.
//

import Foundation
import UIKit

class GradientSymbolButton: UIButton {

    // Set gradient colors
    private let startColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
    private let endColor = UIColor(red: 0.2, green: 0.3, blue: 0.0, alpha: 0.7)

    init(title: String, symbolName: String) {
        super.init(frame: .zero)
        configureButton(title: title, symbolName: symbolName)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureButton(title: "", symbolName: "")
    }

    private func configureButton(title: String, symbolName: String) {
        setTitle(title, for: .normal)

        // Set the image for the button
        if let symbolImage = UIImage(systemName: symbolName)?.withRenderingMode(.alwaysTemplate) {
            setImage(symbolImage, for: .normal)
            tintColor = .white
        }
        
        if symbolName == "instagram" {
            if let symbolImage = UIImage(named: symbolName)?.withRenderingMode(.alwaysTemplate) {
                setImage(symbolImage, for: .normal)
                tintColor = .white
            }
        }

        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        layer.cornerRadius = 12
        layer.masksToBounds = true

        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]

        // Set the gradient layer as the background of the button
        setBackgroundImage(image(withColor: startColor), for: .normal)
        setBackgroundImage(image(withColor: endColor), for: .highlighted)

        // Insert the gradient layer at the bottom of the layers stack
        layer.insertSublayer(gradientLayer, at: 0)
    }

    private func image(withColor color: UIColor) -> UIImage {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bounds
        }
    }
}
