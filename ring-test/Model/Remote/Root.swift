//
//  Root.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/2/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import Foundation

struct Root: Decodable {
    struct Data: Decodable {
        struct Child: Decodable {
            let data: Post
        }
        let children: [Child]
        let after: String?
        let before: String?
    }
    let data: Data
}
