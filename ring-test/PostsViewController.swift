//
//  PostsViewController.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/1/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

protocol PostCellView: class {
    func populate(author: String, title: String, comments: String, time: String, image: UIImage?, longAction: (()->Void)?, shortAction: (()->Void)?)
    func setup(with image: UIImage?)
}

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

class PostsViewController: UIViewController {
    var configurator: PostsConfigurable = PostsConfigurator.init()
    @IBOutlet private weak var tableView: UITableView!
    var presenter: PostsPresenter!
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurator.configure(viewController: self)
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    @objc private func refresh() {
        presenter.load()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        addActivityIndicator()
    }
    
    private func addActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44)
        tableView.tableFooterView = activityIndicator
    }
}

extension PostsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        presenter.configure(cell: cell, for: indexPath.row)
        return cell
    }
}

extension PostsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        presenter.prefetch(for: indexPaths.map({$0.row}))
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        presenter.cancelPrefetching(for: indexPaths.map({$0.row}))
    }
}

extension PostsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplayCell(at: indexPath.row)
    }
}

extension PostsViewController: PostsView {
    func update() {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func getCellView(at index: Int) -> PostCellView? {
        let indexPath = IndexPath.init(row: index, section: 0)
        return tableView.cellForRow(at: indexPath) as? TableViewCell
    }
    
    func presentSharingExtension(for image: UIImage) {
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        present(vc, animated: true)
    }
    func open(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension PostsViewController {
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(presenter.getEncodedData(with: tableView.indexPathsForVisibleRows?.last?.row), forKey: "encoded")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let data = coder.decodeObject(forKey: "encoded") as? Data {
            presenter.decode(data: data)
        }
    }
    
    override func applicationFinishedRestoringState() {
        guard let row = presenter.lastVisibleRow else { return }
        let indexPath = IndexPath(row: row, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
}
