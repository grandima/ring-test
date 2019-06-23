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
    func getCell(at index: Int) -> UITableViewCell?
    func present(with image: UIImage)
}

final class Presenter: NSObject {
    
    weak var view: PresenterOutput!
    
    var dataModel: Data? {
        get {
            var data: Data?
            if !result.posts.isEmpty {
                data = try? JSONEncoder.init().encode(result)
            }
            return data
        }
        set {
            if let data = newValue,
                let newModel = try? JSONDecoder.init().decode(PresentationRoot.self, from: data) {
                result = newModel
            }
        }
    }
    
    private(set) var result = PresentationRoot.init() {
        didSet {
            result.posts.forEach({$0.delegate = self})
            view?.update()
        }
    }
    private let imageManager = ImageLoader.init()
    private let networkManager = NetworkManager.init()
    private var isLoading = false
    
    func load() {
        networkManager.getTopPosts(after: nil, count: nil) {[unowned self] (result) in
            self.result = (try? result.map({PresentationRoot.init(posts: $0.data, oldRoot: .init())}).get()) ?? .init()
        }
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == result.posts.count - 1 {
            handlePagination()
        }
    }
    
    fileprivate func getPost(for indexPath: IndexPath) -> PresentationPost {
        return result.posts[indexPath.row]
    }
    
    fileprivate func loadImage(for post: PresentationPost) {
        guard nil == post.image else { return }
        imageManager.load(for: post.thumbnail, completion: { [unowned post](image) in
            post.image = image
        })
    }
    
    fileprivate func prefetchImages(at indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            let post = getPost(for: indexPath)
            guard nil == post.image else { return }
            imageManager.load(for: post.thumbnail, completion: { [unowned post](image) in
                post.image = image
            })
        }
    }
    
    fileprivate func cancelPrefetching(at indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            let post = getPost(for: indexPath)
            imageManager.cancel(with: post.thumbnail)
        }
    }
    
    private func handlePagination() {
        guard let after = result.after, !isLoading else { return }
        let count = result.posts.count
        isLoading = true
        networkManager.getTopPosts(after: after, count: count) {[unowned self] (result) in
            self.isLoading = false
            if case .success(let root) = result {
                self.result = PresentationRoot.init(posts: root.data, oldRoot: self.result)
            }
        }
    }

    private func open(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension Presenter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        let post = getPost(for: indexPath)
        var shortAction: (()->Void)?
        if let url = post.url, UIApplication.shared.canOpenURL(url) {
            shortAction = {  [unowned self] in
                self.open(url: url)
            }
        }
        var longAction: (()->Void)?
        longAction = {  [unowned self, unowned post] in
            if let image = post.image {
                self.view.present(with: image)
            }
        }
        if nil == post.image {
            loadImage(for: post)
        }
        cell.populate(author: post.authorString, title: post.titleString, comments: post.commentsCountString, time: post.timeString, image: post.image, longAction: longAction, shortAction: shortAction)
        return cell
    }
}

extension Presenter: UITableViewDataSourcePrefetching  {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        prefetchImages(at: indexPaths)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelPrefetching(at: indexPaths)
    }
}

extension Presenter: PresentationPostDelegate {
    func didUpdateImage(for post: PresentationPost) {
        if let index = result.posts.firstIndex(of: post), let cell = view?.getCell(at: index) as? TableViewCell {
            cell.setup(with: result.posts[index].image)
//            cell.imgView.image = result.posts[index].image
        }
    }
}
