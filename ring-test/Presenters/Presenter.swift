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
            result.posts.forEach({$0.delegate = self})
            view?.update()
        }
    }
    private let imageManager = ImageLoader.init()
    private let networkManager = NetworkManager.init()
    func load() {
        networkManager.getTopPosts(before: nil, after: nil, count: nil) {[unowned self] (result) in
            self.result = (try? result.map({PresentationRoot.init(posts: $0.data, oldRoot: .init())}).get()) ?? .init()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        let post = getPost(for: indexPath)
        var openUrlClosure: (()->Void)?
        if let url = post.url, UIApplication.shared.canOpenURL(url) {
            openUrlClosure = {  [unowned self] in
                self.open(url: url)
            }
        }
        if nil == post.image {
            loadImage(for: post)
        }
        cell.populate(author: post.authorString, title: post.titleString, comments: post.commentsCountString, time: post.timeString, image: post.image, longAction: nil, shortAction: openUrlClosure)
        return cell
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
        
    }

    private func open(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func saveToLibrary(at index: Int) {
//        imageManager.getImage(for: "x") { (image) in
////            post.image = image
//        }
    }
}

extension Presenter: UITableViewDataSourcePrefetching, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        prefetchImages(at: indexPaths)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelPrefetching(at: indexPaths)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == result.posts.count - 1 {
            handlePagination()
        }
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
