//
//  PresentationPost.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/8/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import Foundation

struct PresentationPost: Codable {
    private let post: Post
    var title: String {
        return post.title
    }
    var authorName: String {
        return post.author
    }
    var commentsCountString: String {
        return String.init(post.commentsCount)
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
