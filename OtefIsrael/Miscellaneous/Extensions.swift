//
//  Extentions.swift
//  DestinationSmartFinder
//
//  Created by Zohar Mosseri on 15/01/2024.
//

import Foundation
import UIKit
import CoreLocation


extension UIView {
    
    var width : CGFloat{
        return self.frame.size.width
    }
    
    var height : CGFloat{
        return self.frame.size.height
    }
    
    var top : CGFloat{
        return self.frame.origin.y
    }
    
    var bottom : CGFloat{
        return self.frame.size.height + self.frame.origin.y
    }
    
    var left : CGFloat{
        return self.frame.origin.x
    }
    
    var right : CGFloat{
        return self.frame.size.width + self.frame.origin.x
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension UIResponder {
    var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}


extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        // Start a download task
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async { [weak self] in
                self?.image = UIImage(data: data)
            }
        }.resume()
    }
    
    func applyBottomRoundedMask(for view: UIView, cornerRadius: CGFloat) {
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners: [.bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
    }
}


class GradientButton_: UIButton {
    // Define your gradient colors here
    var gradientColors: [CGColor] = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientLayer()
    }

    private func updateGradientLayer() {
        let gradientLayer = createGradientLayer(colors: gradientColors, frame: bounds)
        // Remove old gradient layer if exists
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        layer.insertSublayer(gradientLayer, at: 0)
    }

    private func createGradientLayer(colors: [CGColor], frame: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = frame.height / 2
        return gradientLayer
    }
}


extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}

extension UITextView {
    func calculateHeightForText(_ text: String, width: CGFloat) -> CGFloat {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        textView.text = text
        textView.font = self.font
        textView.textContainerInset = self.textContainerInset
        textView.textContainer.lineFragmentPadding = self.textContainer.lineFragmentPadding
        textView.sizeToFit()
        return textView.frame.height
    }
}

extension UIView {
    func findEditingTextField() -> UITextView? {
        for view in subviews {
            if let textField = view as? UITextView, textField.isFirstResponder {
                return textField
            } else if let result = view.findEditingTextField() {
                return result
            }
        }
        return nil
    }
}
