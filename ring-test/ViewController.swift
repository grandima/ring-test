//
//  ViewController.swift
//  ring-test
//
//  Created by Dmytro Medynsky on 6/1/19.
//  Copyright © 2019 Dmytro Medynsky. All rights reserved.
//

import UIKit

protocol CellView: class {
    func populate(author: String, title: String, comments: String, time: String, image: UIImage?, longAction: (()->Void)?, shortAction: (()->Void)?)
    func setup(with image: UIImage?)
}

protocol PresenterProtocol: class {
    var numberOfRows: Int { get }
    func load()
    func configure(cell: CellView, for index: Int)
    func viewWillAppear()
    
    func willDisplayCell(at index: Int)
    func prefetch(for indices: [Int])
    func cancelPrefetching(for indices: [Int])
    
    var encodedData: Data? { get }
    func decode(data: Data)
    var lastVisibleRow: Int? { get }
    
}

class ViewController: UIViewController {
    @IBOutlet fileprivate weak var tableView: UITableView!
    var presenter: PresenterProtocol! = Presenter.init()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        presenter.configure(cell: cell, for: indexPath.row)
        return cell
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        presenter.prefetch(for: indexPaths.map({$0.row}))
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        presenter.cancelPrefetching(for: indexPaths.map({$0.row}))
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplayCell(at: indexPath.row)
    }
}

extension ViewController: PresenterOutput {
    func updateView() {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func getCellView(at index: Int) -> CellView? {
        let indexPath = IndexPath.init(row: index, section: 0)
        return tableView.cellForRow(at: indexPath) as? TableViewCell
    }
    
    func presentSharingExtension(for image: UIImage) {
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        present(vc, animated: true)
    }
}

extension ViewController {
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(presenter.encodedData, forKey: description)
//        let data = presenter.dataModel
//        coder.encode(data, forKey: "response")
//        if let indexPath = tableView.indexPathsForVisibleRows?.last {
//            coder.encode(indexPath.row, forKey: "currentRow")
//        }
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let data = coder.decodeObject(forKey: description) as? Data {
            presenter.decode(data: data)
        }
//        if let data = coder.decodeObject(forKey: "response") as? Data {
//            let row = coder.decodeInteger(forKey: "currentRow")
//            lastVisibleRow = row
//            presenter.dataModel = data
//        }
    }
    
    override func applicationFinishedRestoringState() {
        guard let row = presenter.lastVisibleRow else { return }
        let indexPath = IndexPath(row: row, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
}
