//
//  Presenter.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/12/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

protocol PresenterOutput: class {
    func updateView()
    func getCellView(at index: Int) -> CellView?
    func presentSharingExtension(for image: UIImage)
}

final class Presenter {
    
    private(set) var lastVisibleRow: Int? {
        get { return result.lastVisibleRow }
        set { result.lastVisibleRow = newValue }
    }
    
    private(set) var result = PresentationRoot.init() {
        didSet {
            result.posts.forEach({$0.delegate = self})
            view?.updateView()
        }
    }
    private let imageManager = ImageLoader.init()
    private let networkManager = NetworkManager.init()
    private var isLoading = false
    private weak var view: PresenterOutput!
    
    init(view: PresenterOutput) {
        self.view = view
    }
    
    private func getPost(for index: Int) -> PresentationPost {
        return result.posts[index]
    }
    
    private func loadImage(for post: PresentationPost) {
        guard nil == post.image else { return }
        imageManager.load(for: post.thumbnailString, completion: { [unowned post](image) in
            post.image = image
        })
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

extension Presenter: PresenterProtocol {
    var numberOfRows: Int {
        return result.posts.count
    }
    
    func load() {
        networkManager.getTopPosts(after: nil, count: nil) {[unowned self] (result) in
            self.result = (try? result.map({PresentationRoot.init(posts: $0.data, oldRoot: .init())}).get()) ?? .init()
        }
    }
    
    func configure(cell: CellView, for index: Int) {
        let post = getPost(for: index)
        var shortAction: (()->Void)?
        if let url = post.url, UIApplication.shared.canOpenURL(url) {
            shortAction = {  [unowned self] in
                self.open(url: url)
            }
        }
        var longAction: (()->Void)?
        longAction = {  [unowned self, unowned post] in
            if let image = post.image {
                self.view?.presentSharingExtension(for: image)
            }
        }
        if nil == post.image {
            loadImage(for: post)
        }
        cell.populate(author: post.authorString, title: post.titleString, comments: post.commentsCountString, time: post.timeString, image: post.image, longAction: longAction, shortAction: shortAction)
    }
    
    func viewWillAppear() {
        if lastVisibleRow == nil {
            load()
        }
    }
    
    func willDisplayCell(at index: Int) {
        if index == result.posts.count - 1 {
            handlePagination()
        }
    }
    
    func prefetch(for indices: [Int]) {
        indices.forEach { (index) in
            let post = getPost(for: index)
            guard nil == post.image else { return }
            imageManager.load(for: post.thumbnailString, completion: { [unowned post](image) in
                post.image = image
            })
        }
    }
    
    func cancelPrefetching(for indices: [Int]) {
        indices.forEach { (index) in
            let post = getPost(for: index)
            imageManager.cancel(with: post.thumbnailString)
        }
    }
    
    var encodedData: Data? {
        var data: Data?
        if !result.posts.isEmpty {
            data = try? JSONEncoder.init().encode(result)
        }
        return data
    }
    
    func decode(data: Data) {
        if let newModel = try? JSONDecoder.init().decode(PresentationRoot.self, from: data) {
            result = newModel
        }
    }
}

extension Presenter: PresentationPostDelegate {
    func didUpdateImage(for post: PresentationPost) {
        if let index = result.posts.firstIndex(of: post),
            let cell = view?.getCellView(at: index) {
            cell.setup(with: result.posts[index].image)
        }
    }
}
