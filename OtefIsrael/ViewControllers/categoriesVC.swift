//
//  categoriesVC.swift
//  OtefIsrael
//
//  Created by Zohar Mosseri on 22/08/2024.
//

import Foundation
import UIKit



class categoriesVC: UIViewController {
    
    var collectionView: UICollectionView!
    var categories: [Category] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    var selectedCategory: IndexPath?
    var allowMultiple: Bool = false
    
    var minChoices : Int?
    var maxChoices : Int? = 1
    
    var didSelectCategory: ((Category?) -> Void)?
    
    private let titleLabel: UILabel = {
         let label = UILabel()
         label.text = "קטגוריות"
         label.textAlignment = .right
         label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
         return label
     }()
     
     private let subtitleLabel: UILabel = {
         let label = UILabel()
         label.text = "בחר קטגוריה המתאימה לבקשתך"
         label.textAlignment = .right
         label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
         return label
     }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        var layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.width/2) - 3, height: (view.width/1.8) - 3)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.allowsMultipleSelection = allowMultiple //maybe allow sometimes
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(CategoriesCell.self, forCellWithReuseIdentifier: "CategoriesCell")
        
        let exitButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(exitButtonTapped))
        navigationItem.rightBarButtonItem = exitButton

        view.addSubview(collectionView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         if let selectedCategory = selectedCategory {
             let selectedCategoryModel = categories[selectedCategory.row]
             didSelectCategory?(selectedCategoryModel)
         }
     }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set frames for title and subtitle labels
        let padding: CGFloat = 16
        let titleHeight: CGFloat = 30
        let subtitleHeight: CGFloat = 20
        
        titleLabel.frame = CGRect(x: padding, y: view.safeAreaInsets.top + padding, width: view.frame.size.width - 2 * padding, height: titleHeight)
        subtitleLabel.frame = CGRect(x: padding, y: titleLabel.frame.maxY + 5, width: view.frame.size.width - 2 * padding, height: subtitleHeight)
        
        // Adjust collectionView frame to be below the labels
        collectionView.frame = CGRect(x: 0, y: subtitleLabel.frame.maxY + 10, width: view.frame.size.width, height: view.frame.size.height - subtitleLabel.frame.maxY - 10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    @objc func exitButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

}


extension categoriesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = categories[indexPath.item]
        
        let imageName = CategoryManager.shared.getImageName(forAnswer: category.category)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCell", for: indexPath) as! CategoriesCell
        
        cell.configure(answer: category, imageName: imageName ?? "airplane")
        return cell
    }
}

extension categoriesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        
        if category.category == "אחר" {
            presentCustomCategoryAlert()
        } else {
            if let cell = collectionView.cellForItem(at: indexPath) as? CategoriesCell {
                let selectedItems = collectionView.indexPathsForSelectedItems ?? []
                var selectedCount = selectedItems.count

                if selectedItems.count > self.maxChoices! {
                    collectionView.deselectItem(at: indexPath, animated: true)
                    selectedCount -= 1
                    showAlert(message: "You reached the limit of \(self.maxChoices!)")
                    return
                }
                cell.isSelected = true
                self.selectedCategory = indexPath
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    private func presentCustomCategoryAlert() {
        let alertController = UIAlertController(title: "הכנס קטגוריה", message: "אנא הכנס את שם הקטגוריה שלך:", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "קטגוריה מותאמת אישית"
        }
        let confirmAction = UIAlertAction(title: "אישור", style: .default) { [weak self] _ in
            if let customCategory = alertController.textFields?.first?.text, !customCategory.isEmpty {
                let newCategory = Category(category: customCategory)
                self?.didSelectCategory?(newCategory)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self?.dismiss(animated: true)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "ביטול", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
