//
//  NetworkManager.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/9/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import Foundation

final class NetworkManager {
    enum NetworkErrors: Error {
        case whileBuildingRequest
        case network(Error)
        case parsing(Error)
    }
    private let baseUrlComponents: URLComponents = {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "reddit.com"
        return urlComponents
    }()
    func getTopPosts(after: String? = nil, count: Int? = nil, completion: @escaping(Result<Root, NetworkErrors>)->Void) {
        var components = baseUrlComponents
        
        components.queryItems = [URLQueryItem.init(name: "after", value: after),
                                 URLQueryItem.init(name: "count", value: (count ?? 0).description)]
        guard let url = components.url?.appendingPathComponent("top.json") else { return completion(.failure(.whileBuildingRequest)) }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.network(error)))
                }
            } else if let data = data {
                do {
                    let root = try JSONDecoder.init().decode(Root.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(root))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.parsing(error)))
                    }
                }
            }
        }.resume()
    }
    
}
