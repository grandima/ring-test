//
//  PostViewModel.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/8/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

protocol PostViewModelDelegate: class {
    func didUpdateImage(for post: PostViewModel)
}

class PostViewModel: Codable {
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
    
    weak var delegate: PostViewModelDelegate?
    
    private let post: Post
    init(post: Post) {
        self.post = post
    }
}

extension PostViewModel: Equatable {
    static func == (lhs: PostViewModel, rhs: PostViewModel) -> Bool {
        return lhs.url == rhs.url
    }
    
    
}
