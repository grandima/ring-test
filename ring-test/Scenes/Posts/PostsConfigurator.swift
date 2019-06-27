//
//  PostsConfigurator.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/24/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import Foundation

protocol PostsConfigurable {
    func configure(viewController: PostsViewController)
}

final class PostsConfigurator: PostsConfigurable {
    func configure(viewController: PostsViewController) {
        let networkLoader = NetworkLoader.init()
        let imageLoader = ImageLoader.init()
        let presenter = PostsPresenterImpl.init(view: viewController, imageManager: imageLoader, networkManager: networkLoader)
        viewController.presenter = presenter
        
    }
}
