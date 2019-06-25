//
//  PresentationPost.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/8/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

protocol PresentationPostDelegate: class {
    func didUpdateImage(for post: PresentationPost)
}

class PresentationPost: Codable {
    private enum CodingKeys: CodingKey {
        case post
    }
    var image: UIImage? {
        didSet {
            delegate?.didUpdateImage(for: self)
        }
    }
    
    var titleString: String {
        return post.title
    }
    
    var authorString: String {
        return post.author
    }
    
    var commentsCountString: String {
        return post.commentsCount.description + " comments"
    }
    
    var timeString: String {
        return post.created.convertToStringAgo()
    }
    
    var thumbnailString: String {
        return post.thumbnail
    }
    
    var url: URL? {
        return post.url
    }
    
    weak var delegate: PresentationPostDelegate?
    
    private let post: Post
    init(post: Post) {
        self.post = post
    }
}

extension PresentationPost: Equatable {
    static func == (lhs: PresentationPost, rhs: PresentationPost) -> Bool {
        return lhs.url == rhs.url
    }
    
    
}
