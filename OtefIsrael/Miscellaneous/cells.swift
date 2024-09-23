//
//  cells.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 21/08/2024.
//

import Foundation
import UIKit

//class RequestCell: UICollectionViewCell {
//
//    let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        return imageView
//    }()
//
//    let titleLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .right // Align text to the right
//        label.font = UIFont.boldSystemFont(ofSize: 16)
//        label.numberOfLines = 1
//        return label
//    }()
//
//    let categoriesLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .right // Align text to the right
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = .gray
//        label.numberOfLines = 1
//        return label
//    }()
//
//    let descriptionLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .right // Align text to the right
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.numberOfLines = 0
//        return label
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setupViews() {
//        backgroundColor = .white
//        layer.cornerRadius = 8
//        layer.borderWidth = 1
//        layer.borderColor = UIColor.lightGray.cgColor
//        clipsToBounds = true
//
//        addSubview(imageView)
//        addSubview(titleLabel)
//        addSubview(categoriesLabel)
//        addSubview(descriptionLabel)
//
//        // Layout the imageView to take the top third of the cell
//        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 3)
//
//        // Layout the titleLabel below the imageView
//        titleLabel.frame = CGRect(x: 8, y: imageView.frame.maxY + 8, width: frame.width - 16, height: 20)
//
//        // Layout the categoriesLabel below the titleLabel
//        categoriesLabel.frame = CGRect(x: 8, y: titleLabel.frame.maxY + 4, width: frame.width - 16, height: 20)
//
//        // Layout the descriptionLabel to take the bottom third of the cell
//        descriptionLabel.frame = CGRect(x: 8, y: categoriesLabel.frame.maxY + 4, width: frame.width - 16, height: frame.height / 3)
//    }
//}

class RequestCell: UICollectionViewCell {
    
    let maxTitleCharacters = 50 // Limit the title to 50 characters

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right // Align text to the right
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0 // Allow multiple lines
        return label
    }()

    let categoriesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right // Align text to the right
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()
    
    let cityLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right // Align text to the right
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right // Align text to the right
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        clipsToBounds = true

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(categoriesLabel)
        addSubview(cityLabel)
        addSubview(descriptionLabel)

        // Layout the imageView to take the top third of the cell
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 3)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Limit the title length
        if let titleText = titleLabel.text, titleText.count > maxTitleCharacters {
            let truncatedText = String(titleText.prefix(maxTitleCharacters)) + "..."
            titleLabel.text = truncatedText
        }

        // Layout the titleLabel with dynamic height
        titleLabel.frame = CGRect(x: 8, y: imageView.frame.maxY + 8, width: frame.width - 16, height: 0)
        titleLabel.sizeToFit() // Adjust the height of titleLabel based on content
        
        // Ensure the title starts from the right
        titleLabel.frame = CGRect(x: frame.width - titleLabel.frame.width - 8, y: imageView.frame.maxY + 8, width: titleLabel.frame.width, height: titleLabel.frame.height)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .right

        // Layout the categoriesLabel below the titleLabel
        categoriesLabel.frame = CGRect(x: 8, y: titleLabel.frame.maxY + 4, width: frame.width - 16, height: 20)
        cityLabel.frame = CGRect(x: 8, y: categoriesLabel.frame.maxY + 4, width: frame.width - 16, height: 20)

        // Layout the descriptionLabel to take the remaining space
        descriptionLabel.frame = CGRect(x: 8, y: cityLabel.frame.maxY + 4, width: frame.width - 16, height: frame.height - cityLabel.frame.maxY - 12)
    }
}





class ExploreEventCell: UITableViewCell {
    
    
    let segmentImages: [UIImage] = [
        UIImage(named: "launchLogo")!,
//        UIImage(named: "marchSquare")!, //MARCHANN , marchWithPoster,marchSquare
//        UIImage(named: "circleRibbon")! //BlackANN, BlackLogo, yellowANN, RibbonANN
    ]
    
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    
    var ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        //imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()

    var timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        return label
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func setupSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(ImageView)
        contentView.addSubview(timestampLabel)
        
        // Setup constraints for subviews
        NSLayoutConstraint.activate([
            // Image View constraints
            ImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ImageView.widthAnchor.constraint(equalToConstant: 64),
            ImageView.heightAnchor.constraint(equalToConstant: 64),

            
            // Title Label constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: ImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),


            // Timestamp Label constraints
            timestampLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timestampLabel.leadingAnchor.constraint(equalTo: ImageView.trailingAnchor, constant: 16),
            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timestampLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    
    func configure(with request: UserRequest) {
        DispatchQueue.main.async {
            if request.id == "dummy"{
                self.titleLabel.text = "JOIN A NEW EVENT"
                self.titleLabel.font = .systemFont(ofSize: 26)
                self.ImageView.isHidden = true
                self.timestampLabel.isHidden = true
            }
            else{
                self.titleLabel.text = request.title
                
                if let date = request.date{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
                    let formattedTimestamp = dateFormatter.string(from: date)
                    self.timestampLabel.text = formattedTimestamp
                }
                let eventImage = self.segmentImages[0]
                self.ImageView.image = eventImage
            }
        }
    }
}


class CategoriesCell: UICollectionViewCell {
        
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderColor = isSelected ? UIColor.gray.cgColor : UIColor.clear.cgColor
            contentView.layer.borderWidth = isSelected ? 2.0 : 0
            
            if isSelected{
                animateImageView()
            }
        }
    }
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var answerName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .link
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
        setupLayout()
    }
    
    private func setupSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(answerName)
    }
    
    private func setupLayout() {
        let padding: CGFloat = 12 // Padding around the content
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            imageView.widthAnchor.constraint(equalToConstant: 130), //130, 150
            imageView.heightAnchor.constraint(equalToConstant: 115), // 115, 130
            
            answerName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: padding),
            answerName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            answerName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            answerName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13),
        ])
        
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.borderWidth = 0
        contentView.layer.cornerRadius = 10
    }

    func animateImageView() {
        // Start by reducing the image to be slightly smaller and faded
        self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.imageView.alpha = 0.5

        // Animate to a larger size with a slight rotation, then back to normal
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.6, // Spring effect
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseInOut],
                       animations: {
            // Scale and rotate the image
            self.imageView.transform = CGAffineTransform(rotationAngle: .pi / 10).scaledBy(x: 1.1, y: 1.1)
            self.imageView.alpha = 1.0 // Fade back to full opacity
        }) { _ in
            // Return to the original state with a bounce effect
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.transform = CGAffineTransform.identity // Reset to original
            })
        }
    }

    
    func configure(answer: Category, imageName: String) {
        setupSubviews()  // Call setupSubviews here
        if let namedImage = UIImage(systemName: answer.image_id){
            imageView.image = namedImage
        }
        else if let namedImage = UIImage(named: answer.category){
            imageView.image = namedImage
        }
        else if let namedImage = UIImage(systemName: answer.category){
            imageView.image = namedImage
        }
        else if let imageName = CategoryManager.shared.getImageUrl(forAnswer: answer.category){
            imageView.sd_setImage(with: imageName, placeholderImage: UIImage(systemName: "airplane"))
        }
        else if let systemImage = UIImage(systemName: imageName){
            imageView.image = systemImage
            if imageName == "airplane"{
                print("airplane in : \(answer.category)")
            }
        }
        imageView.tintColor = .link
        answerName.text = answer.category.capitalized
    }
}



struct FilterOption {
    var name: String
    var isSelected: Bool
}

struct FilterSection {
    var title: String
    var options: [FilterOption]
}

class FilterOptionCell: UITableViewCell {
    
    static let identifier = "FilterOptionCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkboxButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkboxButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 30),
            checkboxButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: checkboxButton.leadingAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with option: FilterOption) {
        titleLabel.text = option.name
        checkboxButton.isSelected = option.isSelected
    }
}


class InfoTableViewCell: UITableViewCell {
    
    let customImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    let customLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right // Align text to the right
        return label
    }()
    
    let customDisclosureIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.left")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(customImageView)
        contentView.addSubview(customLabel)
        contentView.addSubview(customDisclosureIndicator)
        
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        customDisclosureIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up layout constraints for the custom image view, label, and disclosure indicator
        NSLayoutConstraint.activate([
            // Image view on the right
            customImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customImageView.widthAnchor.constraint(equalToConstant: 24),
            customImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Label to the left of the image view
            customLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40), // Space for the disclosure indicator
            customLabel.trailingAnchor.constraint(equalTo: customImageView.leadingAnchor, constant: -8),
            customLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Disclosure indicator on the left edge
            customDisclosureIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customDisclosureIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customDisclosureIndicator.widthAnchor.constraint(equalToConstant: 12),
            customDisclosureIndicator.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
