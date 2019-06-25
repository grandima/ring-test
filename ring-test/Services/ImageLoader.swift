//
//  ImageLoader.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/16/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

protocol ImageLoadable {
    typealias ImageCompletion = ((UIImage?) -> Void)
    func load(for urlString: String, completion: @escaping ImageCompletion)
    func cancel(with urlString: String)
}

class ImageLoader: ImageLoadable {
    
    private let imageCache = NSCache<NSString, UIImage>()
    private let fileSystemStorage = FilesystemStorage.init()
    private var tasks = [URLSessionTask]()
    
    func load(for urlString: String, completion: @escaping (UIImage?) -> Void) {
        let saveBlock: (UIImage) -> Void = { image in
            completion(image)
            self.imageCache.setObject(image, forKey: urlString as NSString)
        }
        if let image = self.imageCache.object(forKey: urlString as NSString) {
            completion(image)
        } else if let image = self.fileSystemStorage.getImage(for: urlString) {
            saveBlock(image)
        } else if let url = URL.init(string: urlString) {
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, _) in
                guard let data = data, let image = UIImage.init(data: data) else { return DispatchQueue.main.async { completion(nil) } }
                DispatchQueue.main.async {
                    saveBlock(image)
                }
                self.fileSystemStorage.save(data: data, for: urlString)
            })
            task.resume()
            tasks.append(task)
        } else {
            completion(nil)
        }
    }
    
    func cancel(with urlString: String) {
        guard let taskIndex = tasks.firstIndex(where: { $0.originalRequest?.url?.absoluteString == urlString }) else {
            return
        }
        let task = tasks[taskIndex]
        task.cancel()
        tasks.remove(at: taskIndex)
    }
}
