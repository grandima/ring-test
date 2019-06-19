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
    enum CodingKeys: CodingKey {
        case post
    }
    private let post: Post
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
        return String.init(post.commentsCount)
    }
    var timeString: String {
        return post.created.convertToStringAgo()
    }
    var thumbnail: String {
        return String.init(post.thumbnail)
    }
    var url: URL? {
        return post.url
    }
    weak var delegate: PresentationPostDelegate?
    init(post: Post) {
        self.post = post
    }
}

extension PresentationPost: Equatable {
    static func == (lhs: PresentationPost, rhs: PresentationPost) -> Bool {
        return lhs.url == rhs.url
    }
    
    
}
