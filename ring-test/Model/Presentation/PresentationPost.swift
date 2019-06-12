//
//  PresentationPost.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/8/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

struct PresentationPost: Codable {
    enum CodingKeys: CodingKey {
        case post
    }
    private let post: Post
    var image: UIImage?
    var titleString: String {
        return post.title
    }
    var authorString: String {
        return post.author
    }
    var commentsCountString: String {
        return String.init(post.commentsCount)
    }
    var timeString: String {
        return post.created.convertToStringAgo()
    }
    var thumbnail: String {
        return String.init(post.thumbnail)
    }
    
    init(post: Post) {
        self.post = post
//        self.title = post.title
//        self.author = post.author
//        self.commentsCount = post.commentsCount
//        self.thumbnail = post.thumbnail
//        self.url = post.url
//        self.created = post.created
    }
}
