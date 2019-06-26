//
//  PresentationModel.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/8/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import Foundation

struct RootViewModel: Codable {
    var lastVisibleRow: Int?
    let posts: [PostViewModel]
    let after: String?
    init() {
        posts = []
        after = nil
    }
    init(posts: Root.Data, oldRoot: RootViewModel) {
        self.after = posts.after
        self.posts = oldRoot.posts + posts.children.map({.init(post: $0.data)})
    }
    init(posts: [PostViewModel], after: String?) {
        self.posts = posts
        self.after = after
    }
}
