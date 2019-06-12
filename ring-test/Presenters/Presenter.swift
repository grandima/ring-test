//
//  Presenter.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/12/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

protocol PresenterOutput: class {
    func update()
}

final class Presenter: NSObject,  UITableViewDataSource {
    
    enum State {
        case loading
        case loaded([PresentationPost])
        case loadingNextChunk
    }
    weak var view: PresenterOutput!
    var result = PresentationRoot.init() {
        didSet {
            view?.update()
        }
    }
    private let imageManager = ImageManager.init()
    private let networkManager = NetworkManager.init()
    func load() {
        networkManager.getTopPosts(before: nil, after: nil) {[unowned self] (result) in
            self.result = (try? result.map({PresentationRoot.init(posts: $0.data, oldRoot: .init())}).get()) ?? .init()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let post = result.posts[indexPath.row]
        cell.populate(author: post.authorString, title: post.titleString, comments: post.commentsCountString, time: post.timeString, longAction: nil, shortAction: nil)
        imageManager.getImage(for: post.thumbnail) { (image) in
            
            cell.setup(with: indexPath.row % 2 == 0 ? image : nil)
        }
        return cell
    }
    
//    func loadImage(indexPath: IndexPath) {
//        let thumbnail = result.posts[indexPath.row].thumbnail
//        imageManager.getImage(for: thumbnail) { [unowned self](image) in
//            var post = self.result.posts[indexPath.row]
//
//        }
//    }
}
