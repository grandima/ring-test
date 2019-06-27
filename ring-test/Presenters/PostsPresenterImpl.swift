//
//  PostsPresenter.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/12/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

protocol PostsPresenter: class {
    var numberOfRows: Int { get }
    func load()
    func configure(cell: PostCellView, for index: Int)
    func viewWillAppear()
    
    func willDisplayCell(at index: Int)
    func prefetch(for indices: [Int])
    func cancelPrefetching(for indices: [Int])
    func getEncodedData(with lastVisibleIndex: Int?) -> Data?
    func decode(data: Data)
    var lastVisibleRow: Int? { get }
    
}

final class PostsPresenterImpl {
    
    private(set) var lastVisibleRow: Int? {
        get { return result.lastVisibleRow }
        set { result.lastVisibleRow = newValue }
    }
    
    private(set) var result = RootViewModel.init() {
        didSet {
            result.posts.forEach({$0.delegate = self})
            view?.update()
        }
    }
    private let imageManager: ImageLoadable
    private let networkManager: PostsLoadable
    private var isLoading = false
    private weak var view: PostsView?
    
    init(view: PostsView, imageManager: ImageLoadable, networkManager: PostsLoadable) {
        self.view = view
        self.imageManager = imageManager
        self.networkManager = networkManager
    }
    
    private func getPost(for index: Int) -> PostViewModel {
        return result.posts[index]
    }
    
    private func loadImage(for post: PostViewModel) {
        guard nil == post.image else { return }
        imageManager.load(for: post.thumbnailString, completion: { [unowned post](image) in
            post.image = image
        })
    }
    
    private func getTopPosts(isNext: Bool = false) {
        guard !isLoading else { return }
        var after: String?
        var count: Int?
        if isNext {
            guard result.after != nil else { return }
            after = result.after
            count = result.posts.count
        }
        isLoading = true
        networkManager.getTopPosts(after: after, count: count) { [weak self](result) in
            guard let self = self else { return }
            self.isLoading = false
            self.result = (try? result.map({RootViewModel.init(posts: $0.data, oldRoot: (isNext ? self.result : .init()))}).get()) ?? self.result
        }
    }
    
}

extension PostsPresenterImpl: PostsPresenter {
    var numberOfRows: Int {
        return result.posts.count
    }
    
    func load() {
        getTopPosts()
    }
    
    func configure(cell: PostCellView, for index: Int) {
        let post = getPost(for: index)
        var shortAction: (()->Void)?
        if let url = post.url, UIApplication.shared.canOpenURL(url) {
            shortAction = {  [unowned self] in
                self.view?.open(url: url)
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
            getTopPosts(isNext: true)
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
            imageManager.cancel(for: post.thumbnailString)
        }
    }
    
    func getEncodedData(with lastVisibleIndex: Int?) -> Data? {
        result.lastVisibleRow = lastVisibleIndex
        var data: Data?
        if !result.posts.isEmpty {
            data = try? JSONEncoder.init().encode(result)
        }
        return data
    }
    
    func decode(data: Data) {
        if let newModel = try? JSONDecoder.init().decode(RootViewModel.self, from: data) {
            result = newModel
        }
    }
}

extension PostsPresenterImpl: PostViewModelDelegate {
    func didUpdateImage(for post: PostViewModel) {
        if let index = result.posts.firstIndex(of: post),
            let cell = view?.getCellView(at: index) {
            cell.update(with: result.posts[index].image)
        }
    }
}
