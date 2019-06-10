//
//  FilesystemCodable.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/10/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import Foundation

final class FilesystemCodable<Value: Codable> {
    
    fileprivate let defaults: UserDefaults
    
    fileprivate let encoder: JSONEncoder
    fileprivate let decoder: JSONDecoder
    
    fileprivate let initialValue: Value
    fileprivate let fileURL: URL?
    var value: Value {
        didSet {
            permanentValue = value
        }
    }
    
    init(initialValue: Value, key: String = #function, defaults: UserDefaults = .standard, encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
        self.fileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(key + ".json")
        self.initialValue = initialValue
        self.value = initialValue
        self.defaults = defaults
        self.encoder = encoder
        encoder.outputFormatting = .prettyPrinted
        self.decoder = decoder
        
        self.value = permanentValue
    }
    
    var permanentValue: Value {
        get {
            guard let fileURL = fileURL else {
                return initialValue
            }
            do {
                let data = try Data.init(contentsOf: fileURL)
                let value = try decoder.decode(Value.self, from: data)
                return value
            }
            catch {
                print("Error while getting a file: " + error.localizedDescription)
                return initialValue
            }
        }
        set {
            do {
                let data = try encoder.encode(newValue)
                if let fileURL = fileURL {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        try FileManager.default.removeItem(atPath: fileURL.path)
                    }
                    try data.write(to: fileURL, options: .atomicWrite)
                }
            }
            catch {
                print("Error while saving a file: " + error.localizedDescription)
            }
            
        }
    }
}
