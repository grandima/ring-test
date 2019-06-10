//
//  ImageManager.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/9/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

final class ImageManager {
    
    static let shared = ImageManager.init()
    
    private let imageCache = NSCache<NSString, UIImage>()
    private let workerQueue = DispatchQueue.init(label: "com.grandima.worker", attributes: .concurrent)
    private let cacheQueue = DispatchQueue.init(label: "com.grandima.cache", attributes: .concurrent)
    
    private let fileSystemStorage = FilesystemStorage.init()
    
    private init() {}
    
    
    func getImage(for urlString: String, completion: @escaping (UIImage?)->Void) {
        let internalCompletion: (UIImage?)->Void  = { image in
            DispatchQueue.main.async {
                completion(image)
            }
        }
        workerQueue.async {
            if let image = self.cacheQueue.sync(execute: { return self.imageCache.object(forKey: urlString as NSString) }) {
                internalCompletion(image)
            } else if let image = self.fileSystemStorage.getImage(for: urlString) {
                internalCompletion(image)
                self.cacheQueue.async(flags: .barrier, execute: {
                    self.imageCache.setObject(image, forKey: urlString as NSString)
                })
            } else if let url = URL.init(string: urlString) {
                URLSession.shared.dataTask(with: url, completionHandler: { (data, _, _) in
                    var wrappedImage: UIImage?
                    if let data = data, let image = UIImage.init(data: data) {
                        wrappedImage = image
                        self.workerQueue.async {
                            self.cacheQueue.async(flags: .barrier, execute: {
                                self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                            })
                        }
                        self.fileSystemStorage.save(data: data, for: urlString)
                    }
                    internalCompletion(wrappedImage)
                }).resume()
            }
        }
    }
    

    
   
}
