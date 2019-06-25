//
//  PresentationModel.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/8/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import Foundation

struct PresentationRoot: Codable {
    var lastVisibleRow: Int?
    let posts: [PresentationPost]
    let after: String?
    init() {
        posts = []
        after = nil
    }
    init(posts: Root.Data, oldRoot: PresentationRoot) {
        self.after = posts.after
        self.posts = oldRoot.posts + posts.children.map({.init(post: $0.data)})
    }
    init(posts: [PresentationPost], after: String?) {
        self.posts = posts
        self.after = after
    }
}
