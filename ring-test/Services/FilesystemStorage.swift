//
//  FilesystemStorage.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/10/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

final class FilesystemStorage {
    private static let fsQueue = DispatchQueue.init(label: "com.grandima.fs", attributes: .concurrent)
    
    private let dictStorage = FilesystemCodable<[String: String]>(initialValue: [:])
    
    private let folderName: String
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if let result = paths.first {
            if FileManager.default.fileExists(atPath: result) {
                folderName = result
            } else {
                do {
                    try FileManager.default.createDirectory(atPath: result, withIntermediateDirectories: false, attributes: nil)
                    folderName = result
                } catch {
                    folderName = ""
                }
            }
        } else {
            folderName = ""
        }
    }
    
    func getImage(for urlKey: String) -> UIImage? {
        return FilesystemStorage.fsQueue.sync {
            guard let fileKey = dictStorage.value[urlKey] else { return nil }
            let newUrlString = URL.init(fileURLWithPath: folderName).appendingPathComponent(fileKey)
            var image: UIImage?
            if let data = try? Data.init(contentsOf: newUrlString) {
                image = UIImage.init(data: data)
            }
            return image
        }
    }

    func save(data: Data, for urlKey: String) {
        let fileKey = UUID.init().uuidString
        let url = URL.init(fileURLWithPath: folderName).appendingPathComponent(fileKey)
        FilesystemStorage.fsQueue.async(flags: .barrier, execute: {
            var dict = self.dictStorage.value
            dict[urlKey] = fileKey
            self.dictStorage.value = dict
            try? data.write(to: url, options: .atomic)
        })
    }
}
