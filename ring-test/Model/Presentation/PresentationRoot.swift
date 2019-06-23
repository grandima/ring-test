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
    
    init() {
        posts = []
        after = nil
        before = nil
    }
    init(posts: Root.Data, oldRoot: PresentationRoot) {
        self.after = posts.after
        self.before = posts.before
        self.posts = oldRoot.posts + posts.children.map({.init(post: $0.data)})
    }
    init(posts: [PresentationPost], after: String?, before: String?) {
        self.posts = posts
        self.after = after
        self.before = before
    }
    func createCopy(with posts: [PresentationPost]) -> PresentationRoot {
        return .init(posts: posts, after: after, before: before)
    }
}
