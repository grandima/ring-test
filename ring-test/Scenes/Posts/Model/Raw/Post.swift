//
//  APPost.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/8/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import Foundation

struct Post {
    let title: String
    let author: String
    let created: Date
    let commentsCount: Int
    let thumbnail: String
    let url: URL?
}

extension Post: Codable {
    
    enum CodingKeys: String, CodingKey {
        case title
        case author
        case thumbnail
        case created = "created_utc"
        case commentsCount = "num_comments"
        case url
    }
    
    init(from decoder: Decoder) throws {
        let data = try decoder.container(keyedBy: CodingKeys.self)
        title = try data.decode(String.self, forKey: .title)
        author = try data.decode(String.self, forKey: .author)
        thumbnail = try data.decode(String.self, forKey: .thumbnail)
        commentsCount = try data.decode(Int.self, forKey: .commentsCount)
        let createdTimestamp: TimeInterval = try data.decode(Double.self, forKey: .created)
        created = Date(timeIntervalSince1970: createdTimestamp)
        url = try data.decode(URL.self, forKey: .url)
    }
    
    func encode(to encoder: Encoder) throws {
        var data = encoder.container(keyedBy: CodingKeys.self)
        try data.encode(title, forKey: .title)
        try data.encode(author, forKey: .author)
        try data.encode(thumbnail, forKey: .thumbnail)
        try data.encode(commentsCount, forKey: .commentsCount)
        try data.encode(created.timeIntervalSince1970, forKey: .created)
        try data.encode(url, forKey: .url)
    }
}
