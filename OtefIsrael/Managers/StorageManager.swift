//
//  StorageManager.swift
//  DestinationSmartFinder
//
//  Created by Zohar Mosseri on 20/02/2024.
//

import Foundation
import FirebaseStorage
import CoreLocation
import FirebaseAuth

/// Allows you to get, fetch, and upload files to firebase  storage
final class StorageManager {

    static let shared = StorageManager()

    private init() {}

    private let storage = Storage.storage().reference()

    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    

    /// Uploads picture to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        // Check if the data size is larger than 5MB
        let tenMB = 10 * 1024 * 1024
        if data.count > tenMB {
            completion(.failure(StorageErrors.fileTooLarge))
            return
        }

        storage.child("profilePics/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                // failed
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }

            // Get download URL
            strongSelf.storage.child("profilePics/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }

                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    func uploadImage(_ image: UIImage, forEventWithID eventID: String, userName: String, completion: @escaping UploadPictureCompletion) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(StorageErrors.failedToUpload))
            return
        }

        // Check if imageData is larger than 5MB
        let tenMB = 10 * 1024 * 1024
        if imageData.count > tenMB {
            completion(.failure(StorageErrors.fileTooLarge))
            return
        }

        let imageName = "\(userName)_\(UUID().uuidString).jpg"
        let storageRef = storage.child("eventImages").child(eventID).child(imageName)

        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                storageRef.downloadURL { (url, error) in
                    if let url = url {
                        completion(.success(url.absoluteString))
                    } else if let error = error {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func getAllDestinationImages(forDestinationWithName destinationName: String? = nil, folderName: String,  completion: @escaping (Result<[URL], Error>) -> Void) {
        
        //todo big check if it's in main thread or not, if not so just create another function
        var storageRef = storage.child(folderName)

        if let destinationName = destinationName{
            storageRef = storage.child(folderName).child(destinationName) //destinationImages
        }
        
        
        storageRef.listAll { (result, error) in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                var imageUrls: [URL] = []

                for item in result.items {
                    item.downloadURL { (url, error) in
                        if let url = url {
                            imageUrls.append(url)
                        } else if let error = error {
                            completion(.failure(error))
                            return
                        }

                        // Check if this is the last item
                        if imageUrls.count == result.items.count {
                            completion(.success(imageUrls))
                        }
                    }
                }
            }
        }
    }
    
    func getAllImagesWithFilenames(forDestinationWithName destinationName: String? = nil, folderName: String, completion: @escaping (Result<[String: URL], Error>) -> Void) {
        
        var storageRef = storage.child(folderName)

        if let destinationName = destinationName {
            storageRef = storage.child(folderName).child(destinationName)
        }
        
        storageRef.listAll { (result, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                var imageUrlsDict: [String: URL] = [:]
                let group = DispatchGroup()

                for item in result!.items {
                    group.enter()
                    item.downloadURL { (url, error) in
                        defer { group.leave() }
                        
                        if let url = url {
                            // Get the file name without the extension
                            let fileNameWithoutExtension = url.deletingPathExtension().lastPathComponent
                            imageUrlsDict[fileNameWithoutExtension] = url
                        } else if let error = error {
                            completion(.failure(error))
                            return
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    // Check if the dictionary has the same number of entries as the result items count
                    if imageUrlsDict.count == result!.items.count {
                        completion(.success(imageUrlsDict))
                    } else {
                        // This means some URLs failed to download, handle this case as needed
                        let error = NSError(domain: "ImageDownloadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not all images could be downloaded."])
                        completion(.failure(error))
                    }
                }
            }
        }
    }


    
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
        case fileTooLarge
    }

    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)

        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }

            completion(.success(url))
        })
    }
}

extension StorageManager {
    
    func uploadRequestImages(requestId: String, images: [UIImage], completion: @escaping (Result<[String], Error>) -> Void) {
        let storageRef = Storage.storage().reference().child("requestsImages/\(requestId)")
        var downloadURLs: [String] = []
        let group = DispatchGroup()
        
        for (index, image) in images.enumerated() {
            group.enter()
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                group.leave()
                continue
            }
            
            let imageRef = storageRef.child("image_\(index + 1).jpg")
            imageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Failed to upload image: \(error)")
                    group.leave()
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("Failed to get download URL: \(error)")
                        group.leave()
                        return
                    }
                    
                    if let url = url {
                        downloadURLs.append(url.absoluteString)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if downloadURLs.count == images.count {
                completion(.success(downloadURLs))
            } else {
                completion(.failure(NSError(domain: "Upload failed", code: -1, userInfo: nil)))
            }
        }
    }
}
