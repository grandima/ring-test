//
//  PresentationModel.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/8/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import Foundation

struct PresentationRoot: Codable {
    let posts: [PresentationPost]
    let after: String?
    let before: String?
    init(posts: Root.Data, oldPosts: [PresentationPost]) {
        self.after = posts.after
        self.before = posts.before
        self.posts = oldPosts + posts.children.map({PresentationPost.init(post: $0.data)})
    }
}
